import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pointycastle/export.dart';
import 'package:bilirubin/core/constants.dart';

/// Manages local app access control via PIN and/or biometric authentication.
class AppLockService {
  AppLockService({
    FlutterSecureStorage? storage,
    LocalAuthentication? localAuth,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _localAuth = localAuth ?? LocalAuthentication();

  final FlutterSecureStorage _storage;
  final LocalAuthentication _localAuth;

  // ── Lock state ─────────────────────────────────────────────────────────────

  Future<bool> isLockEnabled() async {
    final v = await _storage.read(key: kAppLockEnabledAlias);
    return v == 'true';
  }

  // ── PIN management ─────────────────────────────────────────────────────────

  /// Stores a SHA-256 + salt hash of [pin]. Enables lock automatically.
  Future<void> enablePin(String pin) async {
    final salt = _randomBytes(32);
    final hash = _hashPin(pin, salt);
    await _storage.write(key: kPinSaltAlias, value: base64Encode(salt));
    await _storage.write(key: kPinHashAlias, value: base64Encode(hash));
    await _storage.write(key: kAppLockEnabledAlias, value: 'true');
  }

  /// Removes PIN and disables lock.
  Future<void> disableLock() async {
    await _storage.delete(key: kPinHashAlias);
    await _storage.delete(key: kPinSaltAlias);
    await _storage.write(key: kAppLockEnabledAlias, value: 'false');
  }

  /// Returns true if [pin] matches the stored hash.
  Future<bool> verifyPin(String pin) async {
    final saltB64 = await _storage.read(key: kPinSaltAlias);
    final hashB64 = await _storage.read(key: kPinHashAlias);
    if (saltB64 == null || hashB64 == null) return false;

    final salt = base64Decode(saltB64);
    final storedHash = base64Decode(hashB64);
    final candidate = _hashPin(pin, salt);
    return _constantTimeEquals(candidate, storedHash);
  }

  // ── Biometric ──────────────────────────────────────────────────────────────

  /// Returns true if biometric hardware is available and enrolled.
  Future<bool> canUseBiometric() async {
    try {
      final capable = await _localAuth.canCheckBiometrics;
      final supported = await _localAuth.isDeviceSupported();
      return capable && supported;
    } catch (_) {
      return false;
    }
  }

  /// Prompts the user for biometric authentication.
  /// Returns true on success, false on failure or cancellation.
  Future<bool> authenticateBiometric() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access the bilirubin app',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Uint8List _hashPin(String pin, Uint8List salt) {
    final digest = SHA256Digest();
    final input = Uint8List.fromList([
      ...utf8.encode(pin),
      ...salt,
    ]);
    return digest.process(input);
  }

  Uint8List _randomBytes(int length) {
    final r = Random.secure();
    return Uint8List.fromList(List.generate(length, (_) => r.nextInt(256)));
  }

  /// Constant-time comparison to prevent timing attacks.
  bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    int diff = 0;
    for (int i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}

/// Stub for platforms that don't support local_auth (Windows, Linux desktop).
@visibleForTesting
class NoOpAppLockService extends AppLockService {
  NoOpAppLockService() : super();

  @override
  Future<bool> canUseBiometric() async => false;

  @override
  Future<bool> authenticateBiometric() async => false;
}
