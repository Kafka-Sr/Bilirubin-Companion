import 'dart:math';

import 'models.dart';

const List<double> xAnchors = [3, 12, 24, 48, 72, 96, 120];
const List<double> lowUpperY = [1.0, 4.0, 6.0, 8.0, 9.0, 11.0, 11.0];
const List<double> intermediateUpperY = [2.0, 6.0, 8.5, 11.0, 13.5, 14.0, 15.0];
const List<double> highInterUpperY = [3.0, 9.0, 12.0, 15.0, 17.0, 17.0, 17.0];
const List<double> highUpperY = [4.0, 10.5, 15.5, 17.5, 19.5, 19.0, 18.5];

double clampX(double x) => x.clamp(3.0, 120.0);

double interpolate(double x, List<double> ys) {
  final clamped = clampX(x);
  for (var i = 0; i < xAnchors.length - 1; i++) {
    final x0 = xAnchors[i];
    final x1 = xAnchors[i + 1];
    if (clamped >= x0 && clamped <= x1) {
      final t = (clamped - x0) / (x1 - x0);
      return ys[i] + ((ys[i + 1] - ys[i]) * t);
    }
  }
  return ys.last;
}

BhutaniZone classifyBhutani({required double ageHours, required double bilirubin}) {
  final x = clampX(ageHours);
  final y = max(0, bilirubin);
  final lowUpper = interpolate(x, lowUpperY);
  final intermediateUpper = interpolate(x, intermediateUpperY);
  final highInterUpper = interpolate(x, highInterUpperY);
  final highUpper = interpolate(x, highUpperY);

  if (y <= lowUpper) return BhutaniZone.low;
  if (y <= intermediateUpper) return BhutaniZone.intermediate;
  if (y <= highInterUpper) return BhutaniZone.highIntermediate;
  if (y <= highUpper) return BhutaniZone.high;
  return BhutaniZone.veryHigh;
}

double chartYMax(Iterable<double> bilirubinValues) {
  final maxVal = bilirubinValues.isEmpty ? 23.0 : bilirubinValues.reduce(max);
  return max(23.0, (maxVal + 2).ceilToDouble());
}
