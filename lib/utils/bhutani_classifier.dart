// Pediatrics 2000;106(1):17-22 before clinical use.

import 'package:bilirubin/models/bhutani_zone.dart';
import 'package:bilirubin/core/constants.dart';

// Boundary curves
// Each list is a piecewise-linear curve of (ageHours, bilirubinMgDl) anchors.
// Values represent the LOWER threshold of the zone above the named percentile.
// Curves plateau after ~96 h (dashed region in the Bhutani nomogram image).

/// 95th percentile curve – above this line = High Risk Zone.
const List<(double, double)> kBoundaryVeryHigh = [
  (0, 0),
  (12, 6.0),
  (24, 10.5),
  (36, 13.0),
  (48, 15.0),
  (60, 16.5),
  (72, 17.5),
  (96, 18.0),
  (120, 18.0),
  (168, 18.0),
];

/// 75th percentile curve – above this line = High Intermediate Risk Zone.
const List<(double, double)> kBoundaryHigh = [
  (0, 0),
  (12, 4.5),
  (24, 8.5),
  (36, 11.0),
  (48, 12.5),
  (60, 13.5),
  (72, 14.5),
  (96, 15.0),
  (120, 15.0),
  (168, 15.0),
];

/// 40th percentile curve – above this line = Low Intermediate Risk Zone.
const List<(double, double)> kBoundaryHighIntermediate = [
  (0, 0),
  (12, 3.5),
  (24, 6.5),
  (36, 8.5),
  (48, 9.5),
  (60, 10.5),
  (72, 12.0),
  (96, 12.5),
  (120, 12.5),
  (168, 12.5),
];

// Public API

/// Linearly interpolates [bilirubinMgDl] threshold from [curve] at [ageHours].
///
/// [ageHours] is clamped to [kNomogramMinHours]..[kNomogramMaxHours].
double interpolateBoundary(
  List<(double, double)> curve,
  double ageHours,
) {
  final h = ageHours.clamp(kNomogramMinHours, kNomogramMaxHours);
  for (int i = 0; i < curve.length - 1; i++) {
    final (x0, y0) = curve[i];
    final (x1, y1) = curve[i + 1];
    if (h >= x0 && h <= x1) {
      final t = (h - x0) / (x1 - x0);
      return y0 + t * (y1 - y0);
    }
  }
  return curve.last.$2;
}

/// Classifies a measurement point into one of the four [BhutaniZone]s.
///
/// Returns `null` if [ageHours] or [bilirubinMgDl] are outside plausible ranges.
BhutaniZone? classify(double ageHours, double bilirubinMgDl) {
  if (ageHours < 0 || bilirubinMgDl < 0 || bilirubinMgDl > kBilirubinMaxMgDl) {
    return null;
  }
  if (bilirubinMgDl >= interpolateBoundary(kBoundaryVeryHigh, ageHours)) {
    return BhutaniZone.high;
  }
  if (bilirubinMgDl >= interpolateBoundary(kBoundaryHigh, ageHours)) {
    return BhutaniZone.highIntermediate;
  }
  if (bilirubinMgDl >= interpolateBoundary(kBoundaryHighIntermediate, ageHours)) {
    return BhutaniZone.lowIntermediate;
  }
  return BhutaniZone.low;
}

/// Computes the effective Y-axis maximum for the chart, auto-expanding
/// beyond [kNomogramDefaultYMax] if any measurement exceeds it.
double effectiveYMax(Iterable<double> bilirubinValues) {
  double maxVal = kNomogramDefaultYMax;
  for (final v in bilirubinValues) {
    if (v > maxVal) {
      maxVal = (v / 5).ceil() * 5.0 + 5.0;
    }
  }
  return maxVal;
}
