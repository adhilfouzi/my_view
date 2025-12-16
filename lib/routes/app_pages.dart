import 'package:get/get.dart';
import 'app_routes.dart';
import '../modules/public_home/public_home_binding.dart';
import '../modules/public_home/public_home_view.dart';
import '../modules/secret_home/secret_home_binding.dart';
import '../modules/secret_home/secret_home_view.dart';

export 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.home;

  static final routes = [
    GetPage(
      name: Routes.home,
      page: () => const PublicHomeView(),
      binding: PublicHomeBinding(),
    ),
    GetPage(
      name: Routes.secretHome,
      page: () => const SecretHomeView(),
      binding: SecretHomeBinding(),
    ),
  ];
}
