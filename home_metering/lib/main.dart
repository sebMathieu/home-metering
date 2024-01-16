import 'package:flutter/material.dart';
import 'package:home_metering/controller/database_singleton.dart';
import 'package:home_metering/controller/settings_controller.dart';

import 'package:home_metering/views/home_page_view.dart';
import 'package:intl/intl_standalone.dart';
import 'package:flutter_gen/gen_l10n/translations.dart';

void main() async {
  // Database
  await initializeDatabase();
  await initializeSettings();

  // Language
  await findSystemLocale();

  // Run app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home-metering',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.amber, primary: Colors.amber),
      ),
      home: const HomePageView(),
    );
  }
}
