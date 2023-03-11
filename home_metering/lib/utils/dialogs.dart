import 'dart:convert';
import 'dart:typed_data';

import 'package:home_metering/controller/meter_controller.dart';
import 'package:home_metering/utils/widgets.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:home_metering/controller/meter_reading_controller.dart';
import 'package:home_metering/model/meter.dart';
import 'package:home_metering/utils/metering.dart';

void showDeleteDialog(BuildContext context, Function confirmAction, [String? textContent, String? textTitle]) {
  final translator = getTranslator(context);
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(textTitle ?? translator.delete),
      content: Text(textContent ?? translator.deleteConfirmation),
      actions: <Widget>[
        OutlinedButton.icon(
          label: Text(translator.delete),
          icon: const Icon(Icons.delete_forever),
          onPressed: () {
            confirmAction();
            return Navigator.pop(context, 'OK');
          },
        ),
        ElevatedButton.icon(
          label: Text(translator.cancel),
          icon: const Icon(Icons.cancel),
          onPressed: () => Navigator.pop(context, 'Cancel'),
        ),
      ],
    ),
  );
}

Future<bool> importMeterReadingFromCSVImportDialog(BuildContext context, {Meter? preferredMeter}) async {
  final translator = getTranslator(context);
  final result = await FilePicker.platform.pickFiles(
    allowMultiple: false,
    type: FileType.custom,
    allowedExtensions: ["csv"],
    withData: true,
  );

  // if no file is picked
  if (result == null) return false;

  // Parse file
  final file = result.files.first;
  final fileContent = utf8.decode(file.bytes!.toList());
  final meters = await retrieveMeters();

  final newMeterReadings = parseMeterReadingsFromCSVString(fileContent, preferredMeter: preferredMeter, meters: meters);

  // Register meter reading
  for (final meterReading in newMeterReadings) {
    await registerMeterReading(meterReading);
  }

  // Display help if no meter readings imported
  if (newMeterReadings.isEmpty) {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(translator.noMeterReadingsImported),
        content: Text("${translator.csvParsingDescription}\n\n    ${getCSVStringFormats().join("\n    ")}"),
        actions: <Widget>[
          ElevatedButton.icon(
            label: Text(translator.close),
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context, 'Cancel'),
          ),
        ],
      ),
    );
  }

  return newMeterReadings.isNotEmpty;
}


Future<void> showCSVExportDialog(String fileContent, String fileName) async {
  final filePath = "${Uri.encodeComponent(fileName)}.csv";
  final textBytes = Uint8List.fromList(utf8.encode(fileContent));
  try {
    await Share.shareXFiles([XFile.fromData(
      textBytes,
      name: fileName,
      path: filePath,
      mimeType: "text/csv",
    )
    ], subject: filePath);
  } catch (e) {
    // Fallback strategy since the previous do not properly work with some Android versions (2023-01-22)
    Share.share(fileContent, subject: filePath);
  }
}

Future<void> showAllMeterReadingsCSVExportDialog() async {
  final meters = await retrieveMeters();
  final meterReadings = await retrieveMeterReadings();
  final stringCSV = buildCSVStringFromMeterReadings(meterReadings, meters);

  final now = DateTime.now();
  final f = NumberFormat("00");
  await showCSVExportDialog(stringCSV, "home-metering-readings-${now.year}-${f.format(now.month)}-${f.format(now.day)}");
}