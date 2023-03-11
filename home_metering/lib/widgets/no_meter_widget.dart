import 'package:flutter/material.dart';
import 'package:home_metering/utils/widgets.dart';
import 'package:home_metering/views/edit_meter_view.dart';

class NoMeterWidget extends StatelessWidget {
  const NoMeterWidget({super.key});

  void _navigateToAddMeter(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EditMeterView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final translator = getTranslator(context);
    return Center(child:Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
            width: 300,
            child: Text(
              translator.noMeterAssistance,
              textAlign: TextAlign.center,
            )),
        const SizedBox(height: 18),
        ElevatedButton.icon(
          icon: const Icon(Icons.add, size: 18),
          label: Text(translator.addMeter),
          onPressed: () => _navigateToAddMeter(context),
        )
      ],
    ));
  }
}
