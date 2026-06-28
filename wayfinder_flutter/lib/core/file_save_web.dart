import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:web/web.dart';

Future<bool> saveTextFile({
  required String fileName,
  required String contents,
}) async {
  final bytes = Uint8List.fromList(utf8.encode(contents));
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
