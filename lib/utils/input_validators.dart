import 'package:bilirubin/core/constants.dart';

/// Returns an error message string if [value] is invalid, or null if valid.
/// Designed for use with Flutter [FormField.validator].

/// Validates a baby name.
String? validateName(String? value) {
  if (value == null || value.trim().isEmpty) return 'Name is required.';
  final trimmed = value.trim();
  if (trimmed.length > kNameMaxLength) {
    return 'Name must be $kNameMaxLength characters or fewer.';
  }
  // Reject control characters (ASCII < 32, except common whitespace already trimmed)
  if (trimmed.codeUnits.any((c) => c < 32)) {
    return 'Name contains invalid characters.';
  }
  return null;
}

/// Validates a weight string (must be parseable and within range).
String? validateWeightString(String? value) {
  if (value == null || value.trim().isEmpty) return 'Weight is required.';
  final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
  if (parsed == null) return 'Enter a valid number.';
  return validateWeight(parsed);
}

/// Validates an already-parsed weight value.
String? validateWeight(double weight) {
  if (weight < kWeightMinKg || weight > kWeightMaxKg) {
    return 'Weight must be between $kWeightMinKg and $kWeightMaxKg kg.';
  }
  return null;
}

/// Validates a date of birth.
String? validateDateOfBirth(DateTime? value) {
  if (value == null) return 'Date of birth is required.';
  final now = DateTime.now();
  if (value.isAfter(now)) return 'Date of birth cannot be in the future.';
  final maxAge = now.subtract(const Duration(days: kBabyMaxAgeYears * 365));
  if (value.isBefore(maxAge)) {
    return 'Date of birth is too far in the past.';
  }
  return null;
}

/// Validates an incoming bilirubin value from the device.
/// Returns false if the value should be rejected for storage.
bool isBilirubinAcceptable(double value) =>
    value >= kBilirubinMinMgDl && value <= kBilirubinMaxMgDl;

/// Sanitises a baby name: trims whitespace and collapses internal runs.
String sanitiseName(String raw) =>
    raw.trim().replaceAll(RegExp(r'\s+'), ' ');

/// Parses a weight string tolerating comma as decimal separator.
double? parseWeight(String raw) =>
    double.tryParse(raw.trim().replaceAll(',', '.'));
