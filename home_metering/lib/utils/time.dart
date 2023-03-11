import 'package:intl/intl.dart';

class DateRange {
  DateTime fromDateTime;
  DateTime toDateTime;

  DateRange(this.fromDateTime, this.toDateTime);

  bool isIncluding(DateTime t) {
    return t==fromDateTime || t==toDateTime || (fromDateTime.isBefore(t) && toDateTime.isAfter(t));
  }
}

enum Frequency {
  daily,
  weekly,
  monthly,
  yearly,
}

DateTime floorDateTime(DateTime dateTime, Frequency frequency) {
  switch (frequency) {
    case Frequency.yearly:
      return DateTime(dateTime.year);
    case Frequency.monthly:
      return DateTime(dateTime.year, dateTime.month);
    case Frequency.daily:
      return DateTime(dateTime.year, dateTime.month, dateTime.day);
    case Frequency.weekly:
      return DateTime(dateTime.year, dateTime.month, dateTime.day - (dateTime.weekday - 1));
    default:
      throw UnimplementedError("Floor date time at frequency $frequency");
  }
}

DateTime ceilDateTime(DateTime dateTime, Frequency frequency) {
  // Check lower bound
  final flooredDateTime = floorDateTime(dateTime, frequency);
  if (flooredDateTime == dateTime) {
    return flooredDateTime;
  }

  // Go to the next tick
  switch (frequency) {
    case Frequency.yearly:
      return DateTime(dateTime.year + 1);
    case Frequency.monthly:
      return DateTime(dateTime.year, dateTime.month + 1);
    case Frequency.daily:
      return DateTime(dateTime.year, dateTime.month, dateTime.day + 1);
    case Frequency.weekly:
      return DateTime(dateTime.year, dateTime.month, dateTime.day + (8 - dateTime.weekday));
    default:
      throw UnimplementedError("Ceil date time at frequency $frequency");
  }
}

DateTime getNextDateTime(DateTime date, Frequency frequency) {
  switch (frequency) {
    case Frequency.yearly:
      return DateTime(date.year + 1);
    case Frequency.monthly:
      return DateTime(date.year, date.month + 1);
    case Frequency.daily:
      return DateTime(date.year, date.month, date.day + 1); // Do not use duration 1 day which is not reliable with winter hours
    case Frequency.weekly:
      return DateTime(date.year, date.month, date.day + (8 - date.weekday));
    default:
      throw UnimplementedError("Get next date time at frequency $frequency");
  }
}

DateFormat getShortAxisDateFormat(Frequency frequency) {
  switch (frequency) {
    case Frequency.yearly:
      return DateFormat(DateFormat.YEAR);
    case Frequency.monthly:
      return DateFormat(DateFormat.YEAR_NUM_MONTH);
    case Frequency.weekly:
    case Frequency.daily:
      return DateFormat(DateFormat.NUM_MONTH_DAY);
    default:
      throw UnimplementedError("Get next date time at frequency $frequency");
  }
}


Iterable<DateTime> getDateTimeIteratorInRange(DateRange dateRange, Frequency frequency) sync* {
  final roundedStartDateTime = floorDateTime(dateRange.fromDateTime, frequency);
  final roundedEndDateTime = ceilDateTime(dateRange.toDateTime, frequency);

  // Build buckets
  DateTime dateIterator = roundedStartDateTime;
  while (dateIterator == roundedStartDateTime || dateIterator.isBefore(roundedEndDateTime)) {
    yield dateIterator;
    dateIterator = getNextDateTime(dateIterator, frequency);
  }
}

DateRange getDisplayableDateRangeForFrequency(Frequency frequency, DateTime? endDateTime) {
  endDateTime ??= DateTime.now();

  switch (frequency) {
    case Frequency.yearly:
      return DateRange(DateTime(endDateTime.year-9), DateTime(endDateTime.year, 12, 31, 23, 59, 59));
    case Frequency.monthly:
      return DateRange(DateTime(endDateTime.year), DateTime(endDateTime.year, 12, 31, 23, 59, 59));
    case Frequency.daily:
      // Do not use duration that are not reliable
      return DateRange(DateTime(endDateTime.year, endDateTime.month, endDateTime.day - 15), DateTime(endDateTime.year, endDateTime.month, endDateTime.day, 23, 59, 59));
    case Frequency.weekly:
      return DateRange(DateTime(endDateTime.year, endDateTime.month - 2), DateTime(endDateTime.year, endDateTime.month + 1).add(const Duration(seconds: -1)));
    default:
      throw UnimplementedError("Get next date time at frequency $frequency");
  }
}

int daysSince(DateTime dateTime, {DateTime? reference}) {
  return (reference ?? DateTime.now()).difference(dateTime)
      .inDays;
}
