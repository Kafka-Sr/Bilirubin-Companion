// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Bilirubin Monitor';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get noBabiesTitle => 'No babies added yet';

  @override
  String get noBabiesCta => 'Add your first baby';

  @override
  String get noMeasurementsTitle => 'No measurements yet';

  @override
  String get noMeasurementsBody => 'Connect the device and take a measurement.';

  @override
  String deviceConnected(String deviceName, String transport) {
    return 'Connected: $deviceName ($transport)';
  }

  @override
  String get deviceDisconnected => 'Not connected';

  @override
  String get deviceTransportWifi => 'Wi-Fi';

  @override
  String get deviceTransportBle => 'BLE';

  @override
  String get deviceTransportFake => 'Simulator';

  @override
  String get bhutaniChartTitle => 'Bhutani Nomogram';

  @override
  String get showPreviousBilirubin => 'Show Previous Bilirubin';

  @override
  String get zoneLow => 'Low Risk';

  @override
  String get zoneIntermediate => 'Intermediate Risk';

  @override
  String get zoneHighIntermediate => 'High Intermediate Risk';

  @override
  String get zoneHigh => 'High Risk';

  @override
  String get zoneVeryHigh => 'Very High Risk';

  @override
  String get recommendationHeader => 'Recommendation';

  @override
  String get recommendationLow =>
      'Bilirubin levels are within the safe range. Continue routine monitoring. No immediate action required.';

  @override
  String get recommendationIntermediate =>
      'Bilirubin is in the intermediate zone. Repeat measurement in 8–12 hours and monitor closely.';

  @override
  String get recommendationHighIntermediate =>
      'Bilirubin is in the high-intermediate zone. Repeat measurement in 4–8 hours. Consider initiating phototherapy per AAP 2022 guidelines.';

  @override
  String get recommendationHigh =>
      'Bilirubin is in the high-risk zone. Consider phototherapy immediately. Consult a neonatologist.';

  @override
  String get recommendationVeryHigh =>
      'Bilirubin is critically elevated. Immediate intervention required. Escalate to a neonatologist urgently.';

  @override
  String get metadataTitle => 'Baby Information';

  @override
  String get metadataName => 'Name';

  @override
  String get metadataWeight => 'Weight';

  @override
  String metadataWeightKg(String weight) {
    return '$weight kg';
  }

  @override
  String get metadataDob => 'Date of Birth';

  @override
  String get metadataAge => 'Age';

  @override
  String metadataAgeHours(String hours) {
    return '$hours h old';
  }

  @override
  String get metadataEdit => 'Edit';

  @override
  String bilirubinValue(String value) {
    return '$value mg/dL';
  }

  @override
  String get editBabyTitle => 'Edit Baby';

  @override
  String get addBabyTitle => 'Add Baby';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldWeight => 'Weight (kg)';

  @override
  String get fieldDob => 'Date of Birth';

  @override
  String get selectDate => 'Select date';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get validationRequired => 'This field is required.';

  @override
  String get validationWeightRange => 'Weight must be between 0.4 and 8.0 kg.';

  @override
  String get validationDobFuture => 'Date of birth cannot be in the future.';

  @override
  String get validationDobTooOld => 'Date of birth is too far in the past.';

  @override
  String get validationNameTooLong => 'Name must be 100 characters or fewer.';

  @override
  String get validationNameInvalid => 'Name contains invalid characters.';

  @override
  String get settingsWifi => 'Wi-Fi Configuration';

  @override
  String get settingsWifiSsid => 'Network name (SSID)';

  @override
  String get settingsWifiPassword => 'Password';

  @override
  String get settingsBle => 'Bluetooth Configuration';

  @override
  String get settingsBleNotAvailable =>
      'BLE not yet supported in this version.';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsAppLock => 'App Lock';

  @override
  String get settingsAppLockSubtitle =>
      'Require PIN or biometric to open the app.';

  @override
  String get pinLockTitle => 'Enter PIN';

  @override
  String get pinLockEnterNew => 'Set a new PIN';

  @override
  String get pinLockConfirm => 'Confirm PIN';

  @override
  String get pinLockIncorrect => 'Incorrect PIN. Try again.';

  @override
  String get pinLockMismatch => 'PINs do not match.';

  @override
  String get pinLockUseBiometric => 'Use biometric';

  @override
  String get exportSuccess => 'Data exported successfully.';

  @override
  String get exportFailed => 'Export failed.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageIndonesian => 'Indonesian';

  @override
  String get languageGerman => 'German';
}
