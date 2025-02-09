import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:home_metering/model/meter.dart';
import 'package:home_metering/utils/time.dart';
import 'package:home_metering/utils/widgets.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ConsumptionChartWidget extends StatelessWidget {
  final Meter meter;
  final LinkedHashMap<DateTime, num?> consumptionDateTimeBuckets;
  final Frequency frequency;
  final DateRange? dateRange;

  const ConsumptionChartWidget(
      this.meter, this.consumptionDateTimeBuckets, this.frequency,
      {super.key, this.dateRange});

  @override
  Widget build(BuildContext context) {
    final translator = getTranslator(context);
    return SfCartesianChart(
      tooltipBehavior: TooltipBehavior(
          activationMode: ActivationMode.singleTap,
          enable: true
      ),
        primaryXAxis: DateTimeCategoryAxis(
            dateFormat: getShortAxisDateFormat(frequency)),
        primaryYAxis: NumericAxis(
            title: AxisTitle(
                text:
                    "[${meter.unit}/${getFrequencyUnitTranslation(frequency, translator)}]")),
        series: <ColumnSeries<MapEntry<DateTime, num?>, DateTime>>[
          ColumnSeries<MapEntry<DateTime, num?>, DateTime>(
              // Bind data source
            name: meter.name,
              dataSource: consumptionDateTimeBuckets.entries.toList(),
              color: meter.getColorObject(),
              xValueMapper: (MapEntry<DateTime, num?> entry, _) => entry.key,
              yValueMapper: (MapEntry<DateTime, num?> entry, _) => entry.value)
        ]);
  }
}
