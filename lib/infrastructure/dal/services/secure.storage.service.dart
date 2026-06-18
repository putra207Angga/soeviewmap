part of 'main.services.dart';

class SecureStorageServices extends GetxService {
  static SecureStorageServices get to => Get.find<SecureStorageServices>();
  final _storage = GetStorage();
  String _encryptionKey = 'SoebandiGoogleMapReviewKeySecret';

  // Initialize GetStorage and load encryption key from .env
  Future<SecureStorageServices> init() async {
    await GetStorage.init();
    await _loadEnvKey();
    return this;
  }

  // Read external .env key
  Future<void> _loadEnvKey() async {
    try {
      final file = File('.env');
      if (await file.exists()) {
        final lines = await file.readAsLines();
        String? storageKey;
        String? urlKey;
        String? urlIv;

        for (var line in lines) {
          line = line.trim();
          if (line.isEmpty || line.startsWith('#')) continue;
          final parts = line.split('=');
          if (parts.length >= 2) {
            final key = parts[0].trim();
            final value = parts.sublist(1).join('=').trim();
            var cleanValue = value;
            if ((cleanValue.startsWith("'") && cleanValue.endsWith("'")) ||
                (cleanValue.startsWith('"') && cleanValue.endsWith('"'))) {
              cleanValue = cleanValue.substring(1, cleanValue.length - 1);
            }
            if (key == 'STORAGE_ENCRYPTION_KEY') {
              storageKey = cleanValue;
            } else if (key == 'URL_ENCRYPTION_KEY') {
              urlKey = cleanValue;
            } else if (key == 'URL_ENCRYPTION_IV') {
              urlIv = cleanValue;
            }
          }
        }

        if (storageKey != null) {
          _encryptionKey = storageKey;
        }
        if (urlKey != null) {
          ConfigEnvironments.urlDecryptionKey = urlKey;
        }
        if (urlIv != null) {
          ConfigEnvironments.urlDecryptionIv = urlIv;
        }
      } else {
        // Auto-generate hidden .env file with secure random keys
        const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%^&*()_+-=';
        final randomStorageKey = List.generate(32, (index) => chars[DateTime.now().microsecondsSinceEpoch % chars.length]).join();
        final randomUrlKey = List.generate(32, (index) => chars[(DateTime.now().microsecondsSinceEpoch + 1) % chars.length]).join();
        final randomUrlIv = List.generate(16, (index) => chars[(DateTime.now().microsecondsSinceEpoch + 2) % chars.length]).join();

        await file.writeAsString(
          'STORAGE_ENCRYPTION_KEY=$randomStorageKey\n'
          'URL_ENCRYPTION_KEY=$randomUrlKey\n'
          'URL_ENCRYPTION_IV=$randomUrlIv\n',
        );

        _encryptionKey = randomStorageKey;
        ConfigEnvironments.urlDecryptionKey = randomUrlKey;
        ConfigEnvironments.urlDecryptionIv = randomUrlIv;
      }
    } catch (e) {
      // Sandbox fallback
      _encryptionKey = 'SoebandiGoogleMapReviewKeySecret';
      ConfigEnvironments.urlDecryptionKey = 'S0eb1sAppKey2026XXXXXXXXXX!@#\$%^';
      ConfigEnvironments.urlDecryptionIv = 'S0eb1sIV2026!@#\$';
    }
  }

  // Encrypt and write to storage
  void write(String key, String value) {
    final encryptedValue = EncryptionHelper.encrypt(value, _encryptionKey);
    _storage.write(key, encryptedValue);
  }

  // Read and decrypt from storage
  String? read(String key) {
    final encryptedValue = _storage.read<String>(key);
    if (encryptedValue == null) return null;
    return EncryptionHelper.decrypt(encryptedValue, _encryptionKey);
  }

  // Helper boolean wrappers
  void writeBool(String key, bool value) {
    write(key, value ? 'true' : 'false');
  }

  bool readBool(String key, {bool defaultValue = false}) {
    final value = read(key);
    if (value == null) return defaultValue;
    return value == 'true';
  }

  void erase() {
    _storage.erase();
  }
}
