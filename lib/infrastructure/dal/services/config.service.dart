part of 'main.services.dart'; // Load decryption keys from secure storage

class ConfigEnvironments extends GetxService {
  static ConfigEnvironments get to => Get.find<ConfigEnvironments>();
  final Rx<Environments> _currentEnvironments = Environments.local.obs;

  static String urlDecryptionKey = '';
  static String urlDecryptionIv = '';

  Environments get environments => _currentEnvironments.value;

  set setEnvironments(Environments environments) =>
      _currentEnvironments.value = environments;

  /// Initialise decryption keys from secure storage or .env
  Future<void> initialize() async {
    // Ensure SecureStorage loads the .env and sets the keys
    await SecureStorageServices.to.init();
  }
}
