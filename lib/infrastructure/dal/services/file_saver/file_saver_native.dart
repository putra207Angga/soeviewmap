import 'dart:io';
import 'dart:typed_data';

Future<void> saveAndDownloadFile(Uint8List bytes, String fileName) async {
  String downloadsDir = '.';
  if (Platform.isWindows) {
    final userProfile = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'] ?? '';
    if (userProfile.isNotEmpty) {
      downloadsDir = '$userProfile\\Downloads';
    }
  }
  
  final file = File('$downloadsDir${Platform.pathSeparator}$fileName');
  await file.writeAsBytes(bytes);
}
