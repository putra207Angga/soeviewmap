import 'dart:io';
import 'dart:typed_data';

Future<void> saveAndDownloadFile(Uint8List bytes, String fileName) async {
  String downloadsDir = '.';
  if (Platform.isWindows) {
    final userProfile = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'] ?? '';
    if (userProfile.isNotEmpty) {
      downloadsDir = '$userProfile\\Downloads';
    }
  } else if (Platform.isAndroid) {
    final androidDownloadDir = Directory('/storage/emulated/0/Download');
    if (await androidDownloadDir.exists()) {
      downloadsDir = androidDownloadDir.path;
    } else {
      final sdDownloadDir = Directory('/sdcard/Download');
      if (await sdDownloadDir.exists()) {
        downloadsDir = sdDownloadDir.path;
      } else {
        downloadsDir = Directory.systemTemp.path;
      }
    }
  } else if (Platform.isMacOS || Platform.isLinux) {
    final home = Platform.environment['HOME'] ?? '';
    if (home.isNotEmpty) {
      downloadsDir = '$home/Downloads';
    }
  }

  final targetDir = Directory(downloadsDir);
  if (!await targetDir.exists()) {
    await targetDir.create(recursive: true);
  }

  final file = File('$downloadsDir${Platform.pathSeparator}$fileName');
  await file.writeAsBytes(bytes, flush: true);
}
