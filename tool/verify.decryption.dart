// Run with: dart tool/verify.decryption.dart
// ignore_for_file: avoid_print
import 'dart:io';
import 'package:encrypt/encrypt.dart';

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

  final key = Key.fromUtf8(urlKey);
  final iv = IV.fromUtf8(urlIv);
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

  final enumFile = File('lib/domain/core/enums/environments.enum.dart');
  if (!enumFile.existsSync()) {
    print('❌ Error: lib/domain/core/enums/environments.enum.dart not found');
    return;
  }

  final content = enumFile.readAsStringSync();
  final regExp = RegExp(r"(\w+)\s*\([\s\S]*?encryptedUrl:\s*'([^']*)'");
  final matches = regExp.allMatches(content);

  if (matches.isEmpty) {
    print('❌ Warning: No environments with encryptedUrl found in environments.enum.dart');
    return;
  }

  print('=== Verifying URL Decryption ===');
  for (final match in matches) {
    final envName = match.group(1)!;
    final encryptedUrl = match.group(2)!;

    print('${envName.toUpperCase()}:');
    print('  Encrypted: $encryptedUrl');

    try {
      final decrypted = encrypter.decrypt64(encryptedUrl, iv: iv);
      final decryptedUrl = decrypted == 'EMPTY' ? '' : decrypted;
      print('  Decrypted: $decryptedUrl');

      if (envName == 'local') {
        const expected = 'http://soeket.pdesoebandi.id';
        if (decryptedUrl == expected) {
          print('  ✅ LOCAL URL decryption verified successfully!');
        } else {
          print('  ❌ LOCAL URL decryption failed! Expected: $expected');
        }
      }
    } catch (e) {
      print('  ❌ Decryption failed: $e');
    }
  }
}
