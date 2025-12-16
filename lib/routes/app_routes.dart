abstract class Routes {
  Routes._();
  static const home = _Paths.home;
  static const secretHome = _Paths.secretHome;
}

abstract class _Paths {
  _Paths._();
  static const home = '/';
  static const secretHome = '/secret-home';
}
