import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:home_metering/controller/settings_controller.dart';
import 'package:home_metering/model/meter.dart';
import 'package:home_metering/utils/time.dart';
import 'package:home_metering/utils/widgets.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MetersCostChartWidget extends StatelessWidget {
  final List<Meter> meters;
  final Map<int, LinkedHashMap<DateTime, num>> consumptionsByMeterId;
  final Frequency frequency;
  final DateRange? dateRange;

  const MetersCostChartWidget(
      this.meters, this.consumptionsByMeterId, this.frequency,
      {super.key, this.dateRange});

  @override
  Widget build(BuildContext context) {
    final settings = getSettings();
    final translator = getTranslator(context);
    return SfCartesianChart(
      tooltipBehavior: TooltipBehavior(
          activationMode: ActivationMode.singleTap,
          enable: true,
      ),
      primaryXAxis:
          DateTimeCategoryAxis(dateFormat: getShortAxisDateFormat(frequency)),
      primaryYAxis: NumericAxis(
          title: AxisTitle(
              text:
                  "[${settings.currencyUnit}/${getFrequencyUnitTranslation(frequency, translator)}]")),
      legend: const Legend(isVisible: true, position: LegendPosition.top),
      series: meters.map((meter) {
        final consumptionDateTimeBuckets = consumptionsByMeterId[meter.id!]!;
        return StackedColumnSeries<MapEntry<DateTime, num>, DateTime>(
            // Bind data source
            dataSource: consumptionDateTimeBuckets.entries.toList(),
            color: meter.getColorObject(),
            name: meter.name,
            xValueMapper: (MapEntry<DateTime, num> entry, _) => entry.key,
            yValueMapper: (MapEntry<DateTime, num> entry, _) =>
                entry.value * meter.unitCost);
      }).toList(),
    );
  }
}
