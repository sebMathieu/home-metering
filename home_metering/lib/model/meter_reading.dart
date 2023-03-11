class MeterReading {
  int meterId;
  DateTime dateTime;
  num value;
  bool isReset;

  MeterReading({
    required this.meterId,
    required this.dateTime,
    required this.value,
    this.isReset = false,
  });
}
