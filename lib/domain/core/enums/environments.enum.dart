part of 'main.enums.dart';

enum Environments {
  production(
    label: 'prod',
    icon: Icons.verified_rounded,
    color: Color(0xFF006948),
    encryptedUrl: '1T0Ci+L4IyBBxh8HAqQO7A==',
  ),
  qas(
    label: 'QAS',
    icon: Icons.science_rounded,
    color: Color(0xFF006591),
    encryptedUrl: '1T0Ci+L4IyBBxh8HAqQO7A==',
  ),
  dev(
    label: 'dev',
    icon: Icons.code_rounded,
    color: Color(0xFF7C3AED),
    encryptedUrl: '1T0Ci+L4IyBBxh8HAqQO7A==',
  ),
  local(
    label: 'local',
    icon: Icons.computer_rounded,
    color: Color(0xFFF59E0B),
    encryptedUrl: '+CTlaDYzXo9HJ6JbmY3MqRJbIJJTNgfNvGLoabesGLo=',
  );

  final String label;
  final IconData icon;
  final Color color;
  final String encryptedUrl;

  const Environments({
    required this.label,
    required this.icon,
    required this.color,
    required this.encryptedUrl,
  });

  String get url {
    final keyStr = ConfigEnvironments.urlDecryptionKey;
    final ivStr = ConfigEnvironments.urlDecryptionIv;

    if (keyStr.isEmpty || ivStr.isEmpty) {
      return '';
    }

    try {
      final key = encrypt.Key.fromUtf8(keyStr);
      final iv = encrypt.IV.fromUtf8(ivStr);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );
      final decrypted = encrypter.decrypt64(encryptedUrl, iv: iv);
      return decrypted == 'EMPTY' ? '' : decrypted;
    } catch (e) {
      return '';
    }
  }
}
