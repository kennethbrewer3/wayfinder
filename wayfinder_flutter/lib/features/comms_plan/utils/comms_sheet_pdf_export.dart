import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:wayfinder_flutter/core/file_save.dart';

/// Builds a single printable PDF from page widgets and opens the save dialog.
Future<bool> saveCommsSheetPdf({
  required String fileName,
  required List<pw.Widget> Function(pw.Context context) build,
  PdfPageFormat pageFormat = PdfPageFormat.letter,
}) async {
  final doc = pw.Document(
    title: fileName,
    author: 'Wayfinder',
    creator: 'Wayfinder comms sheets',
  );
  doc.addPage(
    pw.MultiPage(
      pageFormat: pageFormat,
      margin: const pw.EdgeInsets.all(28),
      build: build,
    ),
  );
  final bytes = await doc.save();
  return saveBinaryFile(
    fileName: fileName.endsWith('.pdf') ? fileName : '$fileName.pdf',
    bytes: Uint8List.fromList(bytes),
    allowedExtensions: const ['pdf'],
  );
}
