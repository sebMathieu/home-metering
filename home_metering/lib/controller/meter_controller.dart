import 'package:home_metering/controller/database_singleton.dart';
import 'package:home_metering/controller/meter_reading_controller.dart';
import 'package:home_metering/model/meter.dart';
import 'package:sqflite/sqflite.dart';

const meterTableName = 'meters';

Future<Meter> registerMeter(Meter meter) async {
  var db = getDatabase();

  var meterId = await db.insert(
    meterTableName,
    convertMeterToMap(meter, true),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  return await retrieveMeterById(meterId);
}

Future<Meter> retrieveMeterById(int meterId) async {
  var db = getDatabase();

  final List<Map<String, dynamic>> meterMaps =
      await db.query(meterTableName, where: 'id = ?', whereArgs: [meterId]);

  Meter meter = convertMapToMeter(meterMaps[0]);
  return meter;
}

Future<List<Meter>> retrieveMeters() async {
  var db = getDatabase();

  final List<Map<String, dynamic>> meterMaps =
      await db.query(meterTableName, orderBy: "name");

  final meters = meterMaps.map(convertMapToMeter).toList();
  return meters;
}

Future<void> deleteMeter(int meterId) async {
  var db = getDatabase();

  await db.delete(meterReadingTableName,
      where: 'meterId = ?', whereArgs: [meterId]);
  await db.delete(meterTableName, where: 'id = ?', whereArgs: [meterId]);
}

Future<Meter> updateMeter(Meter meter) async {
  var db = getDatabase();

  var meterId = await db.update(
    meterTableName,
    convertMeterToMap(meter, true),
    conflictAlgorithm: ConflictAlgorithm.replace,
    where: 'id = ?',
    whereArgs: [meter.id],
  );

  return await retrieveMeterById(meterId);
}

// Convert instance into a Map ready to be inserted in the database.
// The keys must correspond to the names of the columns in the database.
Map<String, dynamic> convertMeterToMap(Meter meter, [bool? isSkipId]) {
  var m = {
    'name': meter.name,
    'unit': meter.unit,
    'unitCost': meter.unitCost,
    'isDecreasing': meter.isDecreasing ? 1 : 0,
    'decimals': meter.decimals,
    'serialNumber': meter.serialNumber,
    'description': meter.description,
    'color': meter.color,
  };

  if (isSkipId != true && meter.id != null) {
    m['id'] = meter.id!;
  }

  return m;
}

Meter convertMapToMeter(Map<String, dynamic> m) {
  return Meter(
    id: m['id'],
    name: m['name'],
    unit: m['unit'],
    unitCost: m['unitCost'],
    isDecreasing: m['isDecreasing'] > 0,
    decimals: m['decimals'],
    serialNumber: m['description'],
    description: m['description'],
    color: m['color'],
  );
}

Meter copyMeter(Meter meter) {
  return convertMapToMeter(convertMeterToMap(meter));
}
