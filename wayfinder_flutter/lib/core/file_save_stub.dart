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
  List<String> allowedExtensions = const ['json'],
}) async {
  return false;
}

class GeoExchangePickResult {
  const GeoExchangePickResult({
    required this.fileName,
    required this.contents,
  });

  final String fileName;
  final String contents;
}

Future<GeoExchangePickResult?> pickGeoExchangeFile() async {
  return null;
}

Future<bool> saveBinaryFile({
  required String fileName,
  required Uint8List bytes,
  List<String> allowedExtensions = const ['zip'],
}) async {
  return false;
}

Future<String?> pickTextFileContents() async {
  return null;
}

Future<BackupPickResult?> pickBackupFile() async {
  return null;
}
