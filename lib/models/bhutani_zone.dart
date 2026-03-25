import 'package:flutter/material.dart';

/// The five Bhutani nomogram risk zones for neonatal hyperbilirubinemia.
enum BhutaniZone {
  /// Bilirubin below the 10th-percentile curve – lowest risk.
  low,

  /// Between 10th and 40th percentile curves.
  intermediate,

  /// Between 40th and 75th percentile curves.
  highIntermediate,

  /// Between 75th and 95th percentile curves.
  high,

  /// Above the 95th-percentile curve – highest risk.
  veryHigh;

  /// Display-friendly label (title case).
  String get label {
    switch (this) {
      case BhutaniZone.low:
        return 'Low Risk';
      case BhutaniZone.intermediate:
        return 'Intermediate Risk';
      case BhutaniZone.highIntermediate:
        return 'High Intermediate Risk';
      case BhutaniZone.high:
        return 'High Risk';
      case BhutaniZone.veryHigh:
        return 'Very High Risk';
    }
  }

  /// Localization key for the recommendation body text.
  String get recommendationKey {
    switch (this) {
      case BhutaniZone.low:
        return 'recommendationLow';
      case BhutaniZone.intermediate:
        return 'recommendationIntermediate';
      case BhutaniZone.highIntermediate:
        return 'recommendationHighIntermediate';
      case BhutaniZone.high:
        return 'recommendationHigh';
      case BhutaniZone.veryHigh:
        return 'recommendationVeryHigh';
    }
  }

  /// Colour associated with this zone (used in chart fills, cards, etc.).
  Color get color {
    switch (this) {
      case BhutaniZone.low:
        return const Color(0xFF2E7D32); // green-800
      case BhutaniZone.intermediate:
        return const Color(0xFF558B2F); // light-green-800
      case BhutaniZone.highIntermediate:
        return const Color(0xFFF57F17); // amber-900
      case BhutaniZone.high:
        return const Color(0xFFE65100); // deep-orange-900
      case BhutaniZone.veryHigh:
        return const Color(0xFFB71C1C); // red-900
    }
  }

  /// A lighter, semi-transparent fill variant for chart zone backgrounds.
  Color get fillColor => color.withValues(alpha: 0.20);
}
