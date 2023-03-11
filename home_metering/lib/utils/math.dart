num computeAverage(Iterable<num> numbers) {
  if (numbers.isEmpty) return 0;
  return numbers.reduce((a, b) => a + b) / numbers.length;
}


num computeMedian(Iterable<num> numbers) {
  // Sort
  final sortedList = numbers.toList();
  sortedList.sort();

  // Take the middle
  final middleIndex = sortedList.length ~/ 2;
  num median = sortedList[middleIndex];
  if (sortedList.length.isEven) {
    median = (sortedList[middleIndex - 1] + median) / 2.0;
  }
  return median;
}
