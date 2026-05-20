import 'package:flutter/material.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';

/// The four Bhutani nomogram risk zones for neonatal hyperbilirubinemia.
///
/// Zones are based on Bhutani et al., Pediatrics 2000;106(1):17-22.
enum BhutaniZone {
  /// Below the 40th-percentile curve – lowest risk.
  low,

  /// Between the 40th and 75th percentile curves.
  lowIntermediate,

  /// Between the 75th and 95th percentile curves.
  highIntermediate,

  /// Above the 95th-percentile curve – highest risk.
  high;

  /// Display-friendly label (title case). Prefer [localizedLabel] when a
  /// [BuildContext] is available.
  String get label {
    switch (this) {
      case BhutaniZone.low:
        return 'Low Risk';
      case BhutaniZone.lowIntermediate:
        return 'Low Intermediate Risk';
      case BhutaniZone.highIntermediate:
        return 'High Intermediate Risk';
      case BhutaniZone.high:
        return 'High Risk';
    }
  }

  /// Localized short label (e.g. "Risiko Rendah" in Indonesian).
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case BhutaniZone.low:
        return l10n.zoneLow;
      case BhutaniZone.lowIntermediate:
        return l10n.zoneLowIntermediate;
      case BhutaniZone.highIntermediate:
        return l10n.zoneHighIntermediate;
      case BhutaniZone.high:
        return l10n.zoneHigh;
    }
  }

  /// Localized full zone-name label (e.g. "Zona Risiko Rendah").
  String localizedFullLabel(AppLocalizations l10n) {
    switch (this) {
      case BhutaniZone.low:
        return l10n.zoneLowFull;
      case BhutaniZone.lowIntermediate:
        return l10n.zoneLowIntermediateFull;
      case BhutaniZone.highIntermediate:
        return l10n.zoneHighIntermediateFull;
      case BhutaniZone.high:
        return l10n.zoneHighFull;
    }
  }

  /// Colour associated with this zone (used in chart fills, cards, etc.).
  Color get color {
    switch (this) {
      case BhutaniZone.low:
        return const Color(0xFF2E7D32); // green-800
      case BhutaniZone.lowIntermediate:
        return const Color(0xFFF57F17); // amber-900
      case BhutaniZone.highIntermediate:
        return const Color(0xFFE65100); // deep-orange-900
      case BhutaniZone.high:
        return const Color(0xFFB71C1C); // red-900
    }
  }

  /// A lighter, semi-transparent fill variant for chart zone backgrounds.
  Color get fillColor => color.withValues(alpha: 0.20);
}
