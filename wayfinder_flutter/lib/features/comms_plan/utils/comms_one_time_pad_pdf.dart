import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/comms_one_time_pad.dart';

/// Builds PDF pages for one cryptographic one-time pad sheet.
///
/// [monoFont] must be the bundled Noto Sans Mono face so columns match the
/// in-app preview on every platform.
List<pw.Widget> buildCommsOneTimePadPdfWidgets({
  required String planName,
  required CommsOneTimePad pad,
  required String title,
  required String instructions,
  required String generatedLabel,
  required pw.Font monoFont,
}) {
  final generated = DateFormat.yMMMd().add_Hm().format(
    pad.generatedAt.toLocal(),
  );
  final mono = pw.TextStyle(font: monoFont, fontSize: 11);
  final monoSmall = pw.TextStyle(font: monoFont, fontSize: 9);
  return [
    pw.Text(
      title,
      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
    ),
    pw.SizedBox(height: 4),
    pw.Text(
      planName,
      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
    ),
    pw.Text(
      pad.label,
      style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
    ),
    pw.Text(
      '$generatedLabel $generated',
      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
    ),
    pw.SizedBox(height: 8),
    pw.Text(instructions, style: const pw.TextStyle(fontSize: 9)),
    pw.SizedBox(height: 12),
    pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.4),
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      columnWidths: {
        0: const pw.FixedColumnWidth(28),
        for (var c = 0; c < CommsOneTimePad.columnCount; c++)
          c + 1: const pw.FixedColumnWidth(72),
      },
      children: [
        for (var r = 0; r < pad.groups.length; r++)
          pw.TableRow(
            children: [
              _indexCell(
                (r + 1).toString().padLeft(2, '0'),
                style: monoSmall,
              ),
              for (final group in pad.groups[r]) _groupCell(group, style: mono),
            ],
          ),
      ],
    ),
    if (pad.note != null && pad.note!.trim().isNotEmpty) ...[
      pw.SizedBox(height: 10),
      pw.Text(
        pad.note!,
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
      ),
    ],
  ];
}

pw.Widget _indexCell(String text, {required pw.TextStyle style}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
    child: pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(text, style: style),
    ),
  );
}

pw.Widget _groupCell(String text, {required pw.TextStyle style}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    child: pw.Center(child: pw.Text(text, style: style)),
  );
}
