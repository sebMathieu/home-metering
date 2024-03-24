import 'dart:math';

num computeAverage(Iterable<num> numbers) {
  if (numbers.isEmpty) return 0;
  return numbers.reduce((a, b) => a + b) / numbers.length;
}


num computeMedian(Iterable<num> numbers) {
  return computePercentile(numbers, 50);
}


num computePercentile(Iterable<num> numbers, num percentile) {
  // Sort
  final sortedList = numbers.toList();
  sortedList.sort();

  // Take the middle
  final index = max(0, min(
      (sortedList.length * (percentile / 100)).round(),
      sortedList.length - 1
  ));
  return sortedList[index];
}