import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:home_metering/controller/meter_controller.dart';

import 'package:home_metering/controller/meter_reading_controller.dart';
import 'package:home_metering/controller/settings_controller.dart';
import 'package:home_metering/model/meter.dart';
import 'package:home_metering/model/meter_reading.dart';
import 'package:home_metering/utils/metering.dart';
import 'package:home_metering/utils/time.dart';
import 'package:home_metering/utils/widgets.dart';
import 'package:home_metering/views/meter_view.dart';
import 'package:home_metering/widgets/error_display_widget.dart';
import 'package:home_metering/widgets/kpi_widget.dart';
import 'package:home_metering/widgets/loading_widget.dart';
import 'package:home_metering/widgets/meter_icon_widget.dart';
import 'package:home_metering/widgets/meters_cost_chart_widget.dart';
import 'package:home_metering/widgets/no_meter_widget.dart';
import 'package:home_metering/widgets/view_subtitle_widget.dart';
import 'package:intl/intl.dart';

class AllMetersAnalysisWidget extends StatefulWidget {
  const AllMetersAnalysisWidget({super.key});

  @override
  State<AllMetersAnalysisWidget> createState() =>
      _AllMetersAnalysisWidgetState();
}

class AllMetersAnalysisComputation {
  List<Meter> meters;
  Frequency frequency;
  DateRange dateRange;
  Map<int, LinkedHashMap<DateTime, num>> consumptionsByMeterId;
  num averageCost;
  MeterReading? lastMeterReading;
  Map<int, MeterReadingState>? lastMeterReadingStateByMeterId;

  AllMetersAnalysisComputation(this.consumptionsByMeterId, this.meters,
      this.frequency, this.dateRange, this.averageCost,
      {this.lastMeterReading, this.lastMeterReadingStateByMeterId});

  static Future<AllMetersAnalysisComputation> fromDateRange(
      Frequency frequency, DateRange dateRange) async {
    // Retrieve
    List<Meter> meters = await retrieveMeters();
    Map<int, LinkedHashMap<DateTime, num>> consumptionsByMeterId = {};
    for (final meter in meters) {
      final meterReadings = await retrieveMeterReadings(
          meterId: meter.id!,
          dateRange: dateRange,
          isFirstsOutOfBoundReadingIncluded: true);
      final consumptions = computeConsumptionFromSortedMeterReadings(
          meterReadings, meter, frequency,
          dateRange: dateRange);
      consumptionsByMeterId[meter.id!] = consumptions;
    }

    final averageCost =
        computeAverageMeterConsumptionsCost(meters, consumptionsByMeterId);

    // Last meter readings
    var lastMeterReading = await retrieveLastMeterReading();

    // Alerts
    Map<int, MeterReadingState> lastMeterReadingStateByMeterId = {};
    for (final meter in meters) {
      final meterReadingState = await computeLastMeterReadingState(meter);
      if (meterReadingState != null) {
        lastMeterReadingStateByMeterId[meter.id!] = meterReadingState;
      }
    }

    return AllMetersAnalysisComputation(
      consumptionsByMeterId,
      meters,
      frequency,
      dateRange,
      averageCost,
      lastMeterReading: lastMeterReading,
      lastMeterReadingStateByMeterId: lastMeterReadingStateByMeterId,
    );
  }
}

class _AllMetersAnalysisWidgetState extends State<AllMetersAnalysisWidget> {
  late Future<AllMetersAnalysisComputation> _futureAllMetersAnalysisComputation;
  Frequency frequency = Frequency.monthly; // Initialized at init state
  DateTime? endDateTime;

  @override
  void initState() {
    super.initState();
    frequency = globalFrequency;
    _refreshAnalysisComputation();
  }

  @override
  void didUpdateWidget(AllMetersAnalysisWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _refreshAnalysisComputation();
    });
  }

  void _refreshAnalysisComputation() {
    _futureAllMetersAnalysisComputation = () async {
      final dateRange = _getCurrentDateRange();
      return await AllMetersAnalysisComputation.fromDateRange(
          frequency, dateRange);
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
          currentDateRange.fromDateTime.add(const Duration(seconds: -1));
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

  void _navigateToMeterView({int? meterId}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MeterView(initialMeterId: meterId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AllMetersAnalysisComputation>(
        future: _futureAllMetersAnalysisComputation,
        builder: (BuildContext context,
            AsyncSnapshot<AllMetersAnalysisComputation> snapshot) {
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

  Widget _buildAnalysisWidget(BuildContext context,
      AllMetersAnalysisComputation allMetersAnalysisComputation) {
    // Formatting
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMd();
    final currencyFormat = NumberFormat.currency(symbol: '');
    final settings = getSettings();
    final translator = getTranslator(context);

    return Scrollbar(
        child: Padding(
            padding: const EdgeInsets.all(defaultViewPadding),
            child: Column(children: <Widget>[
              ViewSubtitleWidget(
                translator.cost,
                marginBottom: 0,
                filter: DropdownButton(
                  value: frequency,
                  style: theme.textTheme.bodyMedium,
                  onChanged: (value) =>
                      value != null ? _updateFrequency(value) : {},
                  items: Frequency.values.map<DropdownMenuItem<Frequency>>((f) {
                    return DropdownMenuItem<Frequency>(
                        value: f, child: Text(getFrequencyTranslation(f, translator))); // TODO translate
                  }).toList(),
                ),
              ),
              MetersCostChartWidget(
                  allMetersAnalysisComputation.meters,
                  allMetersAnalysisComputation.consumptionsByMeterId,
                  frequency),
              Row(children: [
                IconButton(
                  onPressed: _displayBeforeRangeReadings,
                  icon: const Icon(Icons.arrow_left),
                  iconSize: 32,
                  splashRadius: 15,
                ),
                Expanded(
                    child: Text(
                  "${dateFormat.format(allMetersAnalysisComputation.dateRange.fromDateTime)} - ${dateFormat.format(allMetersAnalysisComputation.dateRange.toDateTime)}",
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
              ViewSubtitleWidget(translator.statistics, marginTop: defaultMargin),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                KPIWidget(
                  "${currencyFormat.format(allMetersAnalysisComputation.averageCost)} ${settings.currencyUnit}/${getFrequencyUnitTranslation(frequency, translator)}",
                  iconData: Icons.euro,
                  label: translator.averageCost,
                ),
                KPIWidget(
                  "${allMetersAnalysisComputation.lastMeterReading != null ? daysSince(allMetersAnalysisComputation.lastMeterReading!.dateTime) : '-'} ${translator.days}",
                  iconData: Icons.watch_later_outlined,
                  label: translator.sinceLastReading,
                ),
              ]),
              ViewSubtitleWidget(translator.meters, marginTop: defaultViewPadding * 1.5),
              _buildMetersNavigation(context, allMetersAnalysisComputation),
            ])));
  }

  Widget _buildMetersNavigation(BuildContext context,
      AllMetersAnalysisComputation allMetersAnalysisComputation) {
    if (allMetersAnalysisComputation.meters.isEmpty) {
      return Column(children: const [
        SizedBox(
          height: defaultMargin,
        ),
        NoMeterWidget()
      ]);
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: allMetersAnalysisComputation.meters
            .map((meter) {
              final lastMeterReadingState = allMetersAnalysisComputation.lastMeterReadingStateByMeterId?[meter.id];
              return _buildMeterNavigationButton(context, meter, lastMeterReadingState: lastMeterReadingState);
        })
            .toList(),
      );
    }
  }

  TextButton _buildMeterNavigationButton(BuildContext context, Meter meter, {MeterReadingState? lastMeterReadingState}) {
    final bool isInAlert = lastMeterReadingState?.isOutlier() ?? false;
    return TextButton(
        onPressed: () => _navigateToMeterView(meterId: meter.id),
        child: Column(children: [
          MeterIconWidget(meter, color: isInAlert ? Colors.red : null),
          const SizedBox(
            height: 4,
          ),
          Text(
            isInAlert ? "! ${meter.name} !" : meter.name,
            style: TextStyle(color: isInAlert ? Colors.red : Colors.black87),
          ),
        ]));
  }
}
