import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import 'file_save_stub.dart';

export 'file_save_stub.dart' show BackupPickResult, GeoExchangePickResult;

Future<bool> saveTextFile({
  required String fileName,
  required String contents,
  List<String> allowedExtensions = const ['json'],
}) async {
  final path = await FilePicker.platform.saveFile(
    fileName: fileName,
    type: FileType.custom,
    allowedExtensions: allowedExtensions,
  );
  if (path == null) {
    return false;
  }

  await File(path).writeAsString(contents);
  return true;
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
  final text = await _readPickedText(file);
  if (text == null) {
    return null;
  }
  return GeoExchangePickResult(fileName: file.name, contents: text);
}

Future<bool> saveBinaryFile({
  required String fileName,
  required Uint8List bytes,
  List<String> allowedExtensions = const ['zip'],
}) async {
  final path = await FilePicker.platform.saveFile(
    fileName: fileName,
    type: FileType.custom,
    allowedExtensions: allowedExtensions,
  );
  if (path == null) {
    return false;
  }

  await File(path).writeAsBytes(bytes, flush: true);
  return true;
}

Future<bool> downloadUrlToFile({
  required Uri url,
  required String fileName,
  List<String> allowedExtensions = const ['pmtiles'],
}) async {
  var path = await FilePicker.platform.saveFile(
    fileName: fileName,
    type: FileType.custom,
    allowedExtensions: allowedExtensions,
  );
  if (path == null) {
    return false;
  }

  if (allowedExtensions.isNotEmpty) {
    final lower = path.toLowerCase();
    final hasExtension = allowedExtensions.any(
      (ext) => lower.endsWith('.${ext.toLowerCase()}'),
    );
    if (!hasExtension) {
      path = '$path.${allowedExtensions.first}';
    }
  }

  final client = http.Client();
  try {
    final request = http.Request('GET', url);
    final response = await client.send(request);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Download failed with HTTP ${response.statusCode}.',
      );
    }

    final sink = File(path).openWrite();
    try {
      await response.stream.pipe(sink);
      await sink.flush();
    } catch (_) {
      await sink.close();
      final partial = File(path);
      if (await partial.exists()) {
        await partial.delete();
      }
      rethrow;
    }
    await sink.close();
    return true;
  } finally {
    client.close();
  }
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
  if (fileName.endsWith('.zip')) {
    final bytes = await _readPickedBytes(file);
    if (bytes == null) {
      return null;
    }
    return BackupPickResult(zipBytes: bytes);
  }

  if (fileName.endsWith('.json')) {
    final text = await _readPickedText(file);
    if (text == null) {
      return null;
    }
    return BackupPickResult(jsonText: text);
  }

  return null;
}

Future<Uint8List?> pickTidePackFile() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['wayfinder-tide', 'zip'],
    withData: true,
  );
  if (result == null || result.files.isEmpty) {
    return null;
  }
  return _readPickedBytes(result.files.single);
}

/// Picks a `.wayfinder-field` or `.zip` field pack archive from local storage.
Future<Uint8List?> pickFieldPackFile() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['wayfinder-field', 'zip'],
    withData: true,
  );
  if (result == null || result.files.isEmpty) {
    return null;
  }
  return _readPickedBytes(result.files.single);
}

Future<Uint8List?> _readPickedBytes(PlatformFile file) async {
  if (file.bytes != null) {
    return Uint8List.fromList(file.bytes!);
  }
  if (file.path != null) {
    return File(file.path!).readAsBytes();
  }
  return null;
}

Future<String?> _readPickedText(PlatformFile file) async {
  if (file.bytes != null) {
    return utf8.decode(file.bytes!);
  }
  if (file.path != null) {
    return File(file.path!).readAsString();
  }
  return null;
}
