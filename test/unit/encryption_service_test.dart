import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bilirubin/security/encryption_service.dart';

// Minimal in-memory implementation of FlutterSecureStorage for testing.
class _FakeStorage implements FlutterSecureStorage {
  final _store = <String, String>{};

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      _store[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _store.remove(key);
    } else {
      _store[key] = value;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('EncryptionService', () {
    late EncryptionService svc;

    setUp(() {
      svc = EncryptionService(storage: _FakeStorage());
    });

    test('encrypt then decrypt roundtrip returns original bytes', () async {
      final plaintext = Uint8List.fromList([1, 2, 3, 4, 5]);
      final cipher = await svc.encrypt(plaintext);
      final recovered = await svc.decrypt(cipher);
      expect(recovered, equals(plaintext));
    });

    test('ciphertext differs from plaintext', () async {
      final plaintext = Uint8List.fromList(List.generate(32, (i) => i));
      final cipher = await svc.encrypt(plaintext);
      expect(cipher, isNot(equals(plaintext)));
    });

    test('two encryptions of same plaintext produce different ciphertexts (random IV)', () async {
      final plaintext = Uint8List.fromList([42, 43, 44]);
      final c1 = await svc.encrypt(plaintext);
      final c2 = await svc.encrypt(plaintext);
      expect(c1, isNot(equals(c2)));
    });

    test('decrypt throws on tampered ciphertext', () async {
      final plaintext = Uint8List.fromList([10, 20, 30]);
      final cipher = await svc.encrypt(plaintext);
      // Flip a byte in the ciphertext portion (after 12-byte IV).
      cipher[20] ^= 0xFF;
      expect(() => svc.decrypt(cipher), throwsA(anything));
    });

    test('decrypt throws if blob is too short', () {
      expect(
        () => svc.decrypt(Uint8List.fromList([1, 2, 3])),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('same key is reused across multiple calls', () async {
      final a = Uint8List.fromList([1]);
      final b = Uint8List.fromList([2]);
      final ca = await svc.encrypt(a);
      final cb = await svc.encrypt(b);
      // Both should decrypt correctly (same key was used).
      expect(await svc.decrypt(ca), equals(a));
      expect(await svc.decrypt(cb), equals(b));
    });
  });
}
