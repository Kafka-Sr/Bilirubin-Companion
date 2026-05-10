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
  String get showPreviousBilirubin => 'Show Previous Readings';

  @override
  String get showReadingsOutside168h => 'Show Readings >168 h';

  @override
  String get bhutaniOutsideRangeNotice =>
      'Reminder: This Bhutani nomogram only displays bilirubin readings from ages 0 to 168 hours. Readings beyond this age range are in purple dots.';

  @override
  String get bhutaniCurrentBeyond168h =>
      'The baby\'s age is currently beyond 168 hours.';

  @override
  String get axisLabelTotalSerumBilirubin => 'Total Serum Bilirubin (mg/dL)';

  @override
  String get axisLabelAgeHours => 'Age (h)';

  @override
  String get zoneLow => 'Low Risk';

  @override
  String get zoneLowIntermediate => 'Low Intermediate Risk';

  @override
  String get zoneHighIntermediate => 'High Intermediate Risk';

  @override
  String get zoneHigh => 'High Risk';

  @override
  String get recommendationHeader => 'Recommendation';

  @override
  String get recommendationLow =>
      'Bilirubin levels are within the safe range (below 40th percentile). Continue routine monitoring. No immediate action required.';

  @override
  String get recommendationLowIntermediate =>
      'Bilirubin is in the low intermediate zone (40th–75th percentile). Repeat measurement in 8–12 hours and monitor closely.';

  @override
  String get recommendationHighIntermediate =>
      'Bilirubin is in the high intermediate zone (75th–95th percentile). Repeat measurement in 4–8 hours. Consider initiating phototherapy per AAP 2022 guidelines.';

  @override
  String get recommendationHigh =>
      'Bilirubin is critically elevated (above 95th percentile). Immediate intervention required. Escalate to a neonatologist urgently.';

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
  String get metadataEdit => 'Edit Baby';

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
  String get settingsPiLanTitle => 'Raspberry Pi LAN';

  @override
  String get settingsPiAddressLabel => 'Pi address or URL';

  @override
  String get settingsPiAddressHint =>
      '192.168.1.50:8080 or http://raspi.local:8080';

  @override
  String get settingsPiSave => 'Save Pi address';

  @override
  String get settingsPiClear => 'Clear';

  @override
  String get settingsPiBeaconUse => 'Use';

  @override
  String get settingsPiBeaconDescription =>
      'If the phone and Pi are on the same Wi-Fi network, the app can discover the Pi automatically by beacon. Supabase still stores the synced history.';

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
  String get exportAction => 'Export';

  @override
  String exportedTo(String filename) {
    return 'Exported to $filename';
  }

  @override
  String get exportSheetTitle => 'Export Data';

  @override
  String get exportFileName => 'File Name';

  @override
  String get exportSaveLocation => 'Save Location';

  @override
  String get exportBrowse => 'Browse';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageIndonesian => 'Indonesian';

  @override
  String get languageGerman => 'German';

  @override
  String get zoneLowFull => 'Low Risk Zone';

  @override
  String get zoneLowIntermediateFull => 'Low Intermediate Risk Zone';

  @override
  String get zoneHighIntermediateFull => 'High Intermediate Risk Zone';

  @override
  String get zoneHighFull => 'High Risk Zone';

  @override
  String get deviceConnecting => 'Connecting…';

  @override
  String get deviceConnectedLabel => 'Connected:';

  @override
  String get deviceConnect => 'Connect';

  @override
  String get deviceDisconnect => 'Disconnect';

  @override
  String get selectBaby => 'Select baby';

  @override
  String get searchBabiesHint => 'Search babies…';

  @override
  String archivedCount(int count) {
    return 'Archived ($count)';
  }

  @override
  String get archivedBabies => 'Archived Babies';

  @override
  String get archiveBabyAction => 'Archive Baby';

  @override
  String archiveBabyContent(String name) {
    return 'Archive \"$name\"? The record will be preserved and can be restored later.';
  }

  @override
  String get archiveAction => 'Archive';

  @override
  String get permanentDeleteTitle => 'Permanently Delete Baby';

  @override
  String permanentDeleteContent(String name) {
    return 'Permanently delete \"$name\"? All data will be lost and cannot be recovered.';
  }

  @override
  String get deleteForever => 'Delete Forever';

  @override
  String get restoreAction => 'Restore';

  @override
  String get permanentlyDeleteTooltip => 'Permanently delete';

  @override
  String get signIn => 'Sign In';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signUp => 'Sign Up';

  @override
  String get createAccount => 'Create Account';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get signInSubtitle => 'Sign in to your hospital account';

  @override
  String get signUpPrompt => 'Don\'t have an account? Sign up';

  @override
  String get accountCreatedMessage =>
      'Account created. Check your email to confirm, then sign in.';

  @override
  String get unexpectedError => 'An unexpected error occurred.';

  @override
  String get accountSection => 'Account';

  @override
  String get adminPanel => 'Admin Panel';

  @override
  String get staffManagement => 'Staff Management';

  @override
  String get staffManagementSubtitle => 'Add or remove nurses and admins';

  @override
  String get parentAccess => 'Parent Access';

  @override
  String get parentAccessSubtitle => 'Link parent accounts to babies';

  @override
  String get patientTransfers => 'Patient Transfers';

  @override
  String get patientTransfersSubtitle =>
      'Initiate or accept transfers between hospitals';

  @override
  String get addStaff => 'Add Staff';

  @override
  String get addStaffTitle => 'Add Staff Member';

  @override
  String get removeStaffTitle => 'Remove Staff Member';

  @override
  String removeStaffContent(String email) {
    return 'Remove $email from the hospital? They will lose access immediately.';
  }

  @override
  String get removeFromHospital => 'Remove from hospital';

  @override
  String get roleNurse => 'Nurse';

  @override
  String get roleStaff => 'Staff';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get temporaryPassword => 'Temporary Password';

  @override
  String get noStaffYet => 'No staff yet.';

  @override
  String get you => 'You';

  @override
  String get parentSearchDescription =>
      'Search for a parent by their email address, then link them to a baby.';

  @override
  String get parentEmailLabel => 'Parent email';

  @override
  String get searchAction => 'Search';

  @override
  String get selectBabyToLink => 'Select baby to link:';

  @override
  String get linkParentToBaby => 'Link Parent to Baby';

  @override
  String get linkedSuccess => 'Successfully linked.';

  @override
  String parentFound(String email) {
    return 'Parent found: $email';
  }

  @override
  String get initiateTransfer => 'Initiate Transfer';

  @override
  String get sendRequest => 'Send Request';

  @override
  String get acceptAction => 'Accept';

  @override
  String get rejectAction => 'Reject';

  @override
  String get cancelRequest => 'Cancel Request';

  @override
  String get noTransferRequests => 'No transfer requests.';

  @override
  String get destinationHospitalCode => 'Destination hospital code';

  @override
  String get waitingForHospital => 'Waiting for hospital';

  @override
  String get waitingForHospitalBody =>
      'Your account has been created. Please ask the hospital staff to link your account to your baby\'s record.';

  @override
  String get validationPasswordLength =>
      'Password must be at least 8 characters.';

  @override
  String get previousReadings => 'Previous Readings';

  @override
  String get loggedInAs => 'Logged in as';

  @override
  String get hospitalLabel => 'Hospital';

  @override
  String get contactAdminHelp =>
      'Need help? Contact your hospital\'s administrator.';

  @override
  String get simulationMode => 'Simulation Mode';
}
