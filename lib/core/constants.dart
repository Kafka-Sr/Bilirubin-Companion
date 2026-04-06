// ignore_for_file: constant_identifier_names

/// App-wide constants for the bilirubin companion app.
library;

// ── Bilirubin bounds ──────────────────────────────────────────────────────────
/// Minimum plausible bilirubin value from the device (mg/dL).
const double kBilirubinMinMgDl = 0.0;

/// Maximum plausible bilirubin value accepted for storage (mg/dL).
const double kBilirubinMaxMgDl = 30.0;

// ── Weight bounds ─────────────────────────────────────────────────────────────
/// Minimum acceptable newborn weight in kg.
const double kWeightMinKg = 0.4;

/// Maximum acceptable newborn weight in kg.
const double kWeightMaxKg = 10.0;

// ── Baby metadata ─────────────────────────────────────────────────────────────
/// Maximum name length (characters) accepted for storage.
const int kNameMaxLength = 100;

/// Maximum reasonable age of a baby in years (used for DoB validation).
const int kBabyMaxAgeYears = 2;

// ── Bhutani nomogram ──────────────────────────────────────────────────────────
/// Minimum postnatal age (hours) on the nomogram x-axis.
const double kNomogramMinHours = 3.0;

/// Maximum postnatal age (hours) on the nomogram x-axis.
const double kNomogramMaxHours = 120.0;

/// Default maximum Y-axis value for the nomogram (mg/dL).
const double kNomogramDefaultYMax = 23.0;

/// X-axis tick positions (hours of life).
const List<double> kNomogramXTicks = [3, 12, 24, 48, 72, 96, 120];

// ── Audit event types ─────────────────────────────────────────────────────────
const String kAuditExport = 'export';
const String kAuditBabyEdit = 'baby_edit';
const String kAuditBabyDelete = 'baby_delete';
const String kAuditMeasurementDelete = 'measurement_delete';

// ── Secure storage keys ───────────────────────────────────────────────────────
const String kImageKeyAlias = 'bilirubin_image_key_v1';
const String kPinHashAlias = 'bilirubin_pin_hash_v1';
const String kPinSaltAlias = 'bilirubin_pin_salt_v1';
const String kAppLockEnabledAlias = 'bilirubin_lock_enabled_v1';

// ── Shared preferences keys ───────────────────────────────────────────────────
const String kPrefThemeMode = 'theme_mode';
const String kPrefLocale = 'locale';

// ── Fake device ───────────────────────────────────────────────────────────────
const String kFakeDeviceId = 'FAKE-001';
const String kFakeDeviceName = 'Simulator';

// ── Export ────────────────────────────────────────────────────────────────────
const int kExportJsonVersion = 1;
