import 'package:home_metering/controller/meter_controller.dart';
import 'package:home_metering/controller/meter_reading_controller.dart';
import 'package:home_metering/controller/settings_controller.dart';
import 'package:sqflite/sqflite.dart';

void upgrade20230205(Batch batch) {
  batch.execute(
    'CREATE TABLE $meterTableName(id INTEGER PRIMARY KEY, name TEXT NOT NULL, unit Text, unitCost REAL, color INTEGER, isDecreasing INTEGER, digits INTEGER, decimals INTEGER, serialNumber TEXT, description TEXT)',
  );
  batch.execute(
    'CREATE TABLE $meterReadingTableName(meterId INTEGER, timestamp INTEGER, value REAL NOT NULL, isReset INTEGER NOT NULL DEFAULT 0, PRIMARY KEY (meterId, timestamp))',
  ); // Foreign key constraint is missing
  batch.execute(
    'CREATE TABLE $settingsTableName(name TEXT PRIMARY KEY, value Text)',
  );
}