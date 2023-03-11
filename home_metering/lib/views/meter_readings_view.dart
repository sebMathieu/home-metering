import 'package:flutter/material.dart';
import 'package:home_metering/widgets/error_display_widget.dart';
import 'package:intl/intl.dart';

import 'package:home_metering/controller/meter_controller.dart';
import 'package:home_metering/controller/meter_reading_controller.dart';
import 'package:home_metering/model/meter.dart';
import 'package:home_metering/model/meter_reading.dart';
import 'package:home_metering/utils/metering.dart';
import 'package:home_metering/utils/widgets.dart';
import 'package:home_metering/utils/dialogs.dart';
import 'package:home_metering/views/edit_meter_reading_view.dart';
import 'package:home_metering/widgets/loading_widget.dart';
import 'package:home_metering/widgets/no_meter_readings_widget.dart';

class MeterReadingsView extends StatefulWidget {
  const MeterReadingsView(this.meter, {super.key});

  final Meter meter;

  @override
  State<MeterReadingsView> createState() => _MeterReadingsViewState();
}

class _MeterReadingsViewState extends State<MeterReadingsView>
    with SingleTickerProviderStateMixin {
  late Future<List<MeterReading>> _futureMeterReadings;

  void _refreshMeterReadings() async {
    _futureMeterReadings = retrieveMeterReadings(meterId: widget.meter.id!);
  }

  void _refreshMeterReadingsState() async {
    setState(() {
      _refreshMeterReadings();
    });
  }

  void _navigateToEditMeterReading([MeterReading? meterReading]) async {
    final meters = await retrieveMeters();

    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditMeterReadingView(
          meters,
          initialMeter: widget.meter,
          initialMeterReading: meterReading,
        ),
      ),
    );
    _refreshMeterReadingsState();
  }

  void _askToDeleteMeterReading(MeterReading meterReading) {
    showDeleteDialog(context, () => _deleteMeterReading(meterReading));
  }

  void _deleteMeterReading(MeterReading meterReading) async {
    await deleteMeterReading(meterReading);
    _refreshMeterReadingsState();
  }

  void _exportMeterReadingsAsCSV() async {
    final meterReadings = await _futureMeterReadings;
    final stringCSV =
        buildCSVStringFromMeterReadings(meterReadings, [widget.meter]);
    await showCSVExportDialog("${widget.meter.name}-readings", stringCSV);
  }

  void _importMeterReadingsFromCSV(BuildContext context) async {
    final isImportDone =
        await importMeterReadingFromCSVImportDialog(context, preferredMeter: widget.meter);

    // Update future
    if (isImportDone) {
      setState(() {
        _refreshMeterReadings();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshMeterReadings();
  }

  @override
  void didUpdateWidget(MeterReadingsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _refreshMeterReadings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final translator = getTranslator(context);
    return FutureBuilder<List<MeterReading>>(
        future: _futureMeterReadings,
        builder:
            (BuildContext context, AsyncSnapshot<List<MeterReading>> snapshot) {
          if (snapshot.hasError) {
            return ErrorDisplayWidget(error: snapshot.error);
          } else if (!snapshot.hasData) {
            return const LoadingWidget();
          } else {
            final meterReadings = snapshot.data!;
            if (meterReadings.isEmpty) {
              return Scaffold(
                  appBar: AppBar(
                    title: Text("${widget.meter.name} - ${translator.meterReadings}"),
                  ),
                  body: NoMeterReadingsWidget(widget.meter));
            } else {
              return _buildMeterContentWidget(context, meterReadings);
            }
          }
        });
  }

  Widget _buildMeterContentWidget(
      BuildContext context, List<MeterReading> meterReadings) {
    final translator = getTranslator(context);
    final title = "${widget.meter.name} - ${translator.meterReadings}";
    // Template
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          _buildContextMenu(context),
        ],
      ),
      body: Scrollbar(
        child: Padding(
            padding: const EdgeInsets.only(bottom: floatActionViewPadding),
            // Leave space for quick action button
            child: ListView(
              restorationId: title,
              padding:
                  const EdgeInsets.symmetric(vertical: defaultViewPadding),
              children: meterReadings.reversed
                  .map((meterReading) =>
                      _buildMeterReadingListTile(context, meterReading))
                  .toList(),
            )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToEditMeterReading,
        tooltip: translator.encodeMeterReading,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMeterReadingListTile(
      BuildContext context, MeterReading meterReading) {
    final translator = getTranslator(context);
    DateFormat dateFormatter = DateFormat.yMd();
    return ListTile(
      leading: ExcludeSemantics(
        child: CircleAvatar(
            child: Icon(meterReading.isReset
                ? Icons.restart_alt
                : Icons.chevron_right)),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(dateFormatter.format(meterReading.dateTime)),
          const SizedBox(width: 18),
          Expanded(
              child: Text(
            '${meterReading.value} ${widget.meter.unit}',
            textAlign: TextAlign.left,
            style: const TextStyle(fontWeight: FontWeight.bold),
          )),
          PopupMenuButton(itemBuilder: (context) {
            return [
              buildPopupMenuItemWithIcon(context, translator.editMeterReading,
                  Icons.edit, () => _navigateToEditMeterReading(meterReading)),
              buildPopupMenuItemWithIcon(
                  context,
                  translator.deleteMeterReading,
                  Icons.delete_forever,
                  () => _askToDeleteMeterReading(meterReading))
            ];
          }),
        ],
      ),
    );
  }

  Widget _buildContextMenu(BuildContext context) {
    final translator = getTranslator(context);
    return PopupMenuButton(itemBuilder: (context) {
      return <PopupMenuEntry<void>>[
        buildPopupMenuItemWithIcon(context, translator.encodeMeterReading, Icons.add,
            _navigateToEditMeterReading),
        const PopupMenuDivider(),
        buildPopupMenuItemWithIcon(context, translator.importFromCSV, Icons.upload,
            () => _importMeterReadingsFromCSV(context)),
        buildPopupMenuItemWithIcon(context, translator.exportAsCSV, Icons.download,
            _exportMeterReadingsAsCSV),
        const PopupMenuDivider(),
        buildPopupMenuItemWithIcon(context, translator.exportReadingsFromAllMeterAsCSV,
            Icons.sim_card_download, showAllMeterReadingsCSVExportDialog),
      ];
    });
  }
}
