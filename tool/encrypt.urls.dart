// Run with: dart tool/encrypt_urls.dart
// This tool generates AES-256-CBC encrypted base64 strings for config URLs.
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

void main() async {
  final env = loadEnv();
  final urlKey = env['URL_ENCRYPTION_KEY'];
  final urlIv = env['URL_ENCRYPTION_IV'];

  if (urlKey == null || urlKey.isEmpty) {
    print('❌ Error: URL_ENCRYPTION_KEY tidak ditemukan di .env');
    return;
  }
  if (urlIv == null || urlIv.isEmpty) {
    print('❌ Error: URL_ENCRYPTION_IV tidak ditemukan di .env');
    return;
  }

  if (urlKey.length != 32) {
    print('❌ Error: URL_ENCRYPTION_KEY harus tepat 32 karakter (32 bytes)');
    return;
  }
  if (urlIv.length != 16) {
    print('❌ Error: URL_ENCRYPTION_IV harus tepat 16 karakter (16 bytes)');
    return;
  }

  final key = Key.fromUtf8(urlKey);
  final iv = IV.fromUtf8(urlIv);
  final enc = Encrypter(AES(key, mode: AESMode.cbc));

  final urls = {
    'LOCAL': 'http://pdesoebandi.id/informasi/',
    'DEV': '',
    'QAS': '',
    'PROD': '',
  };

  print('=== Encrypted URL values ===');
  final encryptedValues = {
    'local': enc
        .encrypt(urls['LOCAL']!.isEmpty ? 'EMPTY' : urls['LOCAL']!, iv: iv)
        .base64,
    'dev': enc
        .encrypt(urls['DEV']!.isEmpty ? 'EMPTY' : urls['DEV']!, iv: iv)
        .base64,
    'qas': enc
        .encrypt(urls['QAS']!.isEmpty ? 'EMPTY' : urls['QAS']!, iv: iv)
        .base64,
    'production': enc
        .encrypt(urls['PROD']!.isEmpty ? 'EMPTY' : urls['PROD']!, iv: iv)
        .base64,
  };

  final file = File('lib/domain/core/enums/environments.enum.dart');

  if (!await file.exists()) {
    print('File environments.dart tidak ditemukan');
    return;
  }

  String content = await file.readAsString();

  encryptedValues.forEach((env, value) {
    content = content.replaceFirstMapped(
      RegExp(
        '$env\\s*\\([\\s\\S]*?encryptedUrl:\\s*\'[^\']*\'',
        multiLine: true,
      ),
      (match) {
        return match
            .group(0)!
            .replaceAll(
              RegExp(r"encryptedUrl:\s*'[^']*'"),
              "encryptedUrl: '$value'",
            );
      },
    );
  });

  await file.writeAsString(content);

  print('✅ environments.dart berhasil diperbarui');
}
