part of 'main.interfaces.dart';

class EncryptionHelper {
  // Encrypt string with XOR + Base64 using a secret key
  static String encrypt(String plainText, String key) {
    if (key.isEmpty) return plainText;
    final List<int> plaintextBytes = utf8.encode(plainText);
    final List<int> keyBytes = utf8.encode(key);
    final List<int> encryptedBytes = List<int>.generate(
      plaintextBytes.length,
      (i) => plaintextBytes[i] ^ keyBytes[i % keyBytes.length],
    );
    return base64.encode(encryptedBytes);
  }

  // Decrypt string with XOR + Base64 using a secret key
  static String decrypt(String encryptedText, String key) {
    if (key.isEmpty) return encryptedText;
    try {
      final List<int> encryptedBytes = base64.decode(encryptedText);
      final List<int> keyBytes = utf8.encode(key);
      final List<int> decryptedBytes = List<int>.generate(
        encryptedBytes.length,
        (i) => encryptedBytes[i] ^ keyBytes[i % keyBytes.length],
      );
      return utf8.decode(decryptedBytes);
    } catch (e) {
      return '';
    }
  }
}
