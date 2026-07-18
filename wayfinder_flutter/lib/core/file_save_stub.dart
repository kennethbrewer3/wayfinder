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

/// Stream [url] to a user-chosen destination (or browser download on web).
///
/// Returns `false` if the user cancels. Throws on network/IO failure.
Future<bool> downloadUrlToFile({
  required Uri url,
  required String fileName,
  List<String> allowedExtensions = const ['pmtiles'],
}) async {
  return false;
}

Future<String?> pickTextFileContents() async {
  return null;
}

Future<BackupPickResult?> pickBackupFile() async {
  return null;
}
