import 'dart:typed_data';

class BackupPickResult {
  const BackupPickResult({this.jsonText, this.zipBytes});

  final String? jsonText;
  final Uint8List? zipBytes;

  bool get isZip => zipBytes != null;
  bool get isJson => jsonText != null;
}

Future<bool> saveTextFile({
  required String fileName,
  required String contents,
}) async {
  return false;
}

Future<bool> saveBinaryFile({
  required String fileName,
  required Uint8List bytes,
}) async {
  return false;
}

Future<String?> pickTextFileContents() async {
  return null;
}

Future<BackupPickResult?> pickBackupFile() async {
  return null;
}
