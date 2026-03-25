// TODO(medical): Verify all boundary values against Bhutani et al.
// Pediatrics 2000;106(1):17-22 before clinical use.

import 'package:bilirubin/models/bhutani_zone.dart';
import 'package:bilirubin/core/constants.dart';

// ── Boundary curves ───────────────────────────────────────────────────────────
// Each list is a piecewise-linear curve of (ageHours, bilirubinMgDl) anchors.
// Values represent the UPPER threshold of the named zone.

/// 95th percentile curve – upper bound of the "high" zone / lower bound of "veryHigh".
const List<(double, double)> kBoundaryVeryHigh = [
  (0, 0),
  (12, 12.0),
  (24, 15.0),
  (48, 18.0),
  (72, 20.0),
  (96, 21.5),
  (120, 22.0),
];

/// 75th percentile curve – upper bound of "highIntermediate" / lower bound of "high".
const List<(double, double)> kBoundaryHigh = [
  (0, 0),
  (12, 10.0),
  (24, 13.0),
  (48, 15.5),
  (72, 17.5),
  (96, 19.0),
  (120, 19.5),
];

/// 40th percentile curve – upper bound of "intermediate" / lower bound of "highIntermediate".
const List<(double, double)> kBoundaryHighIntermediate = [
  (0, 0),
  (12, 8.0),
  (24, 11.0),
  (48, 13.5),
  (72, 15.0),
  (96, 16.0),
  (120, 16.5),
];

/// 10th percentile curve – upper bound of "low" / lower bound of "intermediate".
const List<(double, double)> kBoundaryLow = [
  (0, 0),
  (12, 5.0),
  (24, 8.0),
  (48, 11.0),
  (72, 12.5),
  (96, 13.5),
  (120, 14.0),
];

// ── Public API ────────────────────────────────────────────────────────────────

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

/// Classifies a measurement point into a [BhutaniZone].
///
/// Returns `null` if [ageHours] or [bilirubinMgDl] are outside plausible ranges.
BhutaniZone? classify(double ageHours, double bilirubinMgDl) {
  if (ageHours < 0 || bilirubinMgDl < 0 || bilirubinMgDl > kBilirubinMaxMgDl) {
    return null;
  }
  if (bilirubinMgDl >= interpolateBoundary(kBoundaryVeryHigh, ageHours)) {
    return BhutaniZone.veryHigh;
  }
  if (bilirubinMgDl >= interpolateBoundary(kBoundaryHigh, ageHours)) {
    return BhutaniZone.high;
  }
  if (bilirubinMgDl >= interpolateBoundary(kBoundaryHighIntermediate, ageHours)) {
    return BhutaniZone.highIntermediate;
  }
  if (bilirubinMgDl >= interpolateBoundary(kBoundaryLow, ageHours)) {
    return BhutaniZone.intermediate;
  }
  return BhutaniZone.low;
}

/// Computes the effective Y-axis maximum for the chart, auto-expanding
/// beyond [kNomogramDefaultYMax] if any measurement exceeds it.
double effectiveYMax(Iterable<double> bilirubinValues) {
  double maxVal = kNomogramDefaultYMax;
  for (final v in bilirubinValues) {
    if (v > maxVal) {
      maxVal = (v / 2).ceil() * 2.0 + 2.0;
    }
  }
  return maxVal;
}
