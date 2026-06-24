import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../infrastructure/main.infrastructures.dart';

enum AuthMode { login, lock }

class AuthentifikasiController extends GetxController {
  final authMode = AuthMode.login.obs;

  // Form keys for validation
  final loginFormKey = GlobalKey<FormState>();
  final lockFormKey = GlobalKey<FormState>();

  // Text Editing Controllers
  late final TextEditingController usernameController;
  late final TextEditingController passwordController;
  late final TextEditingController lockPasswordController;

  // UI States
  final rememberMe = false.obs;
  final obscurePassword = true.obs;
  final obscureLockPassword = true.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    usernameController = TextEditingController(text: 'admin');
    passwordController = TextEditingController();
    lockPasswordController = TextEditingController();

    // Check routing arguments to determine default mode
    if (Get.arguments != null && Get.arguments is Map) {
      final modeArg = Get.arguments['mode'];
      if (modeArg == 'lock') {
        authMode.value = AuthMode.lock;
      } else {
        authMode.value = AuthMode.login;
      }
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    lockPasswordController.dispose();
    super.onClose();
  }

  void toggleObscurePassword() => obscurePassword.toggle();

  void toggleObscureLockPassword() => obscureLockPassword.toggle();

  void toggleRememberMe() => rememberMe.toggle();

  void switchToLogin() {
    authMode.value = AuthMode.login;
    passwordController.clear();
  }

  void switchToLock() {
    authMode.value = AuthMode.lock;
    lockPasswordController.clear();
  }

  Future<void> signIn() async {
    if (!(loginFormKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;

    try {
      final response = await AuthDao.login(
        username: usernameController.text,
        password: passwordController.text,
      );

      isLoading.value = false;

      if (response.statusCode == 200 && response.body != null) {
        final resBody = response.body!;
        final success = resBody['success'] as bool? ?? false;
        final message = resBody['message'] as String? ?? 'Login successful.';

        final appAccess = resBody['data']['app_access'] as num;

        if (success && (appAccess == 3 || appAccess == 0)) {
          final data = resBody['data'] as Map<String, dynamic>?;
          final token = data?['token'] as String? ?? '';

          if (token.isNotEmpty) {
            // Save authentication state and token to secure storage
            SecureStorageServices.to.write('token', token);
            SecureStorageServices.to.writeBool('is_logged_in', true);
            SecureStorageServices.to.writeBool('is_locked', false);

            Get.snackbar(
              'Sign In Success',
              message,
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.green.shade50,
              colorText: Colors.green.shade900,
              icon: const Icon(Icons.check_circle_outline, color: Colors.green),
              margin: const EdgeInsets.all(16),
              borderRadius: 12,
            );

            Get.offAllNamed(Routes.home);
            return;
          }
        }
      }

      // Handle login failure
      final errorMessage =
          response.body?['message'] ??
          response.statusText ??
          'Username atau Password salah.';
      Get.snackbar(
        'Sign In Gagal',
        errorMessage.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        icon: const Icon(Icons.error_outline_rounded, color: Colors.red),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat menghubungi server: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        icon: const Icon(Icons.error_outline_rounded, color: Colors.red),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  Future<void> unlock() async {
    if (!(lockFormKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;

    try {
      final response = await AuthDao.checkPin(lockPasswordController.text);
      isLoading.value = false;

      if (response.statusCode == 200 && response.body != null) {
        final resBody = response.body!;
        final success = resBody['success'] as bool? ?? false;
        final message =
            resBody['message'] as String? ?? 'Sesi admin berhasil dipulihkan.';

        if (success) {
          // Save locked status to secure storage
          SecureStorageServices.to.writeBool('is_locked', false);

          Get.snackbar(
            'System Unlocked',
            message,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.indigo.shade50,
            colorText: Colors.indigo.shade900,
            icon: const Icon(Icons.lock_open_rounded, color: Colors.indigo),
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );

          Get.offAllNamed(Routes.home);
          return;
        }
      }

      // Handle check-pin failure
      final errorMessage =
          response.body?['message'] ??
          response.statusText ??
          'PIN yang Anda masukkan salah.';
      Get.snackbar(
        'Unlock Gagal',
        errorMessage.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        icon: const Icon(Icons.error_outline_rounded, color: Colors.red),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat menghubungi server: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        icon: const Icon(Icons.error_outline_rounded, color: Colors.red),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }
}
