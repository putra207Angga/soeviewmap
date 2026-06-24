import 'package:encrypt/encrypt.dart';

void main() {
  final encryptedUrl = '+CTlaDYzXo9HJ6JbmY3MqRJbIJJTNgfNvGLoabesGLo=';

  // Key with escaped $
  final keyStr1 = 'S0eb1sAppKey2026XXXXXXXXXX!@#\$%^';
  final ivStr1 = 'S0eb1sIV2026!@#\$';

  // Raw key
  final keyStr2 = r'S0eb1sAppKey2026XXXXXXXXXX!@#$%^';
  final ivStr2 = r'S0eb1sIV2026!@#$';

  print('keyStr1: $keyStr1');
  print('keyStr2: $keyStr2');
  print('ivStr1: $ivStr1');
  print('ivStr2: $ivStr2');

  try {
    final key1 = Key.fromUtf8(keyStr1);
    final iv1 = IV.fromUtf8(ivStr1);
    final encrypter1 = Encrypter(AES(key1, mode: AESMode.cbc));
    final decrypted1 = encrypter1.decrypt64(encryptedUrl, iv: iv1);
    print('decrypted1: $decrypted1');
  } catch (e) {
    print('Error 1: $e');
  }

  try {
    final key2 = Key.fromUtf8(keyStr2);
    final iv2 = IV.fromUtf8(ivStr2);
    final encrypter2 = Encrypter(AES(key2, mode: AESMode.cbc));
    final decrypted2 = encrypter2.decrypt64(encryptedUrl, iv: iv2);
    print('decrypted2: $decrypted2');
  } catch (e) {
    print('Error 2: $e');
  }
}
