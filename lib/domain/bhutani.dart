import 'dart:math';

import 'package:bilirubin_companion/data/models.dart';

const List<double> xAnchors = [3, 12, 24, 48, 72, 96, 120];
const List<double> lowUpperY = [1.0, 4.0, 6.0, 8.0, 9.0, 11.0, 11.0];
const List<double> intermediateUpperY = [2.0, 6.0, 8.5, 11.0, 13.5, 14.0, 15.0];
const List<double> highInterUpperY = [3.0, 9.0, 12.0, 15.0, 17.0, 17.0, 17.0];
const List<double> highUpperY = [4.0, 10.5, 15.5, 17.5, 19.5, 19.0, 18.5];

double _lerp(double a, double b, double t) => a + ((b - a) * t);

double _interp(List<double> values, double x) {
  if (x <= xAnchors.first) return values.first;
  if (x >= xAnchors.last) return values.last;
  for (var i = 0; i < xAnchors.length - 1; i++) {
    final start = xAnchors[i];
    final end = xAnchors[i + 1];
    if (x >= start && x <= end) {
      final t = (x - start) / (end - start);
      return _lerp(values[i], values[i + 1], t);
    }
  }
  return values.last;
}

BhutaniZone? classifyBhutaniZone({required double ageHours, required double bilirubinMgDl}) {
  if (bilirubinMgDl.isNaN || bilirubinMgDl.isInfinite) return null;
  final x = ageHours.clamp(3, 120).toDouble();
  final y = max(0, bilirubinMgDl);
  final lowUpper = _interp(lowUpperY, x);
  final intermediateUpper = _interp(intermediateUpperY, x);
  final highInterUpper = _interp(highInterUpperY, x);
  final highUpper = _interp(highUpperY, x);

  if (y <= lowUpper) return BhutaniZone.lowRiskZone;
  if (y <= intermediateUpper) return BhutaniZone.intermediateRiskZone;
  if (y <= highInterUpper) return BhutaniZone.highIntermediateRiskZone;
  if (y <= highUpper) return BhutaniZone.highRiskZone;
  return BhutaniZone.veryHighRiskZone;
}

double computeDynamicYMax(List<double> values) {
  const base = 23.0;
  final maxValue = values.isEmpty ? base : max(base, values.reduce(max));
  if (maxValue <= base) return base;
  if (maxValue <= 26) return 26;
  if (maxValue <= 30) return 30;
  if (maxValue <= 35) return 35;
  return ((maxValue / 5).ceil() * 5).toDouble();
}
