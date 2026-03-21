import '../models/models.dart';
import 'helpers.dart';

const List<double> bhutaniXAnchors = <double>[3, 12, 24, 48, 72, 96, 120];
const List<double> lowUpperY = <double>[1.0, 4.0, 6.0, 8.0, 9.0, 11.0, 11.0];
const List<double> intermediateUpperY = <double>[
  2.0,
  6.0,
  8.5,
  11.0,
  13.5,
  14.0,
  15.0,
];
const List<double> highInterUpperY = <double>[
  3.0,
  9.0,
  12.0,
  15.0,
  17.0,
  17.0,
  17.0,
];
const List<double> highUpperY = <double>[
  4.0,
  10.5,
  15.5,
  17.5,
  19.5,
  19.0,
  18.5,
];

double interpolateBhutaniBoundary({
  required List<double> yValues,
  required double ageHours,
}) {
  final clampedAge = ageHours.clamp(3, 120).toDouble();

  for (var index = 0; index < bhutaniXAnchors.length - 1; index++) {
    final x1 = bhutaniXAnchors[index];
    final x2 = bhutaniXAnchors[index + 1];
    if (clampedAge >= x1 && clampedAge <= x2) {
      final y1 = yValues[index];
      final y2 = yValues[index + 1];
      final ratio = (clampedAge - x1) / (x2 - x1);
      return y1 + ((y2 - y1) * ratio);
    }
  }

  return yValues.last;
}

BhutaniRiskZone? classifyBhutaniPoint({
  required double? ageHours,
  required double? bilirubinMgDl,
}) {
  if (ageHours == null || bilirubinMgDl == null) {
    return null;
  }
  if (ageHours.isNaN || ageHours.isInfinite) {
    return null;
  }
  if (bilirubinMgDl.isNaN || bilirubinMgDl.isInfinite) {
    return null;
  }

  final normalizedY = bilirubinMgDl < 0 ? 0 : bilirubinMgDl;
  final lowUpper = interpolateBhutaniBoundary(
    yValues: lowUpperY,
    ageHours: ageHours,
  );
  final intermediateUpper = interpolateBhutaniBoundary(
    yValues: intermediateUpperY,
    ageHours: ageHours,
  );
  final highIntermediateUpper = interpolateBhutaniBoundary(
    yValues: highInterUpperY,
    ageHours: ageHours,
  );
  final highUpper = interpolateBhutaniBoundary(
    yValues: highUpperY,
    ageHours: ageHours,
  );

  if (normalizedY <= lowUpper) {
    return BhutaniRiskZone.lowRiskZone;
  }
  if (normalizedY <= intermediateUpper) {
    return BhutaniRiskZone.intermediateRiskZone;
  }
  if (normalizedY <= highIntermediateUpper) {
    return BhutaniRiskZone.highIntermediateRiskZone;
  }
  if (normalizedY <= highUpper) {
    return BhutaniRiskZone.highRiskZone;
  }
  return BhutaniRiskZone.veryHighRiskZone;
}

double bhutaniYMaxForLevels(Iterable<double> bilirubinLevels) {
  final highest = bilirubinLevels.fold<double>(
    23,
    (current, level) => level > current ? level : current,
  );
  return nextNiceTickAbove(highest);
}
