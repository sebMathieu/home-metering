import 'package:home_metering/controller/database_singleton.dart';
import 'package:home_metering/model/meter_reading.dart';
import 'package:home_metering/utils/time.dart';
import 'package:sqflite/sqflite.dart';

const meterReadingTableName = 'meter_readings';
int _meterReadingsStateTimeStamp = DateTime.now().millisecondsSinceEpoch;

int getMeterReadingsState() {
  return _meterReadingsStateTimeStamp;
}

int changeMeterReadingsState() {
  _meterReadingsStateTimeStamp = DateTime.now().millisecondsSinceEpoch;
  return _meterReadingsStateTimeStamp;
}

Future<MeterReading> registerMeterReading(MeterReading meterReading) async {
  if (meterReading.meterId == 0) throw "Invalid meter id: ${meterReading.meterId}";

  var db = getDatabase();

  await db.insert(
    meterReadingTableName,
    convertMeterReadingToMap(meterReading),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  changeMeterReadingsState();

  return meterReading;
}

Future<List<MeterReading>> retrieveMeterReadings({int? meterId, DateTime? fromDateTime, DateTime? toDateTime, DateRange? dateRange, isFirstsOutOfBoundReadingIncluded = false}) async {
  var db = getDatabase();

  // Min & max date time
  DateTime? minDateTime = fromDateTime ?? dateRange?.fromDateTime;
  if (minDateTime != null && isFirstsOutOfBoundReadingIncluded) {
    if (meterId == null) throw "Multiple meter is not compatible yet with isFirstsOutOfBoundReadingIncluded";
    final firstMinTimestampResult = await db.rawQuery("SELECT MAX(timestamp) as tMax FROM $meterReadingTableName WHERE timestamp < ? AND meterId = ?", [minDateTime.millisecondsSinceEpoch, meterId]);
    int? firstMinTimestamp = firstMinTimestampResult[0]['tMax'] as int?;
    minDateTime = firstMinTimestamp == null ? null : DateTime.fromMillisecondsSinceEpoch(firstMinTimestamp);
  }

  DateTime? maxDateTime = toDateTime ?? dateRange?.toDateTime;
  if (maxDateTime != null && isFirstsOutOfBoundReadingIncluded) {
    if (meterId == null) throw "Multiple meter is not compatible yet with isFirstsOutOfBoundReadingIncluded";
    final firstMaxTimestampResult = await db.rawQuery("SELECT MIN(timestamp) as tMin FROM $meterReadingTableName WHERE timestamp > ? AND meterId = ?", [maxDateTime.millisecondsSinceEpoch, meterId]);
    int? firstMaxTimestamp = firstMaxTimestampResult[0]['tMin'] as int?;
    maxDateTime = firstMaxTimestamp == null ? null : DateTime.fromMillisecondsSinceEpoch(firstMaxTimestamp);
  }

  // Build query parameters
  var whereClauses = [];
  var whereArgs = [];

  if (meterId != null) {
    whereClauses.add('meterId = ?');
    whereArgs.add(meterId);
  }

  if (minDateTime != null) {
    whereClauses.add("timestamp >= ?");
    whereArgs.add(minDateTime.millisecondsSinceEpoch); // Add margin
  }
  if (maxDateTime != null) {
    whereClauses.add("timestamp <= ?");
    whereArgs.add(maxDateTime.millisecondsSinceEpoch); // Add margin
  }

  final List<Map<String, dynamic>> meterReadingMaps = await db.query(
      meterReadingTableName,
      where: whereClauses.isEmpty ? null : whereClauses.join(" and "),
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'timestamp',
  );

  final meterReadings = meterReadingMaps.map(convertMapToMeterReading).toList();
  return meterReadings;
}

Future<MeterReading?> retrieveLastMeterReading({int? meterId}) async {
  var db = getDatabase();

  final List<Map<String, dynamic>> queryResult = await db.rawQuery(
    "SELECT * FROM $meterReadingTableName WHERE ${meterId == null ? "" : "meterId = ? AND "}timestamp = (SELECT MAX(timestamp) as tMax FROM $meterReadingTableName${meterId == null ? "" : " WHERE meterId = ?"});",
    meterId == null ? null : [meterId, meterId]
  );

  if (queryResult.isEmpty) {
    return null;
  }
  else {
    return convertMapToMeterReading(queryResult[0]);
  }
}

Future<void> deleteMeterReading(MeterReading meterReading) async {
  var db = getDatabase();

  await db.delete(meterReadingTableName, where: 'meterId = ? AND timestamp = ?', whereArgs: [meterReading.meterId, meterReading.dateTime.millisecondsSinceEpoch]);
  changeMeterReadingsState();
}

Future<MeterReading> updateMeterReading(MeterReading meterReading, DateTime previousDateTime) async {
  var db = getDatabase();

  var response = await db.update(
    meterReadingTableName,
    convertMeterReadingToMap(meterReading),
    conflictAlgorithm: ConflictAlgorithm.replace,
    where: 'meterId = ? AND timestamp = ?', whereArgs: [meterReading.meterId, previousDateTime.millisecondsSinceEpoch]
  );

  changeMeterReadingsState();
  return meterReading;
}

// Convert instance into a Map ready to be inserted in the database.
// The keys must correspond to the names of the columns in the database.
Map<String, dynamic> convertMeterReadingToMap(MeterReading meterReading) {
  var m = {
    'meterId': meterReading.meterId,
    'timestamp': meterReading.dateTime.millisecondsSinceEpoch,
    'value': meterReading.value,
    'isReset': meterReading.isReset == true ? 1 : 0,
  };

  return m;
}

MeterReading convertMapToMeterReading(Map<String, dynamic> m) {
  return MeterReading(
    meterId: m['meterId'],
    dateTime: DateTime.fromMillisecondsSinceEpoch(m['timestamp']),
    value: m['value'],
    isReset: m['isReset'] == 1
  );
}

MeterReading copyMeterReading(MeterReading meterReading) {
  return convertMapToMeterReading(convertMeterReadingToMap(meterReading));
}
