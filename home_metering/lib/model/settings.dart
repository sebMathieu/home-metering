import 'package:home_metering/utils/time.dart';

class Settings {
  Frequency defaultFrequency;
  String currencyUnit;

  Settings({ // Must have default values
    this.defaultFrequency = Frequency.monthly,
    this.currencyUnit = "€"
  });
}
