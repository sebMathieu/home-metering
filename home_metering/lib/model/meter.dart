import 'dart:ui';

const defaultMeterColor = Color(0xff212121);

enum MeterType {
  electricity,
  water,
  heating,
}

class Meter {
  int? id;
  String name;
  String unit;
  num unitCost;
  int decimals;
  bool isDecreasing;
  MeterType? type;
  String? serialNumber;
  String? description;
  int? color;
  num? monitoringIndexThreshold;

  Meter({
    this.id,
    required this.name,
    required this.unit,
    required this.unitCost,
    this.decimals = 0,
    this.type,
    this.serialNumber,
    this.description,
    this.isDecreasing = false,
    this.color,
    this.monitoringIndexThreshold,
  });

  Color getColorObject() {
    return color == null ? defaultMeterColor: Color(color!);
  }
}
