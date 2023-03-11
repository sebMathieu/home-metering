import 'package:flutter/material.dart';
import 'package:home_metering/controller/meter_controller.dart';
import 'package:home_metering/controller/meter_reading_controller.dart';
import 'package:home_metering/utils/dialogs.dart';
import 'package:home_metering/utils/metering.dart';
import 'package:home_metering/utils/widgets.dart';
import 'package:home_metering/views/edit_meter_reading_view.dart';
import 'package:home_metering/views/edit_meter_view.dart';
import 'package:home_metering/views/meter_view.dart';
import 'package:home_metering/views/settings_view.dart';
import 'package:home_metering/widgets/all_meters_analysis_widget.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  void _navigateToMeterView() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MeterView(),
      ),
    );
  }

  void _navigateToAddMeter() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EditMeterView(),
      ),
    );
    setState(() {});
  }

  void _navigateToAddMeterReading() async {
    final meters = await retrieveMeters();

    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditMeterReadingView(meters),
      ),
    );
    setState(() {});
  }

  void _navigateToSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsView(),
      ),
    );
  }

  void _importMeterReadingsFromCSV(BuildContext context) async {
    final isImportDone =
    await importMeterReadingFromCSVImportDialog(context);

    // Update future
    if (isImportDone) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final translator = getTranslator(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home metering"),
        actions: <Widget>[_buildContextMenu(context)],
        leading: const Icon(Icons.home),
      ),
      body: const SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.only(bottom: floatActionViewPadding),
              child: AllMetersAnalysisWidget())),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddMeterReading,
        tooltip: translator.encodeMeterReading,
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _buildContextMenu(BuildContext context) {
    final translator = getTranslator(context);
    return PopupMenuButton(itemBuilder: (context) {
      var menuItems = <PopupMenuEntry<void>>[];

      menuItems.addAll([
        buildPopupMenuItemWithIcon(
            context, translator.settings, Icons.settings, _navigateToSettings),
        const PopupMenuDivider(),
        buildPopupMenuItemWithIcon(
            context, translator.meters, Icons.electric_meter, _navigateToMeterView),
        buildPopupMenuItemWithIcon(context, translator.addMeter,
            Icons.add, _navigateToAddMeter),
        const PopupMenuDivider(),
        buildPopupMenuItemWithIcon(context, translator.encodeMeterReading,
            Icons.playlist_add, _navigateToAddMeterReading),
        buildPopupMenuItemWithIcon(context, translator.importFromCSV, Icons.upload_file, () =>_importMeterReadingsFromCSV(context)),
        buildPopupMenuItemWithIcon(context, translator.exportReadingsFromAllMeterAsCSV,
            Icons.sim_card_download, showAllMeterReadingsCSVExportDialog),
      ]);

      return menuItems;
    });
  }
}
