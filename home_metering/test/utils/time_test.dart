import 'package:home_metering/utils/time.dart';
import 'package:test/test.dart';

void main() {
  test('get displayable date range with summer/winter hour change', () {
    final dateRange = getDisplayableDateRangeForFrequency(Frequency.daily,
        DateTime(
            2022,
            11,
            10,
            23,
            59,
            59,
            999));

    expect(dateRange.fromDateTime, DateTime(2022,10,26, 0, 0)); // Hours should be 0 !
    expect(dateRange.toDateTime, DateTime(2022,11,10,23,59, 59));
  });

  test('get displayable date range from end time at the beginning of the month', () {
    final dateRange = getDisplayableDateRangeForFrequency(Frequency.daily,
        DateTime(
            2022,
            10,
            2,
            23,
            59,
            59,
            999));

    expect(dateRange.toDateTime, DateTime(2022,10,2,23,59, 59));
    expect(dateRange.fromDateTime, DateTime(2022,10,2).add(const Duration(days: -15)));
  });
}