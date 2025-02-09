import 'dart:math';

List<num> filterNulls(Iterable<num?> numbers) {
  return numbers.whereType<num>().toList();
}

num? computeAverage(Iterable<num?> numbers) {
  final nonNulls = filterNulls(numbers);
  if (nonNulls.isEmpty) return null;
  return nonNulls.reduce((a, b) => a + b) / nonNulls.length;
}


num? computeMedian(Iterable<num?> numbers) {
  return computePercentile(numbers, 50);
}


num? computePercentile(Iterable<num?> numbers, num percentile) {
  // Sort
  final sortedList = filterNulls(numbers).toList();
  if (sortedList.isEmpty) return null;
  sortedList.sort();

  // Take the middle
  final index = max(0, min(
      (sortedList.length * (percentile / 100)).round(),
      sortedList.length - 1
  ));
  return sortedList[index];
}