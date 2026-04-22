import 'package:flutter_test/flutter_test.dart';
import 'package:bilirubin/models/bhutani_zone.dart';
import 'package:bilirubin/utils/bhutani_classifier.dart';

void main() {
  group('interpolateBoundary', () {
    test('interpolates linearly between anchors', () {
      // kBoundaryHighIntermediate: (24, 6.5) → (36, 8.5)
      // At hour 30: t = (30-24)/(36-24) = 0.5, v = 6.5 + 0.5*2.0 = 7.5
      final v = interpolateBoundary(kBoundaryHighIntermediate, 30);
      expect(v, closeTo(7.5, 0.01));
    });

    test('clamps values below minimum to minimum', () {
      final atMin = interpolateBoundary(kBoundaryHighIntermediate, 3);
      final below = interpolateBoundary(kBoundaryHighIntermediate, 0);
      expect(below, atMin);
    });

    test('clamps values above maximum (168) to plateau value', () {
      final atMax = interpolateBoundary(kBoundaryVeryHigh, 168);
      final above = interpolateBoundary(kBoundaryVeryHigh, 200);
      expect(above, atMax);
    });

    test('plateau holds at 168 h for all three boundaries', () {
      expect(interpolateBoundary(kBoundaryVeryHigh, 168), closeTo(18.0, 0.01));
      expect(interpolateBoundary(kBoundaryHigh, 168), closeTo(15.0, 0.01));
      expect(interpolateBoundary(kBoundaryHighIntermediate, 168), closeTo(12.5, 0.01));
    });
  });

  group('classify – four-zone system', () {
    test('returns null for negative bilirubin', () {
      expect(classify(24, -1), isNull);
    });

    test('returns null for bilirubin > 30', () {
      expect(classify(24, 31), isNull);
    });

    test('classifies clearly low value as low', () {
      // At 48h, 40th-percentile boundary ≈ 9.5. A value of 5.0 is low.
      expect(classify(48, 5.0), BhutaniZone.low);
    });

    test('classifies value above 95th percentile as high', () {
      // At 48h, 95th-percentile boundary = 15.0. Value 16 → high.
      expect(classify(48, 16.0), BhutaniZone.high);
    });

    test('classifies value between 75th and 95th as highIntermediate', () {
      // At 48h: 95th=15.0, 75th=12.5. Value 13.5 → highIntermediate.
      expect(classify(48, 13.5), BhutaniZone.highIntermediate);
    });

    test('classifies value between 40th and 75th as lowIntermediate', () {
      // At 48h: 75th=12.5, 40th=9.5. Value 11.0 → lowIntermediate.
      expect(classify(48, 11.0), BhutaniZone.lowIntermediate);
    });

    test('handles age at 72 hours correctly', () {
      // At 72h: 95th=17.5, 75th=14.5, 40th=12.0
      expect(classify(72, 18.0), BhutaniZone.high);
      expect(classify(72, 16.0), BhutaniZone.highIntermediate);
      expect(classify(72, 13.0), BhutaniZone.lowIntermediate);
      expect(classify(72, 5.0), BhutaniZone.low);
    });

    test('handles age beyond 168 h (clamped to plateau)', () {
      // Beyond 168h is clamped; classification still works using plateau values.
      // At 200h (clamped to 168): 95th=18.0. Value 20 → high.
      expect(classify(200, 20.0), BhutaniZone.high);
      // Value 3 → low.
      expect(classify(200, 3.0), BhutaniZone.low);
    });
  });

  group('effectiveYMax', () {
    test('returns default when all values are below it', () {
      expect(effectiveYMax([5.0, 10.0, 15.0]), 25.0);
    });

    test('expands when a value exceeds the default', () {
      final result = effectiveYMax([5.0, 27.0]);
      // ceil(27/5)*5 + 5 = 35
      expect(result, greaterThan(25.0));
    });

    test('returns default for empty input', () {
      expect(effectiveYMax([]), 25.0);
    });
  });
}
