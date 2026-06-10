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
  /// **'Biligun Companion'**
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

  /// No description provided for @deviceDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Not paired, check Settings'**
  String get deviceDisconnected;

  /// No description provided for @bhutaniChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Bhutani Nomogram'**
  String get bhutaniChartTitle;

  /// No description provided for @showPreviousBilirubin.
  ///
  /// In en, this message translates to:
  /// **'Show Previous Readings'**
  String get showPreviousBilirubin;

  /// No description provided for @showReadingsOutside168h.
  ///
  /// In en, this message translates to:
  /// **'Show Readings >168 h'**
  String get showReadingsOutside168h;

  /// No description provided for @bhutaniOutsideRangeNotice.
  ///
  /// In en, this message translates to:
  /// **'Reminder: This Bhutani nomogram only displays bilirubin readings from ages 0 to 168 hours. Readings beyond this age range are in purple dots.'**
  String get bhutaniOutsideRangeNotice;

  /// No description provided for @bhutaniCurrentBeyond168h.
  ///
  /// In en, this message translates to:
  /// **'The baby\'s age is currently beyond 168 hours.'**
  String get bhutaniCurrentBeyond168h;

  /// No description provided for @axisLabelTotalSerumBilirubin.
  ///
  /// In en, this message translates to:
  /// **'Total Serum Bilirubin (mg/dL)'**
  String get axisLabelTotalSerumBilirubin;

  /// No description provided for @axisLabelAgeHours.
  ///
  /// In en, this message translates to:
  /// **'Age (h)'**
  String get axisLabelAgeHours;

  /// No description provided for @zoneLow.
  ///
  /// In en, this message translates to:
  /// **'Low Risk'**
  String get zoneLow;

  /// No description provided for @zoneLowIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Low Intermediate Risk'**
  String get zoneLowIntermediate;

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

  /// No description provided for @recommendationHeader.
  ///
  /// In en, this message translates to:
  /// **'Recommendation'**
  String get recommendationHeader;

  /// No description provided for @recommendationLow.
  ///
  /// In en, this message translates to:
  /// **'Bilirubin levels are within the safe range (below 40th percentile). Continue routine monitoring. No immediate action required.'**
  String get recommendationLow;

  /// No description provided for @recommendationLowIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Bilirubin is in the low intermediate zone (40th–75th percentile). Repeat measurement in 8–12 hours and monitor closely.'**
  String get recommendationLowIntermediate;

  /// No description provided for @recommendationHighIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Bilirubin is in the high intermediate zone (75th–95th percentile). Repeat measurement in 4–8 hours. Consider initiating phototherapy per AAP 2022 guidelines.'**
  String get recommendationHighIntermediate;

  /// No description provided for @recommendationHigh.
  ///
  /// In en, this message translates to:
  /// **'Bilirubin is critically elevated (above 95th percentile). Immediate intervention required. Escalate to a neonatologist urgently.'**
  String get recommendationHigh;

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
  /// **'Edit Data'**
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

  /// No description provided for @editAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editAction;

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
  /// **'Date & Time of Birth'**
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

  /// No description provided for @settingsPiLanTitle.
  ///
  /// In en, this message translates to:
  /// **'Biligun LAN'**
  String get settingsPiLanTitle;

  /// No description provided for @settingsPiAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Biligun address or URL'**
  String get settingsPiAddressLabel;

  /// No description provided for @settingsPiAddressHint.
  ///
  /// In en, this message translates to:
  /// **'10.42.0.1:7878'**
  String get settingsPiAddressHint;

  /// No description provided for @settingsHotspotTitle.
  ///
  /// In en, this message translates to:
  /// **'Biligun Pairing'**
  String get settingsHotspotTitle;

  /// No description provided for @settingsHotspotInstructions.
  ///
  /// In en, this message translates to:
  /// **'If the phone and Biligun are on the same Wi-Fi network, the app will discover the Biligun automatically. Make sure the app connects to the Biligun\'s hotspot connection.'**
  String get settingsHotspotInstructions;

  /// No description provided for @settingsPiSave.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get settingsPiSave;

  /// No description provided for @settingsPiClear.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get settingsPiClear;

  /// No description provided for @settingsPiBeaconUse.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get settingsPiBeaconUse;

  /// No description provided for @settingsPiBeaconDescription.
  ///
  /// In en, this message translates to:
  /// **'If the phone and Biligun are on the same Wi-Fi network, the app can discover the Biligun automatically by beacon. Supabase still stores the synced history.'**
  String get settingsPiBeaconDescription;

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

  /// No description provided for @zoneLowIntermediateFull.
  ///
  /// In en, this message translates to:
  /// **'Low Intermediate Risk Zone'**
  String get zoneLowIntermediateFull;

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

  /// No description provided for @deviceConnecting.
  ///
  /// In en, this message translates to:
  /// **'Pairing…'**
  String get deviceConnecting;

  /// No description provided for @deviceConnectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Connected:'**
  String get deviceConnectedLabel;

  /// No description provided for @deviceConnect.
  ///
  /// In en, this message translates to:
  /// **'Pair'**
  String get deviceConnect;

  /// No description provided for @deviceDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get deviceDisconnect;

  /// No description provided for @deviceConnectedTo.
  ///
  /// In en, this message translates to:
  /// **'Paired with {displayName}'**
  String deviceConnectedTo(String displayName);

  /// No description provided for @deviceConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Failed to pair'**
  String get deviceConnectionError;

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

  /// No description provided for @archivedBabies.
  ///
  /// In en, this message translates to:
  /// **'View Archived Babies'**
  String get archivedBabies;

  /// No description provided for @pdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Bilirubin Report'**
  String get pdfTitle;

  /// No description provided for @pdfExportedAt.
  ///
  /// In en, this message translates to:
  /// **'Exported:'**
  String get pdfExportedAt;

  /// No description provided for @pdfGeneratedBy.
  ///
  /// In en, this message translates to:
  /// **'Generated by Bilirubin App'**
  String get pdfGeneratedBy;

  /// No description provided for @pdfPatientInfo.
  ///
  /// In en, this message translates to:
  /// **'Patient Information'**
  String get pdfPatientInfo;

  /// No description provided for @pdfBirthWeight.
  ///
  /// In en, this message translates to:
  /// **'Birth Weight'**
  String get pdfBirthWeight;

  /// No description provided for @pdfAgeAtExport.
  ///
  /// In en, this message translates to:
  /// **'Age at Export'**
  String get pdfAgeAtExport;

  /// No description provided for @pdfMeasurementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get pdfMeasurementsTitle;

  /// No description provided for @pdfColDateTime.
  ///
  /// In en, this message translates to:
  /// **'Date/Time'**
  String get pdfColDateTime;

  /// No description provided for @pdfColBilirubin.
  ///
  /// In en, this message translates to:
  /// **'Bilirubin (mg/dL)'**
  String get pdfColBilirubin;

  /// No description provided for @pdfColZone.
  ///
  /// In en, this message translates to:
  /// **'Zone'**
  String get pdfColZone;

  /// No description provided for @pdfColDevice.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get pdfColDevice;

  /// No description provided for @cloudNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Can\'t connect to the server'**
  String get cloudNotConfigured;

  /// No description provided for @cloudSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing to server…'**
  String get cloudSyncing;

  /// No description provided for @cloudSyncError.
  ///
  /// In en, this message translates to:
  /// **'Sync error'**
  String get cloudSyncError;

  /// No description provided for @cloudSynced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get cloudSynced;

  /// No description provided for @noReadings.
  ///
  /// In en, this message translates to:
  /// **'No Readings'**
  String get noReadings;

  /// No description provided for @syncButton.
  ///
  /// In en, this message translates to:
  /// **'Synchronise'**
  String get syncButton;

  /// No description provided for @syncButtonSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncButtonSyncing;

  /// No description provided for @metadataTob.
  ///
  /// In en, this message translates to:
  /// **'Time of Birth'**
  String get metadataTob;

  /// No description provided for @errorAccountDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deactivated. Contact your hospital administrator.'**
  String get errorAccountDeactivated;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get loginSubtitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginSignIn;

  /// No description provided for @loginEmailValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get loginEmailValidation;

  /// No description provided for @loginPasswordValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get loginPasswordValidation;

  /// No description provided for @loginContactAdmin.
  ///
  /// In en, this message translates to:
  /// **'Contact your hospital administrator to get an account.'**
  String get loginContactAdmin;

  /// No description provided for @loginUnexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get loginUnexpectedError;

  /// No description provided for @adminPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminPanelTitle;

  /// No description provided for @adminUserManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get adminUserManagementTitle;

  /// No description provided for @adminUserManagementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage all admin, staff, and parent accounts'**
  String get adminUserManagementSubtitle;

  /// No description provided for @adminParentAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Parent Access'**
  String get adminParentAccessTitle;

  /// No description provided for @adminParentAccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Link and unlink parents to babies'**
  String get adminParentAccessSubtitle;

  /// No description provided for @adminTransfersTitle.
  ///
  /// In en, this message translates to:
  /// **'Baby Transfers'**
  String get adminTransfersTitle;

  /// No description provided for @adminTransfersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Initiate and manage inter-hospital transfers'**
  String get adminTransfersSubtitle;

  /// No description provided for @adminAuditTitle.
  ///
  /// In en, this message translates to:
  /// **'Audit Events Log'**
  String get adminAuditTitle;

  /// No description provided for @adminAuditSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View a log of sensitive actions in your hospital'**
  String get adminAuditSubtitle;

  /// No description provided for @userManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagementTitle;

  /// No description provided for @addAccountFab.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get addAccountFab;

  /// No description provided for @noAccountsFound.
  ///
  /// In en, this message translates to:
  /// **'No accounts found.'**
  String get noAccountsFound;

  /// No description provided for @roleAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get roleAll;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get roleStaff;

  /// No description provided for @roleParent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get roleParent;

  /// No description provided for @deactivateAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Deactivate Account'**
  String get deactivateAccountTitle;

  /// No description provided for @reactivateAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Reactivate Account'**
  String get reactivateAccountTitle;

  /// No description provided for @deactivateConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Deactivate {name} ({role})? They will lose access immediately.'**
  String deactivateConfirmContent(String name, String role);

  /// No description provided for @reactivateConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Reactivate {name} ({role})? They will regain access.'**
  String reactivateConfirmContent(String name, String role);

  /// No description provided for @deactivatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Deactivated'**
  String get deactivatedLabel;

  /// No description provided for @selfLabel.
  ///
  /// In en, this message translates to:
  /// **'(you)'**
  String get selfLabel;

  /// No description provided for @addAccountDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get addAccountDialogTitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Min 8 characters'**
  String get passwordMinLength;

  /// No description provided for @createLabel.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createLabel;

  /// No description provided for @loadingUsersError.
  ///
  /// In en, this message translates to:
  /// **'Error loading users: {error}'**
  String loadingUsersError(String error);

  /// No description provided for @parentAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Parent Access'**
  String get parentAccessTitle;

  /// No description provided for @currentLinksTitle.
  ///
  /// In en, this message translates to:
  /// **'Current Links'**
  String get currentLinksTitle;

  /// No description provided for @noParentLinksYet.
  ///
  /// In en, this message translates to:
  /// **'No parent links yet.'**
  String get noParentLinksYet;

  /// No description provided for @linkParentSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Link a Parent to a Baby'**
  String get linkParentSectionTitle;

  /// No description provided for @findParentStep.
  ///
  /// In en, this message translates to:
  /// **'Parent Account'**
  String get findParentStep;

  /// No description provided for @parentEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Parent email'**
  String get parentEmailLabel;

  /// No description provided for @searchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchLabel;

  /// No description provided for @selectBabyStep.
  ///
  /// In en, this message translates to:
  /// **'Baby Profile'**
  String get selectBabyStep;

  /// No description provided for @linkParentButton.
  ///
  /// In en, this message translates to:
  /// **'Link Parent to Baby'**
  String get linkParentButton;

  /// No description provided for @unlinkParentTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlink Parent'**
  String get unlinkParentTitle;

  /// No description provided for @unlinkConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Remove {parent}\'s access to {baby}?'**
  String unlinkConfirmContent(String parent, String baby);

  /// No description provided for @parentLinkedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Parent linked successfully.'**
  String get parentLinkedSuccess;

  /// No description provided for @babyTransfersTitle.
  ///
  /// In en, this message translates to:
  /// **'Baby Transfers'**
  String get babyTransfersTitle;

  /// No description provided for @outgoingTab.
  ///
  /// In en, this message translates to:
  /// **'Outgoing'**
  String get outgoingTab;

  /// No description provided for @incomingTab.
  ///
  /// In en, this message translates to:
  /// **'Incoming'**
  String get incomingTab;

  /// No description provided for @initiateTransferFab.
  ///
  /// In en, this message translates to:
  /// **'Initiate Transfer'**
  String get initiateTransferFab;

  /// No description provided for @noOutgoingTransfers.
  ///
  /// In en, this message translates to:
  /// **'No outgoing transfers.'**
  String get noOutgoingTransfers;

  /// No description provided for @noIncomingTransfers.
  ///
  /// In en, this message translates to:
  /// **'No incoming transfers.'**
  String get noIncomingTransfers;

  /// No description provided for @acceptLabel.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptLabel;

  /// No description provided for @rejectLabel.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectLabel;

  /// No description provided for @initiateTransferDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Initiate Transfer'**
  String get initiateTransferDialogTitle;

  /// No description provided for @babyLabel.
  ///
  /// In en, this message translates to:
  /// **'Baby'**
  String get babyLabel;

  /// No description provided for @targetHospitalCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Target Hospital Code'**
  String get targetHospitalCodeLabel;

  /// No description provided for @hospitalCodeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. RSU-01'**
  String get hospitalCodeHint;

  /// No description provided for @sendLabel.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendLabel;

  /// No description provided for @auditEventsLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Audit Events Log'**
  String get auditEventsLogTitle;

  /// No description provided for @auditAllFilter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get auditAllFilter;

  /// No description provided for @auditNoEvents.
  ///
  /// In en, this message translates to:
  /// **'No events found.'**
  String get auditNoEvents;

  /// No description provided for @auditEventBabyCreate.
  ///
  /// In en, this message translates to:
  /// **'Baby Created'**
  String get auditEventBabyCreate;

  /// No description provided for @auditEventBabyEdit.
  ///
  /// In en, this message translates to:
  /// **'Baby Edited'**
  String get auditEventBabyEdit;

  /// No description provided for @auditEventBabyDelete.
  ///
  /// In en, this message translates to:
  /// **'Baby Deleted'**
  String get auditEventBabyDelete;

  /// No description provided for @auditEventMeasurementCreate.
  ///
  /// In en, this message translates to:
  /// **'Measurement Recorded'**
  String get auditEventMeasurementCreate;

  /// No description provided for @auditEventMeasurementDelete.
  ///
  /// In en, this message translates to:
  /// **'Measurement Deleted'**
  String get auditEventMeasurementDelete;

  /// No description provided for @auditEventExport.
  ///
  /// In en, this message translates to:
  /// **'Data Export'**
  String get auditEventExport;

  /// No description provided for @auditEventAccountCreate.
  ///
  /// In en, this message translates to:
  /// **'Account Created'**
  String get auditEventAccountCreate;

  /// No description provided for @auditEventAccountDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Account Deactivated'**
  String get auditEventAccountDeactivate;

  /// No description provided for @auditEventAccountReactivate.
  ///
  /// In en, this message translates to:
  /// **'Account Reactivated'**
  String get auditEventAccountReactivate;

  /// No description provided for @auditEventParentLink.
  ///
  /// In en, this message translates to:
  /// **'Parent Linked'**
  String get auditEventParentLink;

  /// No description provided for @auditEventParentUnlink.
  ///
  /// In en, this message translates to:
  /// **'Parent Unlinked'**
  String get auditEventParentUnlink;

  /// No description provided for @auditEventDeviceAdd.
  ///
  /// In en, this message translates to:
  /// **'Device Connected'**
  String get auditEventDeviceAdd;

  /// No description provided for @auditEventTransferCreate.
  ///
  /// In en, this message translates to:
  /// **'Transfer Initiated'**
  String get auditEventTransferCreate;

  /// No description provided for @auditEventTransferAccept.
  ///
  /// In en, this message translates to:
  /// **'Transfer Accepted'**
  String get auditEventTransferAccept;

  /// No description provided for @auditEventTransferReject.
  ///
  /// In en, this message translates to:
  /// **'Transfer Rejected'**
  String get auditEventTransferReject;

  /// No description provided for @parentDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Parent Dashboard'**
  String get parentDashboardTitle;

  /// No description provided for @signOutTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutTooltip;

  /// No description provided for @awaitingLinkageTitle.
  ///
  /// In en, this message translates to:
  /// **'Awaiting linkage'**
  String get awaitingLinkageTitle;

  /// No description provided for @awaitingLinkageBody.
  ///
  /// In en, this message translates to:
  /// **'Your account ({email}) has not yet been linked to a baby by the hospital. Please contact your hospital staff.'**
  String awaitingLinkageBody(String email);

  /// No description provided for @measurementsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get measurementsSectionTitle;

  /// No description provided for @noMeasurementsParent.
  ///
  /// In en, this message translates to:
  /// **'No measurements yet.'**
  String get noMeasurementsParent;

  /// No description provided for @settingsAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccountTitle;

  /// No description provided for @signOutLabel.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutLabel;

  /// No description provided for @couldNotLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Could not load profile.'**
  String get couldNotLoadProfile;

  /// No description provided for @adminSearchUsersHint.
  ///
  /// In en, this message translates to:
  /// **'Search users…'**
  String get adminSearchUsersHint;

  /// No description provided for @adminDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get adminDeactivate;

  /// No description provided for @adminReactivate.
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get adminReactivate;

  /// No description provided for @adminErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get adminErrorGeneric;

  /// No description provided for @adminParentNotFound.
  ///
  /// In en, this message translates to:
  /// **'Parent account not found.'**
  String get adminParentNotFound;

  /// No description provided for @adminLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to link parent to baby.'**
  String get adminLinkFailed;

  /// No description provided for @adminUnlinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove link.'**
  String get adminUnlinkFailed;

  /// No description provided for @transferWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Warning: Permanent Data Loss'**
  String get transferWarningTitle;

  /// No description provided for @transferWarningBody.
  ///
  /// In en, this message translates to:
  /// **'Once this transfer is accepted, your hospital will permanently lose access to this baby’s records and measurements. Export the data before proceeding.'**
  String get transferWarningBody;

  /// No description provided for @transferWarningConfirm.
  ///
  /// In en, this message translates to:
  /// **'I Understand, Continue'**
  String get transferWarningConfirm;

  /// No description provided for @cancelTransfer.
  ///
  /// In en, this message translates to:
  /// **'Cancel Transfer'**
  String get cancelTransfer;

  /// No description provided for @adminEditUser.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get adminEditUser;

  /// No description provided for @adminEditUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Account'**
  String get adminEditUserTitle;

  /// No description provided for @adminSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get adminSaveChanges;

  /// No description provided for @auditEventAccountEdit.
  ///
  /// In en, this message translates to:
  /// **'Account Edited'**
  String get auditEventAccountEdit;

  /// No description provided for @auditEventTransferCancel.
  ///
  /// In en, this message translates to:
  /// **'Transfer Cancelled'**
  String get auditEventTransferCancel;

  /// No description provided for @parentNoConnectionTitle.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get parentNoConnectionTitle;

  /// No description provided for @parentNoConnectionBody.
  ///
  /// In en, this message translates to:
  /// **'An internet connection is needed to load your baby\'s data for the first time. Please connect and try again.'**
  String get parentNoConnectionBody;

  /// No description provided for @parentSyncLabel.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get parentSyncLabel;

  /// No description provided for @retryAction.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryAction;

  /// No description provided for @transferInvalidHospitalCode.
  ///
  /// In en, this message translates to:
  /// **'Incorrect hospital code.'**
  String get transferInvalidHospitalCode;

  /// No description provided for @transferSameHospitalError.
  ///
  /// In en, this message translates to:
  /// **'Cannot transfer to your own hospital.'**
  String get transferSameHospitalError;

  /// No description provided for @transferConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Transfer'**
  String get transferConfirmTitle;

  /// No description provided for @transferConfirmBabyLabel.
  ///
  /// In en, this message translates to:
  /// **'Baby being transferred'**
  String get transferConfirmBabyLabel;

  /// No description provided for @transferConfirmYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, Continue'**
  String get transferConfirmYes;

  /// No description provided for @deviceUnpair.
  ///
  /// In en, this message translates to:
  /// **'Unpair'**
  String get deviceUnpair;

  /// No description provided for @linkTo.
  ///
  /// In en, this message translates to:
  /// **'Link To'**
  String get linkTo;

  /// No description provided for @selectParentAccount.
  ///
  /// In en, this message translates to:
  /// **'Select parent account'**
  String get selectParentAccount;

  /// No description provided for @searchParentHint.
  ///
  /// In en, this message translates to:
  /// **'Search parents…'**
  String get searchParentHint;

  /// No description provided for @searchLinksHint.
  ///
  /// In en, this message translates to:
  /// **'Search links…'**
  String get searchLinksHint;

  /// No description provided for @noParentAccountsFound.
  ///
  /// In en, this message translates to:
  /// **'No parent accounts found.'**
  String get noParentAccountsFound;

  /// No description provided for @linkParentFab.
  ///
  /// In en, this message translates to:
  /// **'Link A Parent'**
  String get linkParentFab;

  /// No description provided for @adminLinkAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This parent is already linked to this baby.'**
  String get adminLinkAlreadyExists;
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
