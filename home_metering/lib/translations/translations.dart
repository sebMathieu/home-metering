import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'translations_en.dart';
import 'translations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'translations/translations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @abnormal.
  ///
  /// In en, this message translates to:
  /// **'Abnormal'**
  String get abnormal;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addMeter.
  ///
  /// In en, this message translates to:
  /// **'Add meter'**
  String get addMeter;

  /// No description provided for @analysisPeriod.
  ///
  /// In en, this message translates to:
  /// **'Analysis period'**
  String get analysisPeriod;

  /// No description provided for @averageConsumption.
  ///
  /// In en, this message translates to:
  /// **'Average consumption'**
  String get averageConsumption;

  /// No description provided for @averageCost.
  ///
  /// In en, this message translates to:
  /// **'Average cost'**
  String get averageCost;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @consumptionTrend.
  ///
  /// In en, this message translates to:
  /// **'Consumption trend'**
  String get consumptionTrend;

  /// No description provided for @consumptions.
  ///
  /// In en, this message translates to:
  /// **'Consumptions'**
  String get consumptions;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get cost;

  /// No description provided for @csvParsingDescription.
  ///
  /// In en, this message translates to:
  /// **'No meter readings were parsed from the provided file. Ensure it is a valid CSV file (e.g. separator is \",\") and that all lines fit one of the following formats:'**
  String get csvParsingDescription;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @currentConsumption.
  ///
  /// In en, this message translates to:
  /// **'Current consumption'**
  String get currentConsumption;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'daily'**
  String get daily;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @decimals.
  ///
  /// In en, this message translates to:
  /// **'Decimals'**
  String get decimals;

  /// No description provided for @defaultFrequency.
  ///
  /// In en, this message translates to:
  /// **'Default frequency'**
  String get defaultFrequency;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item ?'**
  String get deleteConfirmation;

  /// No description provided for @deleteMeter.
  ///
  /// In en, this message translates to:
  /// **'Delete meter'**
  String get deleteMeter;

  /// No description provided for @deleteMeterReading.
  ///
  /// In en, this message translates to:
  /// **'Delete meter reading'**
  String get deleteMeterReading;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @digits.
  ///
  /// In en, this message translates to:
  /// **'Digits'**
  String get digits;

  /// No description provided for @display.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get display;

  /// No description provided for @editLastMeterReading.
  ///
  /// In en, this message translates to:
  /// **'Edit last meter reading'**
  String get editLastMeterReading;

  /// No description provided for @editMeter.
  ///
  /// In en, this message translates to:
  /// **'Edit meter'**
  String get editMeter;

  /// No description provided for @editMeterReading.
  ///
  /// In en, this message translates to:
  /// **'Edit meter reading'**
  String get editMeterReading;

  /// No description provided for @encodeMeterReading.
  ///
  /// In en, this message translates to:
  /// **'Encode meter reading'**
  String get encodeMeterReading;

  /// No description provided for @expectedConsumption.
  ///
  /// In en, this message translates to:
  /// **'Expected consumption'**
  String get expectedConsumption;

  /// No description provided for @expectedThresholdReach.
  ///
  /// In en, this message translates to:
  /// **'Expected threshold reach'**
  String get expectedThresholdReach;

  /// No description provided for @exportAsCSV.
  ///
  /// In en, this message translates to:
  /// **'Export as CSV'**
  String get exportAsCSV;

  /// No description provided for @exportReadingsFromAllMeterAsCSV.
  ///
  /// In en, this message translates to:
  /// **'Export readings from all meters as CSV'**
  String get exportReadingsFromAllMeterAsCSV;

  /// No description provided for @forecasts.
  ///
  /// In en, this message translates to:
  /// **'Forecasts'**
  String get forecasts;

  /// No description provided for @importFromCSV.
  ///
  /// In en, this message translates to:
  /// **'Import from CSV'**
  String get importFromCSV;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get invalidNumber;

  /// No description provided for @invalidTimeOfDay.
  ///
  /// In en, this message translates to:
  /// **'Invalid time of day'**
  String get invalidTimeOfDay;

  /// No description provided for @isDecreasing.
  ///
  /// In en, this message translates to:
  /// **'Is decreasing'**
  String get isDecreasing;

  /// No description provided for @isIndexReset.
  ///
  /// In en, this message translates to:
  /// **'Is index reset'**
  String get isIndexReset;

  /// No description provided for @lastReading.
  ///
  /// In en, this message translates to:
  /// **'Last reading'**
  String get lastReading;

  /// No description provided for @meter.
  ///
  /// In en, this message translates to:
  /// **'Meter'**
  String get meter;

  /// No description provided for @meterColor.
  ///
  /// In en, this message translates to:
  /// **'Meter color'**
  String get meterColor;

  /// No description provided for @meterIndex.
  ///
  /// In en, this message translates to:
  /// **'Meter index'**
  String get meterIndex;

  /// No description provided for @meterIndexProperties.
  ///
  /// In en, this message translates to:
  /// **'Index properties'**
  String get meterIndexProperties;

  /// No description provided for @meterReadings.
  ///
  /// In en, this message translates to:
  /// **'Meter readings'**
  String get meterReadings;

  /// No description provided for @meters.
  ///
  /// In en, this message translates to:
  /// **'Meters'**
  String get meters;

  /// No description provided for @monitoringIndexThreshold.
  ///
  /// In en, this message translates to:
  /// **'Monitoring index threshold'**
  String get monitoringIndexThreshold;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get month;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'monthly'**
  String get monthly;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @newMeter.
  ///
  /// In en, this message translates to:
  /// **'New meter'**
  String get newMeter;

  /// No description provided for @newMeterReading.
  ///
  /// In en, this message translates to:
  /// **'New meter reading'**
  String get newMeterReading;

  /// No description provided for @noInformationAvailable.
  ///
  /// In en, this message translates to:
  /// **'No information available.'**
  String get noInformationAvailable;

  /// No description provided for @noMeterAssistance.
  ///
  /// In en, this message translates to:
  /// **'No meter to display. Would you like to add a new meter ?'**
  String get noMeterAssistance;

  /// No description provided for @noMeterReadingAssistance.
  ///
  /// In en, this message translates to:
  /// **'No meter reading to display. Would you like to add a new meter reading ?'**
  String get noMeterReadingAssistance;

  /// No description provided for @noMeterReadingsImported.
  ///
  /// In en, this message translates to:
  /// **'No meter readings imported'**
  String get noMeterReadingsImported;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @problemOccurred.
  ///
  /// In en, this message translates to:
  /// **'An unexpected problem occurred.'**
  String get problemOccurred;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @serialNumber.
  ///
  /// In en, this message translates to:
  /// **'Serial number'**
  String get serialNumber;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @sinceLastReading.
  ///
  /// In en, this message translates to:
  /// **'Since last reading'**
  String get sinceLastReading;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @timeOfDay.
  ///
  /// In en, this message translates to:
  /// **'Time of day'**
  String get timeOfDay;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @unitCost.
  ///
  /// In en, this message translates to:
  /// **'Unit cost'**
  String get unitCost;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @valueMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Value must be positive'**
  String get valueMustBePositive;

  /// No description provided for @viewMeterReadings.
  ///
  /// In en, this message translates to:
  /// **'View meter readings'**
  String get viewMeterReadings;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'week'**
  String get week;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'weekly'**
  String get weekly;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get year;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'yearly'**
  String get yearly;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
