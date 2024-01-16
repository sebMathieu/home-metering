# home_metering

Don't forget to export your data before trying a debug version on your phone.

## Update icon & name

Icon can be updated by changing `/assets/app-logo-256.png` and running

```bash
flutter pub run flutter_launcher_icons
```

The application name can be modified in `android/app/src/main/AndroidManifest.xml`.

## Colors

```json
{
  "Amber": "#ffc107",
  "White": "#fbfffe",
  "Raisin Black": "#272838",
  "Ruby Red": "#9b1d20",
  "Bottle Green": "#226f54"
}
```


## Release

Creating a release requires, to sign it. In particular, ensure that the file `android/key.properties` exists with its content :
```
storePassword=***
keyPassword=***
keyAlias=upload
storeFile=C:\\programs\\android-keystore.jks
```
**Update the version number** in `pubspec.yaml` and run 
```
flutter clean
flutter build appbundle
```
Upload the generated bundle as a *new realease* to [Google play console](https://play.google.com/console).
