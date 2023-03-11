import 'package:flutter/material.dart';
import 'package:home_metering/controller/settings_controller.dart';
import 'package:home_metering/model/settings.dart';
import 'package:home_metering/utils/time.dart';
import 'package:home_metering/utils/validators.dart';
import 'package:home_metering/utils/widgets.dart';
import 'package:home_metering/views/home_page_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Settings settings;

  @override
  void initState() {
    super.initState();
    settings = getSettings();
  }

  void _updateSettings() async {
    if (!_isFormValid()) return;
    _formKey.currentState!.save();
    await updateSettings(settings);
    _clearNavigateHome();
  }

  void _clearNavigateHome() async {
    if (!mounted) return;

    await Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) {
          return const HomePageView();
        }));
    settings = getSettings();
  }

  bool _isFormValid() {
    return _formKey.currentState?.validate() ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final translator = getTranslator(context);
    final ButtonStyle headerButtonStyle = TextButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );

    return Scaffold(
      appBar: AppBar(
          title: Text(translator.settings),
          actions: <Widget>[
            TextButton(
              style: headerButtonStyle,
              onPressed: _clearNavigateHome,
              child: const Icon(Icons.close),
            ),
          ]),
      body: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.all(defaultViewPadding),
              child: _buildForm(context)),
          ElevatedButton.icon(
            icon: const Icon(Icons.edit, size: 18),
            label: Text(translator.update),
            onPressed: _updateSettings,
          )
        ],
      )),
    );
  }

  Form _buildForm(BuildContext context) {
    final translator = getTranslator(context);
    return Form(
        key: _formKey,
        child: Column(
          children: [
            // TODO language & translations
            TextFormField(
                initialValue: settings.currencyUnit,
                onChanged: (value) => settings.currencyUnit = value.trim(),
                validator: (value) => validateRequired(value, translator),
                decoration: InputDecoration(
                  labelText: "${translator.currency} *",
                )),
            DropdownButtonFormField<Frequency>(
              value: settings.defaultFrequency,
              validator: (value) => validateDynamicRequired(value, translator),
              onChanged: (value) => settings.defaultFrequency = value!,
              items: Frequency.values.map<DropdownMenuItem<Frequency>>((frequency) {
                return DropdownMenuItem<Frequency>(
                  value: frequency,
                  child: Text(getFrequencyTranslation(frequency, translator)),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: "${translator.defaultFrequency} *",
              ),
            )
          ],
        ));
  }
}
