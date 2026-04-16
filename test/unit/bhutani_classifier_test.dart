import 'package:flutter_test/flutter_test.dart';
import 'package:bilirubin/models/bhutani_zone.dart';
import 'package:bilirubin/utils/bhutani_classifier.dart';

void main() {
  group('interpolateBoundary', () {
    test('returns first anchor value at minimum hours', () {
      // At hour 3 (min), the low boundary should be 0 (interpolated from (0,0)→(12,5))
      // Actually at hour 3, it's between (0,0) and (12,5): t=(3-0)/(12-0)=0.25 → 0+0.25*5 = 1.25
      final v = interpolateBoundary(kBoundaryLow, 3);
      expect(v, closeTo(1.25, 0.01));
    });

    test('returns last anchor value at maximum hours', () {
      final v = interpolateBoundary(kBoundaryLow, 120);
      expect(v, 14.0);
    });

    test('clamps values below minimum to minimum', () {
      final atMin = interpolateBoundary(kBoundaryLow, 3);
      final below = interpolateBoundary(kBoundaryLow, 0);
      // 0 is clamped to kNomogramMinHours (3)
      expect(below, atMin);
    });

    test('clamps values above maximum to last anchor', () {
      final atMax = interpolateBoundary(kBoundaryLow, 120);
      final above = interpolateBoundary(kBoundaryLow, 200);
      expect(above, atMax);
    });

    test('interpolates linearly between anchors', () {
      // kBoundaryHighIntermediate: (24, 11.0) → (48, 13.5)
      // At hour 36: t = (36-24)/(48-24) = 0.5, v = 11.0 + 0.5*(13.5-11.0) = 12.25
      final v = interpolateBoundary(kBoundaryHighIntermediate, 36);
      expect(v, closeTo(12.25, 0.01));
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
      // At 24h, low boundary ≈ 8.0. A value of 2 mg/dL should be low.
      expect(classify(24, 2.0), BhutaniZone.low);
    });

    test('classifies value just above veryHigh boundary as veryHigh', () {
      // At 48h, veryHigh boundary = 18.0. Value 19 should be veryHigh.
      expect(classify(48, 19.0), BhutaniZone.veryHigh);
    });

    test('classifies value between high and veryHigh as high', () {
      // At 48h: veryHigh=18, high=15.5. Value 16 → high zone.
      expect(classify(48, 16.0), BhutaniZone.high);
    });

    test('classifies value between highIntermediate and high as highIntermediate', () {
      // At 48h: high=15.5, highIntermediate=13.5. Value 14.5 → highIntermediate.
      expect(classify(48, 14.5), BhutaniZone.highIntermediate);
    });

    test('classifies value between low and highIntermediate as intermediate', () {
      // At 48h: highIntermediate=13.5, low=11.0. Value 12 → intermediate.
      expect(classify(48, 12.0), BhutaniZone.intermediate);
    });

    test('handles age at 72 hours correctly', () {
      // At 72h: veryHigh=20, high=17.5, hi=15, low=12.5
      expect(classify(72, 21.0), BhutaniZone.veryHigh);
      expect(classify(72, 18.0), BhutaniZone.high);
      expect(classify(72, 16.0), BhutaniZone.highIntermediate);
      expect(classify(72, 13.5), BhutaniZone.intermediate);
      expect(classify(72, 5.0), BhutaniZone.low);
    });
  });

  group('effectiveYMax', () {
    test('returns default when all values are below it', () {
      expect(effectiveYMax([5.0, 10.0, 15.0]), 23.0);
    });

    test('expands when a value exceeds the default', () {
      final result = effectiveYMax([5.0, 25.0]);
      // ceil(25/2)*2 + 2 = 28
      expect(result, greaterThan(23.0));
    });

    test('returns default for empty input', () {
      expect(effectiveYMax([]), 23.0);
    });
  });
}
