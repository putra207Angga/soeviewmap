part of 'main.middleware.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final isLoggedIn = SecureStorageServices.to.readBool(
      'is_logged_in',
      defaultValue: false,
    );
    final isLocked = SecureStorageServices.to.readBool(
      'is_locked',
      defaultValue: false,
    );

    // If trying to access any route other than authentifikasi:
    if (route != Routes.authentifikasi) {
      if (!isLoggedIn) {
        // Redirect to Login Screen
        return const RouteSettings(
          name: Routes.authentifikasi,
          arguments: {'mode': 'login'},
        );
      }
      if (isLocked) {
        // Redirect to Lock Screen
        return const RouteSettings(
          name: Routes.authentifikasi,
          arguments: {'mode': 'lock'},
        );
      }
    } else {
      // If trying to access authentifikasi page:
      // If logged in and NOT locked, redirect back to Home
      if (isLoggedIn && !isLocked) {
        return RouteSettings(name: Routes.home);
      }
    }
    return null;
  }
}
