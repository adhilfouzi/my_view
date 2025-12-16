import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class EncryptionService extends GetxService {
  static EncryptionService get to => Get.find();
  final _storage = const FlutterSecureStorage();

  late enc.Key _key;
  late enc.Encrypter _encrypter;

  static const String keyMaster = 'master_key_v1';
  bool isReady = false;

  Future<EncryptionService> init() async {
    String? storedKey = await _storage.read(key: keyMaster);

    if (storedKey == null) {
      _key = enc.Key.fromSecureRandom(32);
      await _storage.write(key: keyMaster, value: _key.base64);
    } else {
      _key = enc.Key.fromBase64(storedKey);
    }

    // For simplicity using a fixed IV or random one per file.
    // Ideally store IV with file (prepend it).
    // For this demo, we'll use a fixed IV for simplicity, BUT THIS IS LESS SECURE.
    // Better: prepend IV to file content.
    _encrypter = enc.Encrypter(enc.AES(_key));
    isReady = true;
    return this;
  }

  Uint8List encryptData(Uint8List data) {
    final iv = enc.IV.fromSecureRandom(16);
    final encrypted = _encrypter.encryptBytes(data, iv: iv);
    // Combine IV + Encrypted Data
    return Uint8List.fromList(iv.bytes + encrypted.bytes);
  }

  Uint8List decryptData(Uint8List data) {
    // Extract IV (first 16 bytes)
    final iv = enc.IV(data.sublist(0, 16));
    final encryptedBytes = enc.Encrypted(data.sublist(16));

    return Uint8List.fromList(_encrypter.decryptBytes(encryptedBytes, iv: iv));
  }
}
