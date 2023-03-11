import 'package:flutter/material.dart';

class KPIWidget extends StatelessWidget {
  final IconData iconData;
  final String textValue;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final Color? textColor;
  final String? label;
  final TextSpan? tooltipMessage;

  const KPIWidget(this.textValue, {this.iconData = Icons.insights, this.iconColor, this.label, this.textColor, this.iconBackgroundColor, this.tooltipMessage, super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> rightSideWidgets = [];
    if (label != null) {
      rightSideWidgets.addAll([Text(
        label!,
        style: Theme.of(context).textTheme.bodySmall,
        overflow: TextOverflow.ellipsis,
      ),
        const SizedBox(height: 2,)
      ]);
    }

    var valueStyle = Theme.of(context).textTheme.titleMedium!;
    if (textColor != null) {
        valueStyle = valueStyle.copyWith(color: textColor);
    }

    rightSideWidgets.add(Text(
      textValue,
      style: valueStyle,
    ));

    // Build kpi row
    final kpiRow = Row(children: [
      CircleAvatar(
        backgroundColor: iconBackgroundColor,
        child: Icon(iconData, color: iconColor,),
      ),
      const SizedBox(
        width: 8,
      ),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rightSideWidgets,
      ))
    ]);

    // Add tooltip if provided
    if (tooltipMessage != null) {
      return Flexible(child: Tooltip(
        richMessage: tooltipMessage,
        triggerMode: TooltipTriggerMode.tap,
        showDuration: const Duration(seconds: 30),
        child:  kpiRow,
      ));
    } else {
      return Flexible(child: kpiRow);
    }
  }
}
