import 'package:flutter/material.dart';
import 'package:home_metering/controller/meter_controller.dart';
import 'package:home_metering/utils/dialogs.dart';
import 'package:home_metering/utils/widgets.dart';
import 'package:home_metering/views/edit_meter_reading_view.dart';

import '../model/meter.dart';

class NoMeterReadingsWidget extends StatelessWidget {
  final Meter meter;

  const NoMeterReadingsWidget(this.meter, {super.key});

  void _navigateToAddMeterReading(BuildContext context) async {
    final navigator = Navigator.of(context);
    final meters = await retrieveMeters();
    await navigator.push(
      MaterialPageRoute(
        builder: (context) => EditMeterReadingView(meters, initialMeter: meter),
      ),
    );
  }

  void _importMeterReadingsFromCSV(BuildContext context) async {
    final navigator = Navigator.of(context);
    final isImportDone =
        await importMeterReadingFromCSVImportDialog(context, preferredMeter: meter);
    if (isImportDone) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final translator = getTranslator(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
              width: 300,
              child: Text(
                translator.noMeterReadingAssistance,
                textAlign: TextAlign.center,
              )),
          const SizedBox(height: defaultMargin),
          Padding(
              padding: const EdgeInsets.all(defaultMargin),
              child: Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.center,
                spacing: defaultMargin,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(translator.encodeMeterReading),
                    onPressed: () => _navigateToAddMeterReading(context),
                  ),
                  const SizedBox(width: defaultMargin),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(translator.importFromCSV),
                    onPressed: () => _importMeterReadingsFromCSV(context),
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
