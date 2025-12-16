import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

class SecretHomeController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _enableSecureMode();
  }

  @override
  void onClose() {
    _disableSecureMode();
    super.onClose();
  }

  Future<void> _enableSecureMode() async {
    if (Platform.isAndroid) {
      try {
        await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
      } catch (e) {
        // Handle error or ignore
      }
    }
  }

  Future<void> _disableSecureMode() async {
    if (Platform.isAndroid) {
      try {
        await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
      } catch (e) {
        // Handle error
      }
    }
  }
}
