import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart';

class EncryptionService {
  EncryptionService(this.storage);

  final FlutterSecureStorage storage;
  static const keyName = 'imageEncryptionKey';

  Future<Uint8List> _getKey() async {
    final existing = await storage.read(key: keyName);
    if (existing != null) {
      return Uint8List.fromList(existing.codeUnits.take(32).toList());
    }
    final rand = Random.secure();
    final key = Uint8List.fromList(List<int>.generate(32, (_) => rand.nextInt(256)));
    await storage.write(key: keyName, value: String.fromCharCodes(key));
    return key;
  }

  Future<Uint8List> encrypt(Uint8List plain) async {
    final key = await _getKey();
    final nonce = Uint8List.fromList(List<int>.generate(12, (_) => Random.secure().nextInt(256)));
    final cipher = GCMBlockCipher(AESEngine())
      ..init(true, AEADParameters(KeyParameter(key), 128, nonce, Uint8List(0)));
    final out = cipher.process(plain);
    return Uint8List.fromList([...nonce, ...out]);
  }

  Future<Uint8List> decrypt(Uint8List encrypted) async {
    if (encrypted.length < 13) return encrypted;
    final key = await _getKey();
    final nonce = encrypted.sublist(0, 12);
    final data = encrypted.sublist(12);
    final cipher = GCMBlockCipher(AESEngine())
      ..init(false, AEADParameters(KeyParameter(key), 128, nonce, Uint8List(0)));
    return cipher.process(data);
  }
}
