import 'package:flutter/material.dart';
import 'package:home_metering/controller/meter_controller.dart';
import 'package:home_metering/controller/meter_reading_controller.dart';
import 'package:home_metering/utils/widgets.dart';
import 'package:home_metering/views/edit_meter_reading_view.dart';
import 'package:home_metering/views/edit_meter_view.dart';
import 'package:home_metering/views/home_page_view.dart';
import 'package:home_metering/views/meter_readings_view.dart';
import 'package:home_metering/widgets/error_display_widget.dart';
import 'package:home_metering/widgets/loading_widget.dart';
import 'package:home_metering/widgets/meter_analysis_widget.dart';
import 'package:home_metering/widgets/meter_icon_widget.dart';
import 'package:home_metering/widgets/no_meter_widget.dart';

import '../model/meter.dart';
import '../utils/dialogs.dart';


Future<List<Meter>> retrieveEmptyMeterList() async {
  return [];
}

class MeterView extends StatefulWidget {
  const MeterView({this.initialMeterId, super.key});

  final int? initialMeterId;

  @override
  State<MeterView> createState() => _MeterViewState();
}

class _MeterViewState extends State<MeterView>
    with SingleTickerProviderStateMixin {
  late Future<List<Meter>> _futureMeters;
  TabController? _tabController;
  Meter? currentMeter;

  void _navigateToAddMeter() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EditMeterView(),
      ),
    );
    _refreshMetersState();
  }

  void _navigateToEditCurrentMeter() async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditMeterView(initialMeter: currentMeter!),
      ),
    );
    _refreshMetersState();
  }

  void _navigateToCurrentMeterReadings() async {
    if (!mounted) return;
    _clearFetchedMeters(); // Force to empty the current meters state
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MeterReadingsView(currentMeter!),
      ),
    );
    _refreshMetersState();
  }

  void _editLastMeterReading() async {
    final meters = await _futureMeters;
    final lastMeterReading =
        await retrieveLastMeterReading(meterId: currentMeter!.id!);
    if (lastMeterReading == null) return;

    if (!mounted) return;
    _clearFetchedMeters(); // Force to empty the current meters state
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditMeterReadingView(meters,
            initialMeter: currentMeter, initialMeterReading: lastMeterReading),
      ),
    );
    _refreshMetersState();
  }

  void _clearNavigateHome() async {
    if (!mounted) return;

    await Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return const HomePageView();
    }));
    _refreshMetersState();
  }

  void _askToDeleteCurrentMeter() {
    showDeleteDialog(context, _deleteCurrentMeter);
  }

  void _deleteCurrentMeter() async {
    if (_tabController == null || currentMeter == null) return;
    await deleteMeter(currentMeter!.id!);

    // Update
    _refreshMetersState();
    currentMeter = null;
    if (_tabController!.length > 1) _tabController?.animateTo(0);
  }

  void _refreshMetersState() {
    setState(() {
      _futureMeters = retrieveMeters();
    });
  }

  void _clearFetchedMeters() {
    setState(() {
      _futureMeters = retrieveEmptyMeterList();
    });
  }

  void _navigateToAddMeterReadingOfCurrentMeter() async {
    final meters = await _futureMeters;
    _clearFetchedMeters(); // Force to empty the current meters state
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            EditMeterReadingView(meters, initialMeter: currentMeter!),
      ),
    );
    _refreshMetersState();
  }

  @override
  void initState() {
    super.initState();
    _futureMeters = retrieveMeters();
  }

  @override
  void didUpdateWidget(MeterView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _refreshMetersState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Meter>>(
        future: _futureMeters,
        builder: (BuildContext context, AsyncSnapshot<List<Meter>> snapshot) {
          if (snapshot.hasError) {
            return ErrorDisplayWidget(error: snapshot.error);
          } else if (!snapshot.hasData) {
            return const LoadingWidget();
          } else {
            final meters = snapshot.data!;
            if (meters.isEmpty) {
              return _buildNoMetersView(context);
            } else {
              return _buildMeterContentWidget(context, meters);
            }
          }
        });
  }

  Widget _buildMeterContentWidget(BuildContext context, List<Meter> meters) {
    // Controller initialization if needed
    if (_tabController == null) {
      // Initial index
      var meterTabIndex = 0;
      if (widget.initialMeterId != null) {
        for (var i = 0; i < meters.length; ++i) {
          if (meters[i].id == widget.initialMeterId) {
            meterTabIndex = i;
            break;
          }
        }
      }

      // Create tab controller and set metter
      currentMeter = meters[meterTabIndex];
      _tabController = TabController(
          vsync: this, length: meters.length, initialIndex: meterTabIndex);

      _tabController?.addListener(() {
        if (!_tabController!.indexIsChanging) {
          setState(() {
            currentMeter = meters[_tabController!.index];
          });
        }
      });
    }

    // Template
    final translator = getTranslator(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(translator.meters),
        bottom: TabBar(
            controller: _tabController,
            tabs: meters
                .map((meter) => Tab(
                      icon: MeterIconWidget(meter),
                      text: meter.name,
                    ))
                .toList()),
        actions: <Widget>[
          _buildContextMenu(this.context, _tabController?.index != null)
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _clearNavigateHome,
        ),
      ),
      body: currentMeter == null
          ? const LoadingWidget()
          : SingleChildScrollView(
              child: Padding(
                  padding:
                      const EdgeInsets.only(bottom: floatActionViewPadding),
                  child: MeterAnalysisWidget(currentMeter!))),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddMeterReadingOfCurrentMeter,
        tooltip: translator.encodeMeterReading,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContextMenu(BuildContext context, [isMeterSelected]) {
    final translator = getTranslator(context);
    return PopupMenuButton(itemBuilder: (context) {
      var menuItems = <PopupMenuEntry<void>>[];

      menuItems.add(buildPopupMenuItemWithIcon(
          context, translator.addMeter, Icons.add, _navigateToAddMeter));

      if (isMeterSelected == true) {
        menuItems.addAll([
          const PopupMenuDivider(),
          buildPopupMenuItemWithIcon(context, translator.editMeter, Icons.edit,
              _navigateToEditCurrentMeter),
          buildPopupMenuItemWithIcon(context, translator.deleteMeter,
              Icons.delete_forever, _askToDeleteCurrentMeter),
        ]);
      }

      if (isMeterSelected == true) {
        menuItems.addAll([
          const PopupMenuDivider(),
          buildPopupMenuItemWithIcon(context, translator.viewMeterReadings,
              Icons.playlist_add_check, _navigateToCurrentMeterReadings),
          buildPopupMenuItemWithIcon(context, translator.editLastMeterReading,
              Icons.edit_note, _editLastMeterReading),
          buildPopupMenuItemWithIcon(context, translator.encodeMeterReading,
              Icons.playlist_add, _navigateToAddMeterReadingOfCurrentMeter),
        ]);
      }
      return menuItems;
    });
  }

  Widget _buildNoMetersView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meters"),
        actions: <Widget>[
          _buildContextMenu(context, _tabController?.index != null)
        ],
      ),
      body: const NoMeterWidget(),
    );
  }
}
