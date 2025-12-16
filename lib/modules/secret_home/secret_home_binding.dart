import 'package:get/get.dart';
import 'secret_home_controller.dart';

class SecretHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SecretHomeController>(() => SecretHomeController());
  }
}
