import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/comms_card_of_the_day.dart';

/// Builds PDF content for one card of the day.
List<pw.Widget> buildCommsCardOfTheDayPdfWidgets({
  required String planName,
  required CommsCardOfTheDay card,
  required String title,
  required String instructions,
  required String dateLabel,
  required String digitKeyTitle,
  required String itemColumn,
  required String codeWordColumn,
  required String placesTitle,
  required String peopleTitle,
  required String objectsTitle,
  required String directionsTitle,
  required String conditionsTitle,
  required String otherTitle,
  required String emptyCategory,
  required String digitKeyMissing,
  pw.Font? monoFont,
}) {
  final dateText = DateFormat.yMMMMEEEEd().format(card.date.toLocal());
  final mono = pw.TextStyle(
    font: monoFont,
    fontSize: 12,
    fontWeight: pw.FontWeight.bold,
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
      card.label,
      style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
    ),
    pw.Text(
      '$dateLabel $dateText',
      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
    ),
    pw.SizedBox(height: 8),
    pw.Text(instructions, style: const pw.TextStyle(fontSize: 9)),
    pw.SizedBox(height: 14),
    pw.Text(
      digitKeyTitle,
      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
    ),
    pw.SizedBox(height: 6),
    if (card.hasValidDigitKey)
      pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.grey300),
            children: [
              for (var d = 0; d < 10; d++) _digitHeader('$d'),
            ],
          ),
          pw.TableRow(
            children: [
              for (var d = 0; d < 10; d++)
                _digitBody(card.digitKey[d], style: mono),
            ],
          ),
        ],
      )
    else
      pw.Text(
        digitKeyMissing,
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
      ),
    pw.SizedBox(height: 14),
    ..._categorySection(
      placesTitle,
      card.places,
      itemColumn: itemColumn,
      codeWordColumn: codeWordColumn,
      emptyCategory: emptyCategory,
    ),
    ..._categorySection(
      peopleTitle,
      card.people,
      itemColumn: itemColumn,
      codeWordColumn: codeWordColumn,
      emptyCategory: emptyCategory,
    ),
    ..._categorySection(
      objectsTitle,
      card.objects,
      itemColumn: itemColumn,
      codeWordColumn: codeWordColumn,
      emptyCategory: emptyCategory,
    ),
    ..._categorySection(
      directionsTitle,
      card.directions,
      itemColumn: itemColumn,
      codeWordColumn: codeWordColumn,
      emptyCategory: emptyCategory,
    ),
    ..._categorySection(
      conditionsTitle,
      card.conditions,
      itemColumn: itemColumn,
      codeWordColumn: codeWordColumn,
      emptyCategory: emptyCategory,
    ),
    ..._categorySection(
      otherTitle,
      card.other,
      itemColumn: itemColumn,
      codeWordColumn: codeWordColumn,
      emptyCategory: emptyCategory,
    ),
    if (card.note != null && card.note!.trim().isNotEmpty) ...[
      pw.SizedBox(height: 10),
      pw.Text(
        card.note!,
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
      ),
    ],
  ];
}

List<pw.Widget> _categorySection(
  String title,
  List<CommsCardOfTheDayEntry> entries, {
  required String itemColumn,
  required String codeWordColumn,
  required String emptyCategory,
}) {
  final filled = [
    for (final e in entries)
      if (!e.isBlank) e,
  ];
  return [
    pw.Text(
      title,
      style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
    ),
    pw.SizedBox(height: 4),
    if (filled.isEmpty)
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 10),
        child: pw.Text(
          emptyCategory,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
      )
    else
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 10),
        child: pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.4),
          columnWidths: const {
            0: pw.FlexColumnWidth(1.2),
            1: pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                _headerCell(itemColumn),
                _headerCell(codeWordColumn),
              ],
            ),
            for (final entry in filled)
              pw.TableRow(
                children: [
                  _bodyCell(entry.item),
                  _bodyCell(entry.codeWord),
                ],
              ),
          ],
        ),
      ),
  ];
}

pw.Widget _digitHeader(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 4),
    child: pw.Center(
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      ),
    ),
  );
}

pw.Widget _digitBody(String text, {required pw.TextStyle style}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 6),
    child: pw.Center(child: pw.Text(text, style: style)),
  );
}

pw.Widget _headerCell(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    child: pw.Text(
      text,
      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
    ),
  );
}

pw.Widget _bodyCell(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
  );
}
