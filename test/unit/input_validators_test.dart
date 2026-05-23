import 'package:flutter_test/flutter_test.dart';
import 'package:bilirubin/utils/input_validators.dart';

void main() {
  group('validateName', () {
    test('accepts a valid name', () {
      expect(validateName('Alice'), isNull);
    });

    test('rejects empty string', () {
      expect(validateName(''), isNotNull);
    });

    test('rejects whitespace-only string', () {
      expect(validateName('   '), isNotNull);
    });

    test('rejects name exceeding 100 characters', () {
      expect(validateName('A' * 101), isNotNull);
    });

    test('accepts exactly 100 characters', () {
      expect(validateName('A' * 100), isNull);
    });

    test('rejects name with control characters', () {
      expect(validateName('Alice\x01Bob'), isNotNull);
    });

    test('rejects null', () {
      expect(validateName(null), isNotNull);
    });
  });

  group('validateWeightString', () {
    test('accepts valid weight', () {
      expect(validateWeightString('3.5'), isNull);
    });

    test('accepts comma decimal separator', () {
      expect(validateWeightString('3,5'), isNull);
    });

    test('rejects non-numeric string', () {
      expect(validateWeightString('abc'), isNotNull);
    });

    test('rejects weight below minimum (0.4)', () {
      expect(validateWeightString('0.3'), isNotNull);
    });

    test('rejects weight above maximum (8.0)', () {
      expect(validateWeightString('8.1'), isNotNull);
    });

    test('accepts boundary values', () {
      expect(validateWeightString('0.4'), isNull);
      expect(validateWeightString('8.0'), isNull);
    });

    test('rejects empty string', () {
      expect(validateWeightString(''), isNotNull);
    });
  });

  group('validateDateOfBirth', () {
    test('accepts a recent date', () {
      final dob = DateTime.now().subtract(const Duration(days: 10));
      expect(validateDateOfBirth(dob), isNull);
    });

    test('rejects null', () {
      expect(validateDateOfBirth(null), isNotNull);
    });

    test('rejects future date', () {
      final future = DateTime.now().add(const Duration(days: 1));
      expect(validateDateOfBirth(future), isNotNull);
    });

    test('rejects date more than 2 years ago', () {
      final old = DateTime.now().subtract(const Duration(days: 365 * 3));
      expect(validateDateOfBirth(old), isNotNull);
    });
  });

  group('isBilirubinAcceptable', () {
    test('accepts value in range', () {
      expect(isBilirubinAcceptable(10.0), isTrue);
    });

    test('accepts boundary values', () {
      expect(isBilirubinAcceptable(0.0), isTrue);
      expect(isBilirubinAcceptable(30.0), isTrue);
    });

    test('rejects negative value', () {
      expect(isBilirubinAcceptable(-1.0), isFalse);
    });

    test('rejects value above 30', () {
      expect(isBilirubinAcceptable(30.1), isFalse);
    });
  });

  group('sanitiseName', () {
    test('trims leading and trailing whitespace', () {
      expect(sanitiseName('  Alice  '), 'Alice');
    });

    test('collapses internal whitespace runs', () {
      expect(sanitiseName('Alice   Bob'), 'Alice Bob');
    });
  });

  group('parseWeight', () {
    test('parses dot decimal', () {
      expect(parseWeight('3.5'), 3.5);
    });

    test('parses comma decimal', () {
      expect(parseWeight('3,5'), 3.5);
    });

    test('returns null for non-numeric', () {
      expect(parseWeight('abc'), isNull);
    });
  });
}
