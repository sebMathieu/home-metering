import 'dart:async';

import 'package:flutter_gen/gen_l10n/translations.dart';
import 'package:flutter/material.dart';
import 'package:home_metering/utils/time.dart';

const defaultViewPadding = 18.0;
const floatActionViewPadding = 45.0;
const defaultMargin = 14.0;

PopupMenuItem buildPopupMenuItemWithIcon<T>(BuildContext context, String label, IconData iconData, FutureOr<T> Function()? itemCallback) {
  return PopupMenuItem(
    onTap: () => Future.delayed(
      const Duration(seconds: 0),
      itemCallback,
    ),
    child:Row(children: <Widget>[
      SizedBox(
        width: 32,
        child: Icon(iconData),
      ),
      const SizedBox(width: 8),
      Flexible(child: Text(label, overflow: TextOverflow.ellipsis,)),
    ]),
  );
}

AppLocalizations getTranslator(BuildContext context) {
  return AppLocalizations.of(context)!;
}


String getFrequencyUnitTranslation(Frequency frequency, AppLocalizations translator) {
  switch (frequency) {
    case Frequency.yearly:
      return translator.year;
    case Frequency.monthly:
      return translator.month;
    case Frequency.daily:
      return translator.day;
    case Frequency.weekly:
      return translator.week;
    default:
      throw UnimplementedError("Get frequency unit translation $frequency");
  }
}

String getFrequencyTranslation(Frequency frequency, AppLocalizations translator) {
  switch (frequency) {
    case Frequency.yearly:
      return translator.yearly;
    case Frequency.monthly:
      return translator.monthly;
    case Frequency.daily:
      return translator.daily;
    case Frequency.weekly:
      return translator.weekly;
    default:
      throw UnimplementedError("Get frequency unit translation $frequency");
  }
}