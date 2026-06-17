import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

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

Future<String?> pickTextFileContents() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['json'],
    withData: true,
  );
  if (result == null || result.files.isEmpty) {
    return null;
  }

  final file = result.files.single;
  if (file.bytes != null) {
    return utf8.decode(file.bytes!);
  }
  if (file.path != null) {
    return File(file.path!).readAsString();
  }
  return null;
}
