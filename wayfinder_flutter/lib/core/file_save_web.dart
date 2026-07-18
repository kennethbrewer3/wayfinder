import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:web/web.dart';

import 'file_save_stub.dart';

export 'file_save_stub.dart' show BackupPickResult, GeoExchangePickResult;

Future<bool> saveTextFile({
  required String fileName,
  required String contents,
  List<String> allowedExtensions = const ['json'],
}) async {
  final bytes = Uint8List.fromList(utf8.encode(contents));
  return saveBinaryFile(fileName: fileName, bytes: bytes);
}

Future<GeoExchangePickResult?> pickGeoExchangeFile() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['gpx', 'kml', 'geojson', 'json'],
    withData: true,
  );
  if (result == null || result.files.isEmpty) {
    return null;
  }
  final file = result.files.single;
  final bytes = file.bytes;
  if (bytes == null) {
    return null;
  }
  return GeoExchangePickResult(
    fileName: file.name,
    contents: utf8.decode(bytes),
  );
}

Future<bool> saveBinaryFile({
  required String fileName,
  required Uint8List bytes,
  List<String> allowedExtensions = const ['zip'],
}) async {
  final blob = Blob([bytes.toJS].toJS);
  final url = URL.createObjectURL(blob);
  final anchor = HTMLAnchorElement()
    ..href = url
    ..download = fileName
    ..style.display = 'none';
  document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  URL.revokeObjectURL(url);
  return true;
}

Future<bool> downloadUrlToFile({
  required Uri url,
  required String fileName,
  List<String> allowedExtensions = const ['pmtiles'],
}) async {
  // Streamed server download — do not buffer the archive in memory.
  final anchor = HTMLAnchorElement()
    ..href = url.toString()
    ..download = fileName
    ..rel = 'noopener'
    ..style.display = 'none';
  document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  return true;
}

Future<String?> pickTextFileContents() async {
  final result = await pickBackupFile();
  return result?.jsonText;
}

Future<BackupPickResult?> pickBackupFile() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['json', 'zip'],
    withData: true,
  );
  if (result == null || result.files.isEmpty) {
    return null;
  }

  final file = result.files.single;
  final fileName = file.name.toLowerCase();
  final bytes = file.bytes;
  if (bytes == null) {
    return null;
  }

  if (fileName.endsWith('.zip')) {
    return BackupPickResult(zipBytes: Uint8List.fromList(bytes));
  }
  if (fileName.endsWith('.json')) {
    return BackupPickResult(jsonText: utf8.decode(bytes));
  }
  return null;
}
