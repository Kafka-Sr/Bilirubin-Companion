import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('id')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Bilirubin Monitor'**
  String get appTitle;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @noBabiesTitle.
  ///
  /// In en, this message translates to:
  /// **'No babies added yet'**
  String get noBabiesTitle;

  /// No description provided for @noBabiesCta.
  ///
  /// In en, this message translates to:
  /// **'Add your first baby'**
  String get noBabiesCta;

  /// No description provided for @noMeasurementsTitle.
  ///
  /// In en, this message translates to:
  /// **'No measurements yet'**
  String get noMeasurementsTitle;

  /// No description provided for @noMeasurementsBody.
  ///
  /// In en, this message translates to:
  /// **'Connect the device and take a measurement.'**
  String get noMeasurementsBody;

  /// No description provided for @deviceConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected: {deviceName} ({transport})'**
  String deviceConnected(String deviceName, String transport);

  /// No description provided for @deviceDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get deviceDisconnected;

  /// No description provided for @deviceTransportWifi.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi'**
  String get deviceTransportWifi;

  /// No description provided for @deviceTransportBle.
  ///
  /// In en, this message translates to:
  /// **'BLE'**
  String get deviceTransportBle;

  /// No description provided for @deviceTransportFake.
  ///
  /// In en, this message translates to:
  /// **'Simulator'**
  String get deviceTransportFake;

  /// No description provided for @bhutaniChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Bhutani Nomogram'**
  String get bhutaniChartTitle;

  /// No description provided for @showPreviousBilirubin.
  ///
  /// In en, this message translates to:
  /// **'Show Previous Bilirubin'**
  String get showPreviousBilirubin;

  /// No description provided for @zoneLow.
  ///
  /// In en, this message translates to:
  /// **'Low Risk'**
  String get zoneLow;

  /// No description provided for @zoneIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate Risk'**
  String get zoneIntermediate;

  /// No description provided for @zoneHighIntermediate.
  ///
  /// In en, this message translates to:
  /// **'High Intermediate Risk'**
  String get zoneHighIntermediate;

  /// No description provided for @zoneHigh.
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get zoneHigh;

  /// No description provided for @zoneVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Very High Risk'**
  String get zoneVeryHigh;

  /// No description provided for @recommendationHeader.
  ///
  /// In en, this message translates to:
  /// **'Recommendation'**
  String get recommendationHeader;

  /// No description provided for @recommendationLow.
  ///
  /// In en, this message translates to:
  /// **'Bilirubin levels are within the safe range. Continue routine monitoring. No immediate action required.'**
  String get recommendationLow;

  /// No description provided for @recommendationIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Bilirubin is in the intermediate zone. Repeat measurement in 8–12 hours and monitor closely.'**
  String get recommendationIntermediate;

  /// No description provided for @recommendationHighIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Bilirubin is in the high-intermediate zone. Repeat measurement in 4–8 hours. Consider initiating phototherapy per AAP 2022 guidelines.'**
  String get recommendationHighIntermediate;

  /// No description provided for @recommendationHigh.
  ///
  /// In en, this message translates to:
  /// **'Bilirubin is in the high-risk zone. Consider phototherapy immediately. Consult a neonatologist.'**
  String get recommendationHigh;

  /// No description provided for @recommendationVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Bilirubin is critically elevated. Immediate intervention required. Escalate to a neonatologist urgently.'**
  String get recommendationVeryHigh;

  /// No description provided for @metadataTitle.
  ///
  /// In en, this message translates to:
  /// **'Baby Information'**
  String get metadataTitle;

  /// No description provided for @metadataName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get metadataName;

  /// No description provided for @metadataWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get metadataWeight;

  /// No description provided for @metadataWeightKg.
  ///
  /// In en, this message translates to:
  /// **'{weight} kg'**
  String metadataWeightKg(String weight);

  /// No description provided for @metadataDob.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get metadataDob;

  /// No description provided for @metadataAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get metadataAge;

  /// No description provided for @metadataAgeHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} h old'**
  String metadataAgeHours(String hours);

  /// No description provided for @metadataEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Baby'**
  String get metadataEdit;

  /// No description provided for @bilirubinValue.
  ///
  /// In en, this message translates to:
  /// **'{value} mg/dL'**
  String bilirubinValue(String value);

  /// No description provided for @editBabyTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Baby'**
  String get editBabyTitle;

  /// No description provided for @addBabyTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Baby'**
  String get addBabyTitle;

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// No description provided for @fieldWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get fieldWeight;

  /// No description provided for @fieldDob.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get fieldDob;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get validationRequired;

  /// No description provided for @validationWeightRange.
  ///
  /// In en, this message translates to:
  /// **'Weight must be between 0.4 and 8.0 kg.'**
  String get validationWeightRange;

  /// No description provided for @validationDobFuture.
  ///
  /// In en, this message translates to:
  /// **'Date of birth cannot be in the future.'**
  String get validationDobFuture;

  /// No description provided for @validationDobTooOld.
  ///
  /// In en, this message translates to:
  /// **'Date of birth is too far in the past.'**
  String get validationDobTooOld;

  /// No description provided for @validationNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Name must be 100 characters or fewer.'**
  String get validationNameTooLong;

  /// No description provided for @validationNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Name contains invalid characters.'**
  String get validationNameInvalid;

  /// No description provided for @settingsWifi.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi Configuration'**
  String get settingsWifi;

  /// No description provided for @settingsWifiSsid.
  ///
  /// In en, this message translates to:
  /// **'Network name (SSID)'**
  String get settingsWifiSsid;

  /// No description provided for @settingsWifiPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get settingsWifiPassword;

  /// No description provided for @settingsBle.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Configuration'**
  String get settingsBle;

  /// No description provided for @settingsBleNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'BLE not yet supported in this version.'**
  String get settingsBleNotAvailable;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsAppLock.
  ///
  /// In en, this message translates to:
  /// **'App Lock'**
  String get settingsAppLock;

  /// No description provided for @settingsAppLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Require PIN or biometric to open the app.'**
  String get settingsAppLockSubtitle;

  /// No description provided for @pinLockTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get pinLockTitle;

  /// No description provided for @pinLockEnterNew.
  ///
  /// In en, this message translates to:
  /// **'Set a new PIN'**
  String get pinLockEnterNew;

  /// No description provided for @pinLockConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get pinLockConfirm;

  /// No description provided for @pinLockIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN. Try again.'**
  String get pinLockIncorrect;

  /// No description provided for @pinLockMismatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match.'**
  String get pinLockMismatch;

  /// No description provided for @pinLockUseBiometric.
  ///
  /// In en, this message translates to:
  /// **'Use biometric'**
  String get pinLockUseBiometric;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully.'**
  String get exportSuccess;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed.'**
  String get exportFailed;

  /// No description provided for @exportAction.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportAction;

  /// No description provided for @exportedTo.
  ///
  /// In en, this message translates to:
  /// **'Exported to {filename}'**
  String exportedTo(String filename);

  /// No description provided for @exportSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportSheetTitle;

  /// No description provided for @exportFileName.
  ///
  /// In en, this message translates to:
  /// **'File Name'**
  String get exportFileName;

  /// No description provided for @exportSaveLocation.
  ///
  /// In en, this message translates to:
  /// **'Save Location'**
  String get exportSaveLocation;

  /// No description provided for @exportBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get exportBrowse;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageIndonesian.
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get languageIndonesian;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get languageGerman;

  /// No description provided for @zoneLowFull.
  ///
  /// In en, this message translates to:
  /// **'Low Risk Zone'**
  String get zoneLowFull;

  /// No description provided for @zoneIntermediateFull.
  ///
  /// In en, this message translates to:
  /// **'Intermediate Risk Zone'**
  String get zoneIntermediateFull;

  /// No description provided for @zoneHighIntermediateFull.
  ///
  /// In en, this message translates to:
  /// **'High Intermediate Risk Zone'**
  String get zoneHighIntermediateFull;

  /// No description provided for @zoneHighFull.
  ///
  /// In en, this message translates to:
  /// **'High Risk Zone'**
  String get zoneHighFull;

  /// No description provided for @zoneVeryHighFull.
  ///
  /// In en, this message translates to:
  /// **'Very High Risk Zone'**
  String get zoneVeryHighFull;

  /// No description provided for @deviceConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get deviceConnecting;

  /// No description provided for @deviceConnectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Connected:'**
  String get deviceConnectedLabel;

  /// No description provided for @deviceConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get deviceConnect;

  /// No description provided for @deviceDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get deviceDisconnect;

  /// No description provided for @selectBaby.
  ///
  /// In en, this message translates to:
  /// **'Select baby'**
  String get selectBaby;

  /// No description provided for @searchBabiesHint.
  ///
  /// In en, this message translates to:
  /// **'Search babies…'**
  String get searchBabiesHint;

  /// No description provided for @archivedCount.
  ///
  /// In en, this message translates to:
  /// **'Archived ({count})'**
  String archivedCount(int count);

  /// No description provided for @archiveBabyAction.
  ///
  /// In en, this message translates to:
  /// **'Archive Baby'**
  String get archiveBabyAction;

  /// No description provided for @archiveBabyContent.
  ///
  /// In en, this message translates to:
  /// **'Archive \"{name}\"? The record will be preserved and can be restored later.'**
  String archiveBabyContent(String name);

  /// No description provided for @archiveAction.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveAction;

  /// No description provided for @permanentDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently Delete Baby'**
  String get permanentDeleteTitle;

  /// No description provided for @permanentDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete \"{name}\"? All data will be lost and cannot be recovered.'**
  String permanentDeleteContent(String name);

  /// No description provided for @deleteForever.
  ///
  /// In en, this message translates to:
  /// **'Delete Forever'**
  String get deleteForever;

  /// No description provided for @restoreAction.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restoreAction;

  /// No description provided for @permanentlyDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete'**
  String get permanentlyDeleteTooltip;
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
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
