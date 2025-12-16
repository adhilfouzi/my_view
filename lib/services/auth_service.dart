import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../routes/app_pages.dart';

class AuthService extends GetxService with WidgetsBindingObserver {
  static AuthService get to => Get.find();
  final _storage = const FlutterSecureStorage();

  final RxBool isConfigured = false.obs;
  String? _storedHash;

  static const String keyPassword = 'secret_password_hash';
  static const String setupCode = '@init';

  Future<AuthService> init() async {
    WidgetsBinding.instance.addObserver(this);
    _storedHash = await _storage.read(key: keyPassword);
    isConfigured.value = _storedHash != null;
    return this;
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Auto Lock when backgrounded
      if (Get.currentRoute == Routes.secretHome) {
        Get.offAllNamed(Routes.home);
      }
    }
  }

  /// Verifies the input password against the stored hash.
  bool verifyPassword(String input) {
    if (_storedHash == null) return false;
    final inputHash = _hash(input);
    return inputHash == _storedHash;
  }

  /// Sets the secret password.
  Future<void> setPassword(String password) async {
    final hash = _hash(password);
    await _storage.write(key: keyPassword, value: hash);
    _storedHash = hash;
    isConfigured.value = true;
  }

  String _hash(String text) {
    final bytes = utf8.encode(text);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
