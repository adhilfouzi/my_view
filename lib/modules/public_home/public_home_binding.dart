import 'package:get/get.dart';
import 'public_home_controller.dart';

class PublicHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PublicHomeController>(() => PublicHomeController());
  }
}
