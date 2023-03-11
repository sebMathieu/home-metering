import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/translations.dart';


String? validateRequired(String? value, AppLocalizations translator) {
  if (value == null || value.trim().isEmpty) {
    return translator.required;
  }
  return null;
}

String? validateDynamicRequired(dynamic value, AppLocalizations translator) {
  if (value == null) {
    return translator.required;
  }
  return null;
}

String? validateFloat(String? value, AppLocalizations translator) {
  if (value == null) { return null; }
  else {
    final parsed = num.tryParse(value);
    if (parsed == null) {
      return translator.invalidNumber;
    } else {
      return null;
    }
  }
}

String? validatePositiveInteger(String? value, AppLocalizations translator) {
  if (value == null) { return null; }
  else {
    final parsed = int.tryParse(value);
    if (parsed == null) {
      return translator.invalidNumber;
    } else if (parsed < 0) {
      return translator.valueMustBePositive;
    } else {
      return null;
    }
  }
}

String? validateDateTime(String? value, AppLocalizations translator, {DateFormat? formatter}) {
  if (value == null) { return null; }
  else {
      try {
        if (formatter != null) {
          formatter.parseLoose(value);
        } else {
          DateTime.parse(value);
        }
        return null;
      } on FormatException {
        return translator.invalidTimeOfDay;
      }
  }
}

String? _applyValidationChain(String? value, List<Function(String?, AppLocalizations)> validators, AppLocalizations translator) {
  for (final validator in validators) {
    final validationResult = validator(value, translator);
    if (validationResult != null) return validationResult;
  }
  return null;
}


String? validateRequiredFloat(String? value, AppLocalizations translator) {
  return _applyValidationChain(value, [validateRequired, validateFloat], translator);
}

String? validateRequiredPositiveInteger(String? value, AppLocalizations translator) {
  return _applyValidationChain(value, [validateRequired, validatePositiveInteger], translator);
}

String? validateRequiredDateTime(String? value, AppLocalizations translator, {DateFormat? formatter}) {
  String? validationResult = validateRequired(value, translator);
  if (validationResult != null) return validationResult;
  return validateDateTime(value, translator, formatter: formatter);
}