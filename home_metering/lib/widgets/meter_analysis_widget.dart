import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:home_metering/controller/meter_reading_controller.dart';
import 'package:home_metering/controller/settings_controller.dart';
import 'package:home_metering/model/meter.dart';
import 'package:home_metering/model/meter_reading.dart';
import 'package:home_metering/utils/math.dart';
import 'package:home_metering/utils/metering.dart';
import 'package:home_metering/utils/time.dart';
import 'package:home_metering/utils/widgets.dart';
import 'package:home_metering/widgets/consumption_chart_widget.dart';
import 'package:home_metering/widgets/error_display_widget.dart';
import 'package:home_metering/widgets/kpi_widget.dart';
import 'package:home_metering/widgets/loading_widget.dart';
import 'package:home_metering/widgets/view_subtitle_widget.dart';
import 'package:intl/intl.dart';

class MeterAnalysisWidget extends StatefulWidget {
  final Meter meter;

  MeterAnalysisWidget(this.meter)
      : super(key: Key("MeterAnalysis-${meter.id}-${getMeterReadingsState()}"));

  @override
  State<MeterAnalysisWidget> createState() => _MeterAnalysisWidgetState();
}

class MeterAnalysisComputation {
  Meter meter;
  LinkedHashMap<DateTime, num?> consumptionDateTimeBuckets;
  Frequency frequency;
  DateRange dateRange;
  num? averageConsumption;
  MeterReading? lastMeterReading;
  MeterReadingState? lastMeterReadingState;
  DateTime? predictedReachOfMonitoringIndexThresholdDateTime;

  MeterAnalysisComputation(
      this.meter,
      this.consumptionDateTimeBuckets,
      this.frequency,
      this.dateRange,
      this.averageConsumption,
      this.lastMeterReading,
      this.lastMeterReadingState,
      this.predictedReachOfMonitoringIndexThresholdDateTime);

  bool checkIsForecastsAvailable() {
    return predictedReachOfMonitoringIndexThresholdDateTime != null;
  }

  static Future<MeterAnalysisComputation> fromDateRange(
      Meter meter, Frequency frequency, DateRange dateRange) async {
    List<MeterReading> sortedMeterReadings = await retrieveMeterReadings(
        meterId: meter.id!,
        dateRange: dateRange,
        isFirstsOutOfBoundReadingIncluded: true);

    final consumptionDateTimeBuckets =
        computeConsumptionFromSortedMeterReadings(
            sortedMeterReadings, meter, frequency,
            dateRange: frequency != Frequency.yearly
                ? dateRange
                : null); // Do not force range for yearly values

    final averageConsumption = computeAverage(consumptionDateTimeBuckets.values.where((v) => v != 0.0));

    // Last meter readings
    final lastMeterReading = await retrieveLastMeterReading(meterId: meter.id!);
    final lastMeterReadingState = await computeLastMeterReadingState(meter);

    // Limit reach
    DateTime? predictedLimitReachedDateTime;
    if (meter.monitoringIndexThreshold != null && lastMeterReading != null && averageConsumption != null) {
      final limit = meter.monitoringIndexThreshold!;
      num remainingFrequencies = (limit - lastMeterReading.value) / averageConsumption;
      if (meter.isDecreasing) remainingFrequencies = -remainingFrequencies;

      final num remainingMinutes;
      switch (frequency) {
        case Frequency.daily:
          remainingMinutes = remainingFrequencies * 24*60;
          break;
        case Frequency.weekly:
          remainingMinutes = remainingFrequencies * 7*24*60;
          break;
        case Frequency.monthly:
          remainingMinutes = remainingFrequencies * 30*24*60;
          break;
        case Frequency.yearly:
          remainingMinutes = remainingFrequencies * 365*24*60;
          break;
        default:
          throw Exception("Not implemented frequency in limit reach prediction");
      }
      predictedLimitReachedDateTime = lastMeterReading.dateTime.add(Duration(minutes: remainingMinutes.ceil()));
    }

    return MeterAnalysisComputation(
        meter,
        consumptionDateTimeBuckets,
        frequency,
        dateRange,
        averageConsumption,
        lastMeterReading,
        lastMeterReadingState,
        predictedLimitReachedDateTime);
  }
}

class _MeterAnalysisWidgetState extends State<MeterAnalysisWidget> {
  late Future<MeterAnalysisComputation> _futureMeterAnalysisComputation;
  Frequency frequency = Frequency.monthly; // Initialize at init state
  DateTime? endDateTime;

  @override
  void initState() {
    super.initState();
    frequency = globalFrequency;
    _refreshAnalysisComputation();
  }

  @override
  void didUpdateWidget(MeterAnalysisWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.meter != widget.meter) {
      setState(() {
        _refreshAnalysisComputation();
      });
    }
  }

  void _refreshAnalysisComputation() {
    _futureMeterAnalysisComputation = () async {
      final dateRange = _getCurrentDateRange();
      return await MeterAnalysisComputation.fromDateRange(
          widget.meter, frequency, dateRange);
    }();
  }

  void _updateFrequency(Frequency f) {
    globalFrequency = f;
    setState(() {
      frequency = f;
      _refreshAnalysisComputation();
    });
  }

  DateRange _getCurrentDateRange() {
    return getDisplayableDateRangeForFrequency(frequency, endDateTime);
  }

  void _displayBeforeRangeReadings() {
    final currentDateRange = _getCurrentDateRange();
    setState(() {
      endDateTime =
          currentDateRange.fromDateTime.add(const Duration(milliseconds: -1));
      _refreshAnalysisComputation();
    });
  }

  void _displayAfterRangeReadings() {
    if (endDateTime == null) return; // already at max

    final currentDateRange = _getCurrentDateRange();
    DateTime? candidateEndDateTime = currentDateRange.toDateTime.add(
        currentDateRange.toDateTime.difference(currentDateRange.fromDateTime));
    if (candidateEndDateTime.isAfter(DateTime.now())) {
      candidateEndDateTime = null;
    }

    setState(() {
      endDateTime = candidateEndDateTime;
      _refreshAnalysisComputation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MeterAnalysisComputation>(
        future: _futureMeterAnalysisComputation,
        builder: (BuildContext context,
            AsyncSnapshot<MeterAnalysisComputation> snapshot) {
          if (snapshot.hasError) {
            return ErrorDisplayWidget(error: snapshot.error);
          } else if (!snapshot.hasData) {
            return const LoadingWidget();
          } else {
            final meterAnalysisComputation = snapshot.data!;
            return _buildAnalysisWidget(context, meterAnalysisComputation);
          }
        });
  }

  Widget _buildAnalysisWidget(
    BuildContext context, MeterAnalysisComputation meterAnalysisComputation) {
    final theme = Theme.of(context);
    final translator = getTranslator(context);
    final dateFormatter = DateFormat.yMd();
    final numberFormatter = NumberFormat("##0.0#");
    final settings = getSettings();
    final currencyFormatter = NumberFormat.currency(symbol: '');
    final frequencyUnitTranslation =
        getFrequencyUnitTranslation(frequency, translator);

    // Prepare base bottom sections
    List<Widget> sections = [
      ViewSubtitleWidget(translator.statistics),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          KPIWidget(
              meterAnalysisComputation.averageConsumption == null ? '-' : "${numberFormatter.format(meterAnalysisComputation.averageConsumption)} ${meterAnalysisComputation.meter.unit}/$frequencyUnitTranslation",
              iconData: Icons.shopping_cart,
              label: translator.averageConsumption),
          KPIWidget(
              meterAnalysisComputation.averageConsumption == null ? '-' : "${currencyFormatter.format((meterAnalysisComputation.averageConsumption ?? 0.0) * meterAnalysisComputation.meter.unitCost)} ${settings.currencyUnit}/$frequencyUnitTranslation",
              iconData: Icons.euro,
              label: translator.averageCost)
        ],
      ),
      ViewSubtitleWidget(
        translator.lastReading,
        marginTop: defaultViewPadding,
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _buildLastMeterReadingTrendKPI(
            meterAnalysisComputation.lastMeterReadingState, numberFormatter),
        const SizedBox(
          width: defaultViewPadding,
        ),
        KPIWidget(
          "${meterAnalysisComputation.lastMeterReading != null ? daysSince(meterAnalysisComputation.lastMeterReading!.dateTime) : '-'} ${translator.days}",
          iconData: Icons.watch_later_outlined,
          label: translator.sinceLastReading,
        ),
      ]),
    ];

    // Forecasts
    if (meterAnalysisComputation.checkIsForecastsAvailable()) {
      sections.add(ViewSubtitleWidget(
        translator.forecasts,
        marginTop: defaultViewPadding,
      ));
      Row forecastsRow =
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: []);
      sections.add(forecastsRow);
      if (meterAnalysisComputation.predictedReachOfMonitoringIndexThresholdDateTime != null) {
        final formattedDate = dateFormatter
            .format(meterAnalysisComputation.predictedReachOfMonitoringIndexThresholdDateTime!);
        final daysToLimit = meterAnalysisComputation.predictedReachOfMonitoringIndexThresholdDateTime!.difference(DateTime.now()).inDays;
        final label = translator.expectedThresholdReach;
        final tooltipMessage = TextSpan(text: numberFormatter.format(meterAnalysisComputation.meter.monitoringIndexThreshold));

        final KPIWidget limitReachedKpi;
        if (daysToLimit < 14) {
          limitReachedKpi = KPIWidget.instantiateErrorKPI(formattedDate,
              iconData: Icons.assignment_late, label: label, tooltipMessage: tooltipMessage);
        } else if (daysToLimit < 30) {
          limitReachedKpi = KPIWidget.instantiateWarningKPI(formattedDate,
              iconData: Icons.assignment_late, label: label, tooltipMessage: tooltipMessage);
        } else {
          limitReachedKpi = KPIWidget(formattedDate,
              iconData: Icons.assignment_late, label: label, tooltipMessage: tooltipMessage);
        }

        forecastsRow.children.add(limitReachedKpi);
      }
    }

    // Build final view
    return Scrollbar(
        child: Padding(
            padding: const EdgeInsets.all(defaultViewPadding),
            child: Column(children: <Widget>[
              ViewSubtitleWidget(translator.consumptions,
                  marginBottom: 0,
                  filter: DropdownButton(
                    value: frequency,
                    style: theme.textTheme.bodyMedium,
                    onChanged: (value) =>
                        value != null ? _updateFrequency(value) : {},
                    items:
                        Frequency.values.map<DropdownMenuItem<Frequency>>((f) {
                      return DropdownMenuItem<Frequency>(
                          value: f,
                          child: Text(getFrequencyTranslation(f, translator)));
                    }).toList(),
                  )),
              ConsumptionChartWidget(
                widget.meter,
                meterAnalysisComputation.consumptionDateTimeBuckets,
                frequency,
              ),
              Row(children: [
                IconButton(
                  onPressed: _displayBeforeRangeReadings,
                  icon: const Icon(Icons.arrow_left),
                  iconSize: 32,
                  splashRadius: 15,
                ),
                Expanded(
                    child: Text(
                  "${dateFormatter.format(meterAnalysisComputation.dateRange.fromDateTime)} - ${dateFormatter.format(meterAnalysisComputation.dateRange.toDateTime)}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: theme.textTheme.titleMedium?.fontSize),
                )),
                IconButton(
                  onPressed: _displayAfterRangeReadings,
                  icon: const Icon(Icons.arrow_right),
                  iconSize: 32,
                  splashRadius: 15,
                  color: endDateTime == null ? theme.disabledColor : null,
                ),
              ]),
              ...sections,
            ])));
  }

  Widget _buildLastMeterReadingTrendKPI(
      MeterReadingState? lastMeterReadingState, NumberFormat numberFormatter) {
    final evolutionValue = lastMeterReadingState?.relativeEvolution();
    final translator = getTranslator(context);
    final label = translator.consumptionTrend;
    if (lastMeterReadingState == null || evolutionValue == null) {
      return KPIWidget(
        "- %",
        iconData: Icons.timeline,
        label: label,
      );
    } else {
      final trendFormat = NumberFormat("+ 0 %;- 0 %;0 %");
      var formattedValue = trendFormat.format(evolutionValue);

      // Tooltip
      const tooltipValueTextStyle = TextStyle(fontWeight: FontWeight.bold);
      final translatedFrequency = getFrequencyUnitTranslation(
          lastMeterReadingState.consumptionFrequency, translator);
      final tooltipMessage = TextSpan(
        text: '', // Empty to keep base style
        children: <InlineSpan>[
          TextSpan(
            text: "${translator.analysisPeriod} : 365 ${translator.days}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text: "\n",
            style: TextStyle(fontSize: 2),
          ),
          TextSpan(text: "\n${translator.expectedConsumption} : ", children: [
            TextSpan(
                text:
                    "${numberFormatter.format(lastMeterReadingState.expectedConsumption)} ± ${numberFormatter.format(lastMeterReadingState.expectedTolerance)} ${lastMeterReadingState.meter.unit}/$translatedFrequency",
                style: tooltipValueTextStyle),
          ]),
          TextSpan(text: '\n${translator.currentConsumption} : ', children: [
            TextSpan(
              text:
                  "${numberFormatter.format(lastMeterReadingState.consumption)} ${lastMeterReadingState.meter.unit}/$translatedFrequency",
              style: tooltipValueTextStyle,
            ),
          ]),
        ],
      );

      final isOutlier = lastMeterReadingState.isOutlier();
      final KPIWidget kpiWidget;
      if (isOutlier) {
        kpiWidget = KPIWidget.instantiateErrorKPI(
          "$formattedValue ${translator.abnormal}",
          label: label,
          tooltipMessage: tooltipMessage,
          iconData: Icons.warning,
        );
      } else if (evolutionValue.abs() < 0.05) {
        kpiWidget = KPIWidget(
          formattedValue,
          label: label,
          tooltipMessage: tooltipMessage,
          iconData: Icons.trending_flat,
        );
      } else if (evolutionValue < 0) {
        kpiWidget = KPIWidget.instantiateSuccessKPI(
          formattedValue,
          label: label,
          tooltipMessage: tooltipMessage,
          iconData: Icons.trending_down,
        );
      } else {
        kpiWidget = KPIWidget.instantiateWarningKPI(
          formattedValue,
          label: label,
          tooltipMessage: tooltipMessage,
          iconData: Icons.trending_up,
        );
      }

      return kpiWidget;
    }
  }
}
