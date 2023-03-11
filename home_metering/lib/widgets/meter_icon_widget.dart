import 'package:flutter/material.dart';
import 'package:home_metering/model/meter.dart';

class MeterIconWidget extends StatelessWidget {
  final Meter meter;
  final Color? color;

  const MeterIconWidget(this.meter, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    const meterMarketSize = 10.0;
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        const SizedBox(width: meterMarketSize,),
    Icon(Icons.electric_meter, color: color ?? Colors.black87),
    Icon(Icons.circle, color: meter.color == null ? null : Color(meter.color!), size: meterMarketSize,)
    ]);
  }

}
