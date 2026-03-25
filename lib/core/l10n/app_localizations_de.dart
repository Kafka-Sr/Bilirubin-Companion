// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Bilirubin-Monitor';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get noBabiesTitle => 'Noch keine Babys hinzugefügt';

  @override
  String get noBabiesCta => 'Erstes Baby hinzufügen';

  @override
  String get noMeasurementsTitle => 'Noch keine Messungen';

  @override
  String get noMeasurementsBody => 'Gerät verbinden und Messung durchführen.';

  @override
  String deviceConnected(String deviceName, String transport) {
    return 'Verbunden: $deviceName ($transport)';
  }

  @override
  String get deviceDisconnected => 'Nicht verbunden';

  @override
  String get deviceTransportWifi => 'WLAN';

  @override
  String get deviceTransportBle => 'BLE';

  @override
  String get deviceTransportFake => 'Simulator';

  @override
  String get bhutaniChartTitle => 'Bhutani-Nomogramm';

  @override
  String get showPreviousBilirubin => 'Frühere Bilirubin-Werte anzeigen';

  @override
  String get zoneLow => 'Geringes Risiko';

  @override
  String get zoneIntermediate => 'Mittleres Risiko';

  @override
  String get zoneHighIntermediate => 'Erhöhtes mittleres Risiko';

  @override
  String get zoneHigh => 'Hohes Risiko';

  @override
  String get zoneVeryHigh => 'Sehr hohes Risiko';

  @override
  String get recommendationHeader => 'Empfehlung';

  @override
  String get recommendationLow =>
      'Die Bilirubinwerte liegen im sicheren Bereich. Routineüberwachung fortsetzen. Kein sofortiger Handlungsbedarf.';

  @override
  String get recommendationIntermediate =>
      'Bilirubin liegt im mittleren Bereich. Messung in 8–12 Stunden wiederholen und engmaschig beobachten.';

  @override
  String get recommendationHighIntermediate =>
      'Bilirubin liegt im erhöhten mittleren Bereich. Messung in 4–8 Stunden wiederholen. Phototherapie gemäß AAP-Leitlinie 2022 erwägen.';

  @override
  String get recommendationHigh =>
      'Bilirubin im Hochrisikobereich. Sofortige Phototherapie erwägen. Neonatologen konsultieren.';

  @override
  String get recommendationVeryHigh =>
      'Bilirubin kritisch erhöht. Sofortiger Handlungsbedarf. Dringend Neonatologen hinzuziehen.';

  @override
  String get metadataTitle => 'Babyinformationen';

  @override
  String get metadataName => 'Name';

  @override
  String get metadataWeight => 'Gewicht';

  @override
  String metadataWeightKg(String weight) {
    return '$weight kg';
  }

  @override
  String get metadataDob => 'Geburtsdatum';

  @override
  String get metadataAge => 'Alter';

  @override
  String metadataAgeHours(String hours) {
    return '$hours Stunden alt';
  }

  @override
  String get metadataEdit => 'Bearbeiten';

  @override
  String bilirubinValue(String value) {
    return '$value mg/dL';
  }

  @override
  String get editBabyTitle => 'Baby bearbeiten';

  @override
  String get addBabyTitle => 'Baby hinzufügen';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldWeight => 'Gewicht (kg)';

  @override
  String get fieldDob => 'Geburtsdatum';

  @override
  String get selectDate => 'Datum auswählen';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get validationRequired => 'Dieses Feld ist erforderlich.';

  @override
  String get validationWeightRange =>
      'Gewicht muss zwischen 0,4 und 8,0 kg liegen.';

  @override
  String get validationDobFuture =>
      'Geburtsdatum kann nicht in der Zukunft liegen.';

  @override
  String get validationDobTooOld =>
      'Geburtsdatum liegt zu weit in der Vergangenheit.';

  @override
  String get validationNameTooLong =>
      'Name darf höchstens 100 Zeichen lang sein.';

  @override
  String get validationNameInvalid => 'Name enthält ungültige Zeichen.';

  @override
  String get settingsWifi => 'WLAN-Konfiguration';

  @override
  String get settingsWifiSsid => 'Netzwerkname (SSID)';

  @override
  String get settingsWifiPassword => 'Passwort';

  @override
  String get settingsBle => 'Bluetooth-Konfiguration';

  @override
  String get settingsBleNotAvailable =>
      'BLE wird in dieser Version noch nicht unterstützt.';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsTheme => 'Design';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Hell';

  @override
  String get settingsThemeDark => 'Dunkel';

  @override
  String get settingsAppLock => 'App-Sperre';

  @override
  String get settingsAppLockSubtitle =>
      'PIN oder Biometrie zum Öffnen der App verlangen.';

  @override
  String get pinLockTitle => 'PIN eingeben';

  @override
  String get pinLockEnterNew => 'Neue PIN festlegen';

  @override
  String get pinLockConfirm => 'PIN bestätigen';

  @override
  String get pinLockIncorrect => 'Falsche PIN. Erneut versuchen.';

  @override
  String get pinLockMismatch => 'PINs stimmen nicht überein.';

  @override
  String get pinLockUseBiometric => 'Biometrie verwenden';

  @override
  String get exportSuccess => 'Daten erfolgreich exportiert.';

  @override
  String get exportFailed => 'Export fehlgeschlagen.';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get languageIndonesian => 'Indonesisch';

  @override
  String get languageGerman => 'Deutsch';
}
