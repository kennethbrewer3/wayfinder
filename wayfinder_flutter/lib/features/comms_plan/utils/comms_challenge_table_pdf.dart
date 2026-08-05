import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/comms_challenge_table.dart';

/// Builds PDF pages for one or more radio challenge authentication tables.
List<pw.Widget> buildCommsChallengeTablePdfWidgets({
  required String planName,
  required CommsChallengeTable table,
  required String title,
  required String instructions,
  required String generatedLabel,
}) {
  final generated = DateFormat.yMMMd().add_Hm().format(
    table.generatedAt.toLocal(),
  );
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
      table.label,
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
      border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _headerCell(''),
            for (final col in table.columnLabels) _headerCell(col),
          ],
        ),
        for (var r = 0; r < table.rowCount; r++)
          pw.TableRow(
            children: [
              _headerCell(table.rowLabels[r]),
              for (var c = 0; c < table.columnCount; c++)
                _bodyCell(table.cells[r][c]),
            ],
          ),
      ],
    ),
    if (table.note != null && table.note!.trim().isNotEmpty) ...[
      pw.SizedBox(height: 10),
      pw.Text(
        table.note!,
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
      ),
    ],
  ];
}

pw.Widget _headerCell(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
    child: pw.Center(
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      ),
    ),
  );
}

pw.Widget _bodyCell(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
    child: pw.Center(
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          fontFallback: const [],
        ),
      ),
    ),
  );
}
