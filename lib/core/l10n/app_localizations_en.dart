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
  String get deviceDisconnected => 'Not paired';

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
  String get fieldDob => 'Date & Time of Birth';

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
  String get settingsPiLanTitle => 'Biligun LAN';

  @override
  String get settingsPiAddressLabel => 'Biligun address or URL';

  @override
  String get settingsPiAddressHint => '10.42.0.1:7878';

  @override
  String get settingsHotspotTitle => 'Biligun Pairing';

  @override
  String get settingsHotspotInstructions =>
      'Connect your phone to the Biligun\'s Wi-Fi hotspot, then enter its address below.';

  @override
  String get settingsPiSave => 'Connect';

  @override
  String get settingsPiClear => 'Disconnect';

  @override
  String get settingsPiBeaconUse => 'Use';

  @override
  String get settingsPiBeaconDescription =>
      'If the phone and Biligun are on the same Wi-Fi network, the app can discover the Biligun automatically by beacon. Supabase still stores the synced history.';

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
  String get deviceConnecting => 'Pairing…';

  @override
  String get deviceConnectedLabel => 'Connected:';

  @override
  String get deviceConnect => 'Connect';

  @override
  String get deviceDisconnect => 'Disconnect';

  @override
  String deviceConnectedTo(String displayName) {
    return 'Paired with $displayName';
  }

  @override
  String get deviceConnectionError => 'Failed to pair';

  @override
  String get selectBaby => 'Select baby';

  @override
  String get searchBabiesHint => 'Search babies…';

  @override
  String archivedCount(int count) {
    return 'Archived ($count)';
  }

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
  String get archivedBabies => 'View Archived Babies';

  @override
  String get pdfTitle => 'Bilirubin Report';

  @override
  String get pdfExportedAt => 'Exported:';

  @override
  String get pdfGeneratedBy => 'Generated by Bilirubin App';

  @override
  String get pdfPatientInfo => 'Patient Information';

  @override
  String get pdfBirthWeight => 'Birth Weight';

  @override
  String get pdfAgeAtExport => 'Age at Export';

  @override
  String get pdfMeasurementsTitle => 'Measurements';

  @override
  String get pdfColDateTime => 'Date/Time';

  @override
  String get pdfColBilirubin => 'Bilirubin (mg/dL)';

  @override
  String get pdfColZone => 'Zone';

  @override
  String get pdfColDevice => 'Device';

  @override
  String get cloudNotConfigured => 'Can\'t connect to the server';

  @override
  String get cloudSyncing => 'Syncing…';

  @override
  String get cloudSyncError => 'Sync error';

  @override
  String get cloudSynced => 'Synced';

  @override
  String get noReadings => 'No Readings';

  @override
  String get syncButton => 'Synchronise';

  @override
  String get metadataTob => 'Time of Birth';

  @override
  String get errorAccountDeactivated =>
      'Your account has been deactivated. Contact your hospital administrator.';

  @override
  String get loginSubtitle => 'Sign in to continue';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginSignIn => 'Sign In';

  @override
  String get loginEmailValidation => 'Enter your email';

  @override
  String get loginPasswordValidation => 'Enter your password';

  @override
  String get loginContactAdmin =>
      'Contact your hospital administrator to get an account.';

  @override
  String get loginUnexpectedError => 'An unexpected error occurred.';

  @override
  String get adminPanelTitle => 'Admin Panel';

  @override
  String get adminUserManagementTitle => 'User Management';

  @override
  String get adminUserManagementSubtitle =>
      'Manage all accounts — staff, admin, and parent';

  @override
  String get adminParentAccessTitle => 'Parent Access';

  @override
  String get adminParentAccessSubtitle => 'Link and unlink parents to babies';

  @override
  String get adminTransfersTitle => 'Baby Transfers';

  @override
  String get adminTransfersSubtitle =>
      'Initiate and manage inter-hospital transfers';

  @override
  String get adminAuditTitle => 'Audit Events Log';

  @override
  String get adminAuditSubtitle =>
      'View a log of sensitive actions in your hospital';

  @override
  String get userManagementTitle => 'User Management';

  @override
  String get addAccountFab => 'Add Account';

  @override
  String get noAccountsFound => 'No accounts found.';

  @override
  String get roleAll => 'All';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleStaff => 'Staff';

  @override
  String get roleParent => 'Parent';

  @override
  String get deactivateAccountTitle => 'Deactivate Account';

  @override
  String get reactivateAccountTitle => 'Reactivate Account';

  @override
  String deactivateConfirmContent(String name, String role) {
    return 'Deactivate $name ($role)? They will lose access immediately.';
  }

  @override
  String reactivateConfirmContent(String name, String role) {
    return 'Reactivate $name ($role)? They will regain access.';
  }

  @override
  String get deactivatedLabel => 'Deactivated';

  @override
  String get selfLabel => '(you)';

  @override
  String get addAccountDialogTitle => 'Add Account';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get roleLabel => 'Role';

  @override
  String get passwordMinLength => 'Min 8 characters';

  @override
  String get createLabel => 'Create';

  @override
  String loadingUsersError(String error) {
    return 'Error loading users: $error';
  }

  @override
  String get parentAccessTitle => 'Parent Access';

  @override
  String get currentLinksTitle => 'Current Links';

  @override
  String get noParentLinksYet => 'No parent links yet.';

  @override
  String get linkParentSectionTitle => 'Link a Parent to a Baby';

  @override
  String get findParentStep => 'Step 1: Find parent account';

  @override
  String get parentEmailLabel => 'Parent email';

  @override
  String get searchLabel => 'Search';

  @override
  String get selectBabyStep => 'Step 2: Select baby';

  @override
  String get linkParentButton => 'Link Parent to Baby';

  @override
  String get unlinkParentTitle => 'Unlink Parent';

  @override
  String unlinkConfirmContent(String parent, String baby) {
    return 'Remove $parent\'s access to $baby?';
  }

  @override
  String get parentLinkedSuccess => 'Parent linked successfully.';

  @override
  String get babyTransfersTitle => 'Baby Transfers';

  @override
  String get outgoingTab => 'Outgoing';

  @override
  String get incomingTab => 'Incoming';

  @override
  String get initiateTransferFab => 'Initiate Transfer';

  @override
  String get noOutgoingTransfers => 'No outgoing transfers.';

  @override
  String get noIncomingTransfers => 'No incoming transfers.';

  @override
  String get acceptLabel => 'Accept';

  @override
  String get rejectLabel => 'Reject';

  @override
  String get initiateTransferDialogTitle => 'Initiate Transfer';

  @override
  String get babyLabel => 'Baby';

  @override
  String get targetHospitalCodeLabel => 'Target Hospital Code';

  @override
  String get hospitalCodeHint => 'e.g. RSU-01';

  @override
  String get sendLabel => 'Send';

  @override
  String get auditEventsLogTitle => 'Audit Events Log';

  @override
  String get auditAllFilter => 'All';

  @override
  String get auditNoEvents => 'No events found.';

  @override
  String get auditEventBabyCreate => 'Baby Created';

  @override
  String get auditEventBabyEdit => 'Baby Edited';

  @override
  String get auditEventBabyDelete => 'Baby Deleted';

  @override
  String get auditEventMeasurementCreate => 'Measurement Recorded';

  @override
  String get auditEventMeasurementDelete => 'Measurement Deleted';

  @override
  String get auditEventExport => 'Data Export';

  @override
  String get auditEventAccountCreate => 'Account Created';

  @override
  String get auditEventAccountDeactivate => 'Account Deactivated';

  @override
  String get auditEventAccountReactivate => 'Account Reactivated';

  @override
  String get auditEventParentLink => 'Parent Linked';

  @override
  String get auditEventParentUnlink => 'Parent Unlinked';

  @override
  String get auditEventDeviceAdd => 'Device Connected';

  @override
  String get auditEventTransferCreate => 'Transfer Initiated';

  @override
  String get auditEventTransferAccept => 'Transfer Accepted';

  @override
  String get auditEventTransferReject => 'Transfer Rejected';

  @override
  String get parentDashboardTitle => 'My Baby';

  @override
  String get signOutTooltip => 'Sign Out';

  @override
  String get awaitingLinkageTitle => 'Awaiting linkage';

  @override
  String awaitingLinkageBody(String email) {
    return 'Your account ($email) has not yet been linked to a baby by the hospital. Please contact your hospital staff.';
  }

  @override
  String get measurementsSectionTitle => 'Measurements';

  @override
  String get noMeasurementsParent => 'No measurements yet.';

  @override
  String get settingsAccountTitle => 'Account';

  @override
  String get signOutLabel => 'Sign Out';

  @override
  String get couldNotLoadProfile => 'Could not load profile.';
}
