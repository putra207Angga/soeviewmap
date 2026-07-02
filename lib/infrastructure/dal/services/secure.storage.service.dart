part of 'main.services.dart';

class SecureStorageServices extends GetxService {
  static SecureStorageServices get to => Get.find<SecureStorageServices>();
  final _storage = GetStorage();
  String _encryptionKey = 'SoebandiGoogleMapReviewKeySecret';

  bool _isInitialized = false;

  @override
  void onInit() {
    super.onInit();
    init();
  }

  // Initialize GetStorage and load encryption key from .env
  Future<SecureStorageServices> init() async {
    if (_isInitialized) return this;
    await GetStorage.init();
    await _loadEnvKey();
    _isInitialized = true;
    return this;
  }

  // Read external .env key from assets or local file
  Future<void> _loadEnvKey() async {
    String? envContent;

    // 1. Try reading from Flutter assets (.env)
    try {
      envContent = await rootBundle.loadString('.env');
      log("Loading from asset", name: 'SecStorageServices');
    } catch (e, er) {
      // Asset not found or failed to load
      log(
        "Loading failed from asset $e",
        name: 'SecStorageServices',
        error: er,
      );
    }

    // 2. Try reading from local file if asset load failed (for desktop/tests)
    if (envContent == null || envContent.isEmpty) {
      if (!kIsWeb) {
        try {
          var dir = Directory.current;
          File? foundFile;
          while (true) {
            final file = File('${dir.path}/.env');
            if (file.existsSync()) {
              foundFile = file;
              break;
            }
            final parent = dir.parent;
            if (parent.path == dir.path) {
              break;
            }
            dir = parent;
          }

          if (foundFile != null && foundFile.existsSync()) {
            envContent = await foundFile.readAsString();
          }
        } catch (e, er) {
          log(
            "Loading failed from local file $e",
            name: 'SecStorageServices',
            error: er,
          );
        }
      }
    }

    if (envContent != null && envContent.isNotEmpty) {
      try {
        final lines = envContent.split('\n');
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
        if (urlKey != null && urlIv != null) {
          return; // Success
        }
      } catch (e, er) {
        log(
          "Loading failed from parsing $e",
          name: 'SecStorageServices',
          error: er,
        );
      }
    }

    // 3. Fallback keys if both asset and file fail
    _encryptionKey = 'SoebandiGoogleMapReviewKeySecret';
    ConfigEnvironments.urlDecryptionKey = 'S0eb1sAppKey2026XXXXXXXXXX!@#\$%^';
    ConfigEnvironments.urlDecryptionIv = 'S0eb1sIV2026!@#\$';
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
