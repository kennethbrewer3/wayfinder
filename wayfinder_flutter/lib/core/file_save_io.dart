import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import 'file_save_stub.dart';

export 'file_save_stub.dart' show BackupPickResult;

Future<bool> saveTextFile({
  required String fileName,
  required String contents,
}) async {
  final path = await FilePicker.platform.saveFile(
    fileName: fileName,
    type: FileType.custom,
    allowedExtensions: const ['json'],
  );
  if (path == null) {
    return false;
  }

  await File(path).writeAsString(contents);
  return true;
}

Future<bool> saveBinaryFile({
  required String fileName,
  required Uint8List bytes,
}) async {
  final path = await FilePicker.platform.saveFile(
    fileName: fileName,
    type: FileType.custom,
    allowedExtensions: const ['zip'],
  );
  if (path == null) {
    return false;
  }

  await File(path).writeAsBytes(bytes, flush: true);
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
