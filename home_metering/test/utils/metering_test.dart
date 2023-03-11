import 'package:home_metering/model/meter.dart';
import 'package:home_metering/model/meter_reading.dart';
import 'package:home_metering/utils/metering.dart';
import 'package:home_metering/utils/time.dart';
import 'package:test/test.dart';

void main() {
  test('Compute decreasing daily consumptions', () {
    final meter = Meter(id: 42, name: "Meter", unit: "l", unitCost: 1, isDecreasing: true);
    final readings = [
      MeterReading(meterId: meter.id!, dateTime: DateTime(2023, 1, 14, 12), value: 2000),
      MeterReading(meterId: meter.id!, dateTime: DateTime(2023, 1, 18, 12), value: 1950),
      MeterReading(meterId: meter.id!, dateTime: DateTime(2023, 1, 21, 12), value: 1900),
    ];

    final consumptions = computeConsumptionFromSortedMeterReadings(readings, meter, Frequency.daily);

    expect(consumptions[DateTime(2023, 1, 15)], closeTo(50 / 4, 0.01));
    expect(consumptions[DateTime(2023, 1, 20)], closeTo(50 / 3, 0.01));
    expect(consumptions[DateTime(2023, 1, 14)], closeTo(50 / 4 / 2, 0.01));
    expect(consumptions[DateTime(2023, 1, 21)], closeTo(50 / 3 / 2, 0.01));
    expect(consumptions[DateTime(2023, 1, 18)], closeTo(50 / 4 / 2 + 50 / 3 / 2, 0.01));
  });

  test('Compute monthly consumptions with more than one reading in month', () {
    final meter = Meter(id: 42, name: "Meter", unit: "l", unitCost: 1, isDecreasing: true);
    final readings = [
      MeterReading(meterId: meter.id!, dateTime: DateTime(2023, 1, 14, 12), value: 2000),
      MeterReading(meterId: meter.id!, dateTime: DateTime(2023, 1, 18, 12), value: 1950),
      MeterReading(meterId: meter.id!, dateTime: DateTime(2023, 1, 21, 12), value: 1900),
    ];

    final consumptions = computeConsumptionFromSortedMeterReadings(readings, meter, Frequency.monthly);

    expect(consumptions[DateTime(2023, 1, 1)], closeTo(100, 0.01));
  });

  test('Parse single meter CSV with date time', () {
    final meter = Meter(id: 42, name: "Meter", unit: "l", unitCost: 1, isDecreasing: true);
    const csvContent = "Date,Time,Value\r\n2022-08-03,12:30,45.5\r\n";
    final readings = parseMeterReadingsFromCSVString(csvContent, preferredMeter: meter);

    expect(readings.length, 1);
    final reading = readings.first;
    expect(reading.value, closeTo(45.5, 0.01));
    expect(reading.dateTime, DateTime(2022,8,3,12,30));
  });

  test('Parse single meter CSV with spaces', () {
    final meter = Meter(id: 42, name: "Meter", unit: "l", unitCost: 1, isDecreasing: true);
    const csvContent = "Date, Time, Value\r\n2022-08-03, 12:30, 45.5\r\n";
    final readings = parseMeterReadingsFromCSVString(csvContent, preferredMeter: meter);

    expect(readings.length, 1);
    final reading = readings.first;
    expect(reading.value, closeTo(45.5, 0.01));
    expect(reading.dateTime, DateTime(2022,8,3,12,30));
  });

  test('Parse single meter CSV with date time and reset', () {
    final meter = Meter(id: 42, name: "elec", unit: "l", unitCost: 1, isDecreasing: true);
    const csvContent = "Date,Time,Value,isReset\r\n2022-08-03,12:30,45.5,1\r\n";
    final readings = parseMeterReadingsFromCSVString(csvContent, preferredMeter: meter);

    expect(readings.length, 1);
    final reading = readings.first;
    expect(reading.isReset, true);
    expect(reading.dateTime, DateTime(2022,8,3,12,30));
  });

  test('Parse single meter CSV with date only', () {
    final meter = Meter(id: 42, name: "Meter", unit: "l", unitCost: 1, isDecreasing: true);
    const csvContent = "Date,Value\r\n2022-08-03,45.5\r\n";
    final readings = parseMeterReadingsFromCSVString(csvContent, preferredMeter: meter);

    expect(readings.length, 1);
    final reading = readings.first;
    expect(reading.value, closeTo(45.5, 0.01));
    expect(reading.dateTime, DateTime(2022,8,3));
  });

  test("Parse multiple meters CSV", () {
    final meterA = Meter(id: 42, name: "A", unit: "l", unitCost: 1, isDecreasing: true);
    final meterB = Meter(id: 43, name: "B", unit: "kWh", unitCost: 1, isDecreasing: false);
    const csvContent = "Date,Time,Value,isReset,Meter\r\n2022-08-03,12:30,45.5,1,A\r\n2022-08-03,12:30,90,,b\r\n2022-08-03,12:30,80,,\r\n2022-08-03,12:30,80,,unknown\r\n";
    final readings = parseMeterReadingsFromCSVString(csvContent, preferredMeter: meterA, meters: [meterA, meterB]);

    expect(readings.length, 3);
    expect(readings.where((reading) => reading.meterId == meterA.id).length, 2);
    expect(readings.where((reading) => reading.meterId == meterB.id).length, 1);
  });
}