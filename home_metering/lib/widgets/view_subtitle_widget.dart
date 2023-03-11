import 'package:flutter/material.dart';
import 'package:home_metering/utils/widgets.dart';

class ViewSubtitleWidget extends StatelessWidget {
  final String text;
  final Widget? filter;
  final double marginBottom;
  final double marginTop;

  const ViewSubtitleWidget(this.text, {this.filter, this.marginBottom = defaultMargin, this.marginTop = 0, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    var titleWidgets = <Widget>[Flexible(child: Text(text, style: theme.textTheme.titleMedium))];
    if (filter != null) {
      titleWidgets.addAll([
        const SizedBox(width: defaultMargin / 2),
        const Text("|"),
        const SizedBox(width: defaultMargin / 2),
        filter!,
      ]);
    }

    return Padding(
      padding: EdgeInsets.only(bottom: marginBottom, top: marginTop),
      child: Row(children: titleWidgets),
    );
  }
}
