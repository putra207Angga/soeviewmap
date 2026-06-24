import 'package:encrypt/encrypt.dart';

void main() {
  final key = Key.fromUtf8(r'S0eb1sAppKey2026XXXXXXXXXX!@#$%^');
  final iv = IV.fromUtf8(r'S0eb1sIV2026!@#$');
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

  final encryptedLocal = '+CTlaDYzXo9HJ6JbmY3MqRJbIJJTNgfNvGLoabesGLo=';
  final decrypted = encrypter.decrypt64(encryptedLocal, iv: iv);
  print('Decrypted Local URL: $decrypted');
}
