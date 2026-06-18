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
    usernameController = TextEditingController(text: 'admin@rsudsoebandi.gov');
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
    
    // Simulate API network call delay for modern feel with progress loader
    await Future.delayed(const Duration(milliseconds: 1500));
    
    isLoading.value = false;

    // Save authentications state to secure storage
    SecureStorageServices.to.writeBool('is_logged_in', true);
    SecureStorageServices.to.writeBool('is_locked', false);
    
    Get.snackbar(
      'Sign In Success',
      'Selamat datang kembali di Review Management System RSD Soebandi!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade50,
      colorText: Colors.green.shade900,
      icon: const Icon(Icons.check_circle_outline, color: Colors.green),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );

    Get.offAllNamed(Routes.home);
  }

  Future<void> unlock() async {
    if (!(lockFormKey.currentState?.validate() ?? false)) return;
    
    isLoading.value = true;
    
    // Simulate unlock check
    await Future.delayed(const Duration(milliseconds: 1200));
    
    isLoading.value = false;

    // Save locked status to secure storage
    SecureStorageServices.to.writeBool('is_locked', false);

    Get.snackbar(
      'System Unlocked',
      'Sesi admin berhasil dipulihkan.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.indigo.shade50,
      colorText: Colors.indigo.shade900,
      icon: const Icon(Icons.lock_open_rounded, color: Colors.indigo),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );

    Get.offAllNamed(Routes.home);
  }
}

