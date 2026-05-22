import 'package:flutter_test/flutter_test.dart';
import 'package:bilirubin/models/bhutani_zone.dart';
import 'package:bilirubin/utils/bhutani_classifier.dart';

void main() {
  group('interpolateBoundary', () {
    test('returns first anchor value at minimum hours', () {
      // At hour 3 (min), kBoundaryHighIntermediate: (0,0)→(12,3.5)
      // t=(3-0)/(12-0)=0.25 → 0+0.25*3.5 = 0.875
      final v = interpolateBoundary(kBoundaryHighIntermediate, 3);
      expect(v, closeTo(0.875, 0.01));
    });

    test('returns last anchor value at maximum hours', () {
      final v = interpolateBoundary(kBoundaryHighIntermediate, 120);
      expect(v, 12.5);
    });

    test('clamps values below minimum to minimum', () {
      final atMin = interpolateBoundary(kBoundaryHighIntermediate, 3);
      final below = interpolateBoundary(kBoundaryHighIntermediate, 0);
      // 0 is clamped to kNomogramMinHours (3)
      expect(below, atMin);
    });

    test('clamps values above maximum to last anchor', () {
      final atMax = interpolateBoundary(kBoundaryHighIntermediate, 120);
      final above = interpolateBoundary(kBoundaryHighIntermediate, 200);
      expect(above, atMax);
    });

    test('interpolates linearly between anchors', () {
      // kBoundaryHighIntermediate has an explicit anchor at (36, 8.5)
      final v = interpolateBoundary(kBoundaryHighIntermediate, 36);
      expect(v, closeTo(8.5, 0.01));
    });
  });

  group('classify', () {
    test('returns null for negative bilirubin', () {
      expect(classify(24, -1), isNull);
    });

    test('returns null for bilirubin > 30', () {
      expect(classify(24, 31), isNull);
    });

    test('classifies clearly low value as low', () {
      // At 24h, kBoundaryHighIntermediate ≈ 6.5. A value of 2 mg/dL should be low.
      expect(classify(24, 2.0), BhutaniZone.low);
    });

    test('classifies value above high-risk boundary as high', () {
      // At 48h, kBoundaryVeryHigh = 15.0. Value 19 should be high.
      expect(classify(48, 19.0), BhutaniZone.high);
    });

    test('classifies value between highIntermediate and high as highIntermediate', () {
      // At 48h: high=15.0, highIntermediate=12.5. Value 14.5 → highIntermediate.
      expect(classify(48, 14.5), BhutaniZone.highIntermediate);
    });

    test('classifies value between lowIntermediate and highIntermediate as lowIntermediate', () {
      // At 48h: highIntermediate=12.5, lowIntermediate=9.5. Value 12 → lowIntermediate.
      expect(classify(48, 12.0), BhutaniZone.lowIntermediate);
    });

    test('handles age at 72 hours correctly', () {
      // At 72h: high boundary=17.5, highIntermediate=14.5, lowIntermediate=12.0
      expect(classify(72, 21.0), BhutaniZone.high);
      expect(classify(72, 18.0), BhutaniZone.high);
      expect(classify(72, 16.0), BhutaniZone.highIntermediate);
      expect(classify(72, 13.5), BhutaniZone.lowIntermediate);
      expect(classify(72, 5.0), BhutaniZone.low);
    });
  });

  group('effectiveYMax', () {
    test('returns default when all values are below it', () {
      expect(effectiveYMax([5.0, 10.0, 15.0]), 25.0);
    });

    test('expands when a value exceeds the default', () {
      final result = effectiveYMax([5.0, 30.0]);
      expect(result, greaterThan(25.0));
    });

    test('returns default for empty input', () {
      expect(effectiveYMax([]), 25.0);
    });
  });
}
