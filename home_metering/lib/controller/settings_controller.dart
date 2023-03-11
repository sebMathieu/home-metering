import 'dart:io';

import 'package:home_metering/controller/database_singleton.dart';
import 'package:home_metering/model/settings.dart';
import 'package:home_metering/utils/time.dart';
import 'package:sqflite/sqflite.dart';

const settingsTableName = 'settings';

Settings? _settingsCache;
Frequency globalFrequency = Frequency.monthly;

Settings getSettings() {
  if (_settingsCache == null) {
    throw StateError("Settings has not been loaded");
  }
  return _settingsCache!;
}

Future<Settings> initializeSettings() async {
  // Prepare a settings object with default values
  var settings = Settings();

  // Retrieve existing records from database
  var db = getDatabase();
  final List<Map<String, dynamic>> settingsMap = await db.query(settingsTableName);

  for (final settingRecord in settingsMap) {
    String settingRecordName = settingRecord["name"];
    String rawSettingRecordValue = settingRecord["value"];

    // Deserialize setting
    switch (settingRecordName) {
      case "defaultFrequency":
        try {
          settings.defaultFrequency =
              Frequency.values.byName(rawSettingRecordValue);
        } catch (e) {
          stderr.writeln("Unknown default frequency: \"$rawSettingRecordValue\"");
        }
        break;
      case "currencyUnit":
        settings.currencyUnit = rawSettingRecordValue;
        break;
      default:
        throw Exception("Unknown setting record name \"$settingRecordName\".");
    }
  }

  return _updateSettingsCache(settings);
}

Future<Settings> updateSettings(Settings newSettings) async {
  // Serialize settings
  var serializedSettings = [
    {
      "name": "defaultFrequency",
      "value": newSettings.defaultFrequency.name,
    },
    {
      "name": "currencyUnit",
      "value": newSettings.currencyUnit,
    }
  ];

  // Update database
  var db = getDatabase();
  var batch = db.batch();
  for (final serializedSetting in serializedSettings) {
    batch.insert(settingsTableName, serializedSetting, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  await batch.commit();

  // Set update
  return _updateSettingsCache(newSettings);
}

Settings _updateSettingsCache(Settings newSettings) {
  _settingsCache = newSettings;
  globalFrequency = newSettings.defaultFrequency;
  return newSettings;
}
