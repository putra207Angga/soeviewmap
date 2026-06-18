part of 'main.services.dart';

class ConfigEnvironments extends GetxService {
  static ConfigEnvironments get to => Get.find<ConfigEnvironments>();
  final Rx<Environments> _currentEnvironments = Environments.local.obs;

  static String urlDecryptionKey = '';
  static String urlDecryptionIv = '';

  Environments get environments => _currentEnvironments.value;

  set setEnvironments(Environments environments) =>
      _currentEnvironments.value = environments;
}
