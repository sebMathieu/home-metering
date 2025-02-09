import 'package:home_metering/controller/meter_controller.dart';
import 'package:sqflite/sqflite.dart';

void upgrade20250208(Batch batch) {
  batch.execute('ALTER TABLE $meterTableName ADD COLUMN monitoringIndexThreshold FLOAT NULL');
}