import 'dart:io';
import 'package:get/get.dart';
import 'package:screen_protector/screen_protector.dart';

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
    // ScreenProtector works on iOS/Android
    try {
      await ScreenProtector.preventScreenshotOn();
      await ScreenProtector.protectDataLeakageWithBlur(); // For iOS background
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _disableSecureMode() async {
    try {
      await ScreenProtector.preventScreenshotOff();
      await ScreenProtector.protectDataLeakageWithBlurOff();
    } catch (e) {
      // Handle error
    }
  }
}
