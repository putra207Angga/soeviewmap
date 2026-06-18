// Run with: dart tool/verify_decryption.dart
// ignore_for_file: avoid_print
import 'dart:io';
import 'package:soeviewmap/domain/main.domains.dart';
import 'package:soeviewmap/infrastructure/main.infrastructures.dart';

Map<String, String> loadEnv() {
  final env = <String, String>{};
  final file = File('.env');
  if (file.existsSync()) {
    final lines = file.readAsLinesSync();
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
        env[key] = cleanValue;
      }
    }
  }
  return env;
}

void main() {
  final env = loadEnv();
  final urlKey = env['URL_ENCRYPTION_KEY'];
  final urlIv = env['URL_ENCRYPTION_IV'];

  if (urlKey == null || urlIv == null) {
    print('❌ Error: .env file or encryption keys are missing');
    return;
  }

  // Populate ConfigEnvironments variables like the app does at startup
  ConfigEnvironments.urlDecryptionKey = urlKey;
  ConfigEnvironments.urlDecryptionIv = urlIv;

  print('=== Verifying URL Decryption ===');
  for (var envType in Environments.values) {
    final decryptedUrl = envType.url;
    print('${envType.label.toUpperCase()}:');
    print('  Encrypted: ${envType.encryptedUrl}');
    print('  Decrypted: $decryptedUrl');

    if (envType == Environments.local) {
      const expected = 'http://pdesoebandi.id/informasi/';
      if (decryptedUrl == expected) {
        print('  ✅ LOCAL URL decryption verified successfully!');
      } else {
        print('  ❌ LOCAL URL decryption failed! Expected: $expected');
      }
    }
  }
}
