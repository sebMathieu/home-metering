import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:home_metering/controller/migrations/migration_2023_02_05_db_setup.dart';
import 'package:home_metering/controller/migrations/migration_2025_02_08_meter_limit.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Database? _database;

Future<void> initializeDatabase() async {
  // Ensure everything is fine
  WidgetsFlutterBinding.ensureInitialized();

  // Database path
  String databaseContainerFolder = await getDatabasesPath();
  if (kDebugMode) {
    // Protection for the following line that should not be run in production
    //databaseFactory.deleteDatabase(join(databaseContainerFolder, 'home-metering.db')); // Remove old database
  }

  // Get the database connection
  _database = await openDatabase(
    join(databaseContainerFolder, 'home-metering.db'),
    version: 20250208,
    onCreate: (db, version) async {
      var batch = db.batch();
      upgrade20230205(batch);
      await batch.commit();
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      var batch = db.batch();

      // Register useful migrations
      if (oldVersion < 20230205) {
        upgrade20230205(batch);
      }
      if (oldVersion < 20250208) {
        upgrade20250208(batch);
      }

      // Execute the migrations
      await batch.commit();
    },
  );
}

Database getDatabase() {
  if (_database == null) {
    throw StateError("Database not loaded");
  }
  return _database!;
}
