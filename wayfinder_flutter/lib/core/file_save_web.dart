import 'dart:convert';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:file_picker/file_picker.dart';

Future<bool> saveTextFile({
  required String fileName,
  required String contents,
}) async {
  final bytes = utf8.encode(contents);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..download = fileName
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
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

  final bytes = result.files.single.bytes;
  if (bytes == null) {
    return null;
  }
  return utf8.decode(bytes);
}
