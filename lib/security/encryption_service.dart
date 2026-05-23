import 'dart:typed_data';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart';
import 'package:bilirubin/core/constants.dart';

/// AES-256-GCM encryption service for protecting image blobs on disk.
///
/// Key lifecycle:
///   • On first use, a 32-byte random key is generated, base64-encoded,
///     and stored in the platform secure enclave via [FlutterSecureStorage].
///   • Subsequent calls retrieve the same key.
///
/// Ciphertext layout (bytes):
///   [12 B IV][N B ciphertext][16 B GCM authentication tag]
class EncryptionService {
  EncryptionService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  Uint8List? _cachedKey;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Encrypts [plaintext] and returns the combined IV + ciphertext + tag blob.
  Future<Uint8List> encrypt(Uint8List plaintext) async {
    final key = await _getOrCreateKey();
    final iv = _generateIV();

    final cipher = GCMBlockCipher(AESEngine())
      ..init(true, AEADParameters(KeyParameter(key), 128, iv, Uint8List(0)));

    final ciphertext = cipher.process(plaintext);
    // Layout: 12B IV | ciphertext+tag (PointyCastle appends tag to ciphertext)
    return Uint8List.fromList([...iv, ...ciphertext]);
  }

  /// Decrypts a blob produced by [encrypt].
  ///
  /// Throws [InvalidCipherTextException] if authentication fails (tampered).
  Future<Uint8List> decrypt(Uint8List blob) async {
    if (blob.length < 12 + 16) {
      throw ArgumentError('Blob too short to be valid ciphertext.');
    }
    final key = await _getOrCreateKey();
    final iv = blob.sublist(0, 12);
    final ciphertextWithTag = blob.sublist(12);

    final cipher = GCMBlockCipher(AESEngine())
      ..init(false, AEADParameters(KeyParameter(key), 128, iv, Uint8List(0)));

    return cipher.process(ciphertextWithTag);
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<Uint8List> _getOrCreateKey() async {
    if (_cachedKey != null) return _cachedKey!;

    final stored = await _storage.read(key: kImageKeyAlias);
    if (stored != null) {
      _cachedKey = _base64Decode(stored);
      return _cachedKey!;
    }

    // Generate a fresh 256-bit key.
    final key = _generateKey();
    await _storage.write(key: kImageKeyAlias, value: _base64Encode(key));
    _cachedKey = key;
    return key;
  }

  Uint8List _generateKey() {
    final rng = FortunaRandom();
    rng.seed(KeyParameter(_platformSeed(32)));
    return rng.nextBytes(32);
  }

  Uint8List _generateIV() {
    final rng = FortunaRandom();
    rng.seed(KeyParameter(_platformSeed(32)));
    return rng.nextBytes(12);
  }

  /// Builds a seed for the PRNG from [dart:math] SecureRandom.
  Uint8List _platformSeed(int length) {
    final r = Random.secure();
    return Uint8List.fromList(List.generate(length, (_) => r.nextInt(256)));
  }

  static String _base64Encode(Uint8List bytes) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    final buf = StringBuffer();
    for (int i = 0; i < bytes.length; i += 3) {
      final b0 = bytes[i];
      final b1 = i + 1 < bytes.length ? bytes[i + 1] : 0;
      final b2 = i + 2 < bytes.length ? bytes[i + 2] : 0;
      buf
        ..writeCharCode(chars.codeUnitAt(b0 >> 2))
        ..writeCharCode(chars.codeUnitAt(((b0 & 3) << 4) | (b1 >> 4)))
        ..writeCharCode(i + 1 < bytes.length
            ? chars.codeUnitAt(((b1 & 0xf) << 2) | (b2 >> 6))
            : 61)
        ..writeCharCode(i + 2 < bytes.length
            ? chars.codeUnitAt(b2 & 0x3f)
            : 61);
    }
    return buf.toString();
  }

  static Uint8List _base64Decode(String encoded) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    final cleaned = encoded.replaceAll('=', '');
    final bytes = <int>[];
    for (int i = 0; i < cleaned.length; i += 4) {
      final b0 = chars.indexOf(cleaned[i]);
      final b1 = i + 1 < cleaned.length ? chars.indexOf(cleaned[i + 1]) : 0;
      final b2 = i + 2 < cleaned.length ? chars.indexOf(cleaned[i + 2]) : 0;
      final b3 = i + 3 < cleaned.length ? chars.indexOf(cleaned[i + 3]) : 0;
      bytes.add((b0 << 2) | (b1 >> 4));
      if (i + 2 < cleaned.length) bytes.add(((b1 & 0xf) << 4) | (b2 >> 2));
      if (i + 3 < cleaned.length) bytes.add(((b2 & 3) << 6) | b3);
    }
    return Uint8List.fromList(bytes);
  }
}
