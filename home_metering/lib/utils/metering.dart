import 'dart:collection';
import 'dart:math';

import 'package:csv/csv.dart';
import 'package:csv/csv_settings_autodetection.dart';
import 'package:home_metering/controller/meter_reading_controller.dart';
import 'package:home_metering/model/meter.dart';
import 'package:home_metering/model/meter_reading.dart';
import 'package:home_metering/utils/math.dart';
import 'package:home_metering/utils/time.dart';
import 'package:intl/intl.dart';

// Scaling factor for ease of debugging and to not get a total per day too low (e.g. 10e-7)
const _msPerDay = 24 * 3600 * 1000;

LinkedHashMap<DateTime, num> computeConsumptionFromSortedMeterReadings(
    List<MeterReading> sortedMeterReadings, Meter meter, Frequency frequency,
    {DateRange? dateRange}) {
  // Create buckets container
  LinkedHashMap<DateTime, num> consumptionBuckets =
      LinkedHashMap<DateTime, num>();
  if (sortedMeterReadings.isEmpty) return consumptionBuckets;

  // initialize buckets if date range provided
  if (dateRange != null) {
    for (final t in getDateTimeIteratorInRange(dateRange, frequency)) {
      consumptionBuckets[t] = 0;
    }
  }

  // Fill buckets from measurements
  int i = 1;
  DateTime previousDateTime = sortedMeterReadings[0].dateTime;
  num previousIndex = sortedMeterReadings[0].value;
  while (i < sortedMeterReadings.length) {
    MeterReading reading = sortedMeterReadings[i];
    if (!reading.isReset) {
      // Compute total
      num totalTimeDelta = (reading.dateTime.millisecondsSinceEpoch -
              previousDateTime.millisecondsSinceEpoch) /
          _msPerDay;
      num totalPerDay = (reading.value - previousIndex) / totalTimeDelta;
      if (meter.isDecreasing) {
        totalPerDay = -totalPerDay;
      }

      // Distribute it according to frequency
      DateTime tStart = floorDateTime(previousDateTime, frequency);
      DateTime tEnd = floorDateTime(reading.dateTime, frequency);

      // Beginning of the period
      DateTime t1 = getNextDateTime(tStart, frequency);
      if (dateRange == null || dateRange.isIncluding(tStart)) {
        consumptionBuckets[tStart] = (consumptionBuckets[tStart] ?? 0.0) +
            (max(
                    0.0,
                    min(
                        (t1.millisecondsSinceEpoch -
                                previousDateTime.millisecondsSinceEpoch) /
                            _msPerDay,
                        totalTimeDelta)) *
                totalPerDay);
      }

      // Middle of the period
      DateTime t = t1;
      while (t.isBefore(tEnd)) {
        t1 = getNextDateTime(t, frequency);
        if (dateRange == null || dateRange.isIncluding(t)) {
          consumptionBuckets[t] = (consumptionBuckets[t] ?? 0) +
              ((t1.millisecondsSinceEpoch - t.millisecondsSinceEpoch) /
                  _msPerDay *
                  totalPerDay); // We are guaranteed that the previous is set to 0;
        }
        // Iterate
        t = t1;
      }

      // End of the period
      if (tEnd.isAfter(tStart) &&
          (dateRange == null || dateRange.isIncluding(tEnd))) {
        // protect from double counting if interval between readings is less than the frequency
        consumptionBuckets[tEnd] = (consumptionBuckets[tEnd] ?? 0.0) +
            (max(
                    0.0,
                    min(
                        (reading.dateTime.millisecondsSinceEpoch -
                                tEnd.millisecondsSinceEpoch) /
                            _msPerDay,
                        totalTimeDelta)) *
                totalPerDay);
      }
    }

    // Iterate
    i += 1;
    previousDateTime = reading.dateTime;
    previousIndex = reading.value;
  }

  // Return
  return consumptionBuckets;
}

String buildCSVStringFromMeterReadings(
    Iterable<MeterReading> meterReadings, Iterable<Meter>? meters) {
  final f = NumberFormat("00");

  // Prepare meter name map
  Map<int, String> meterNameById = {};
  for (final meter in meters ?? <Meter>[]) {
    meterNameById[meter.id!] = meter.name;
  }

  // Write content
  String content = "date,time,value,meter,is_reset\n";
  for (final meterReading in meterReadings) {
    // Prepare columns
    final stringDate =
        "${f.format(meterReading.dateTime.year)}-${f.format(meterReading.dateTime.month)}-${f.format(meterReading.dateTime.day)}";
    final stringTime =
        "${f.format(meterReading.dateTime.hour)}:${f.format(meterReading.dateTime.minute)}:${f.format(meterReading.dateTime.second)}";
    final meterName = meterNameById[meterReading.meterId];
    final stringIsReset = meterReading.isReset ? "1" : "0";

    // Concatenate
    content += "${[
      stringDate,
      stringTime,
      meterReading.value,
      meterName,
      stringIsReset
    ].join(",")}\n";
  }

  return content;
}

List<String> getCSVStringFormats() {
  return [
    "date-iso8601 (2023-02-24), value (45.5)",
    "date-iso8601 (2023-02-24), time-iso8601 (14:32), value (45.5)",
    "date-iso8601 (2023-02-24), time-iso8601 (14:32), value (45.5), is-reset (1)",
    "date-iso8601 (2023-02-24), time-iso8601 (14:32), value (45.5), is-reset (1), meter-name (elec)"
  ];
}

List<MeterReading> parseMeterReadingsFromCSVString(String rawCSV,
    {Iterable<Meter>? meters, Meter? preferredMeter}) {


  // Prepare
  List<MeterReading> newMeterReadings = [];
  Map<String, Meter>? meterByName = meters == null
      ? null
      : Map.fromEntries(meters.map((m) => MapEntry(m.name.toLowerCase(), m)));

  // Convert to list
  const csvSettingsDetector = FirstOccurrenceSettingsDetector(eols: ['\r\n', '\n']);
  const csvConverter = CsvToListConverter(csvSettingsDetector: csvSettingsDetector);
  final csvList = csvConverter.convert(rawCSV);

  // Parse lines
  // Coarse implementation of CSV parsing, could be improved with a feedback to the user about the lines with error
  for (final csvLine in csvList) {
    // Attempt to parse values
    DateTime? dateTime;
    dynamic indexValue;
    if (csvLine.length < 2) {
      continue; // Too short, skip
    } else if (csvLine.length == 2) {
      dateTime = DateTime.tryParse(csvLine[0].toString());
      indexValue = csvLine[1];
    } else {
      dateTime = DateTime.tryParse(
          "${csvLine[0].toString().trim()}T${csvLine[1].toString().trim()}");
      indexValue = csvLine[2];
    }

    final isReset =
        csvLine.length >= 4 && (csvLine[3] == 1 || csvLine[3] == "1");

    Meter? meter = preferredMeter;
    if (csvLine.length >= 5 && csvLine[4] != null && csvLine[4].trim() != "") {
      final lowerMeterName = csvLine[4].trim().toLowerCase();
      print("meter name \"$lowerMeterName\" from line ${csvLine} among ${meterByName?.keys} ?");
      if (preferredMeter != null && lowerMeterName == preferredMeter.name.toLowerCase()) {
      } // Already set to preferred meter
      else if (meterByName == null) {
        throw "Meters must be provided to parse multi-meters CSV from column 4.";
      } else {
        meter = meterByName[lowerMeterName];
      }
    }

    // Skip if cannot read
    if (dateTime == null || indexValue is! num || meter == null) {
      print("Invalid datetime \"$dateTime\" or value \"$indexValue\" or meter \"${meter?.name}\"");
      continue;
    }

    // Create reading
    newMeterReadings.add(MeterReading(
        meterId: meter.id!,
        dateTime: dateTime,
        value: indexValue,
        isReset: isReset));
    // Duplicates will be automatically merged by the database
  }

  return newMeterReadings;
}

num computeAverageMeterConsumptionsCost(List<Meter> meters,
    Map<int, LinkedHashMap<DateTime, num>> consumptionsByMeterId) {
  var totalCostByDateTime = <DateTime, num>{};
  for (final meter in meters) {
    final consumptions = consumptionsByMeterId[meter.id!]!;
    for (final consumptionEntry in consumptions.entries) {
      totalCostByDateTime[consumptionEntry.key] =
          (totalCostByDateTime[consumptionEntry.key] ?? 0.0) +
              consumptionEntry.value * meter.unitCost;
    }
  }
  return computeAverage(totalCostByDateTime.values.where((v) => v != 0.0));
}

class MeterReadingState {
  MeterReading reading;
  Meter meter;
  Frequency consumptionFrequency;
  num consumption;
  num expectedConsumption;
  num expectedTolerance;

  MeterReadingState(
      this.reading,
      this.meter,
      this.consumption,
      this.consumptionFrequency,
      this.expectedConsumption,
      this.expectedTolerance);

  num? relativeEvolution() {
    if (expectedConsumption.abs() < 0.01) {
      return null;
    } else {
      return (consumption - expectedConsumption) / expectedConsumption;
    }
  }

  bool isOutlier() {
    return consumption < expectedConsumption - expectedTolerance ||
        consumption > expectedConsumption + expectedTolerance;
  }
}

Future<MeterReadingState?> computeLastMeterReadingState(meter,
    {double madFactor = 3.0}) async {
  final now = DateTime.now();
  final dateRange = DateRange(now.add(const Duration(days: -365)), now);
  const frequency = Frequency.daily;
  final readings = await retrieveMeterReadings(
      meterId: meter.id!,
      isFirstsOutOfBoundReadingIncluded: true,
      dateRange: dateRange);

  // Check data is significant
  if (readings.length < 5 ||
      readings.last.dateTime.difference(readings.first.dateTime).inDays < 15) {
    return null;
  }

  // Compute consumptions
  var consumptions =
      computeConsumptionFromSortedMeterReadings(readings, meter, frequency);
  if (consumptions.length < 3) {
    return null;
  } // First and last may not be complete consumptions

  // Compute range
  final medianConsumption = computeMedian(consumptions.values);
  final mad = 1.482 *
      computeMedian(
          consumptions.values.map((v) => (v - medianConsumption).abs()));
  final tolerance =
      max(mad * madFactor, medianConsumption.abs() * 0.1); // 10% is ok

  // Check value
  final lastConsumption = consumptions.values.toList()[consumptions.length - 2];
  return MeterReadingState(readings.last, meter, lastConsumption, frequency,
      medianConsumption, tolerance);
}
