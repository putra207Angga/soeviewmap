part of 'main.navigations.dart';

class Routes {
  static Future<String> get initialRoute async {
    final isLoggedIn = SecureStorageServices.to.readBool(
      'is_logged_in',
      defaultValue: false,
    );
    final isLocked = SecureStorageServices.to.readBool(
      'is_locked',
      defaultValue: false,
    );

    if (!isLoggedIn) {
      return authentifikasi;
    }
    if (isLocked) {
      return authentifikasi;
    }
    return home;
  }

  static final home = '/home';
  static const authentifikasi = '/authentifikasi';
  static const balas = '/balas';
  static const dahsboard = '/dahsboard';
  static const review = '/review';
  static const template = '/template';
  static const logBot = '/log-bot';
}
