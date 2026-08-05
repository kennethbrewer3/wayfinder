import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../models/comms_card_of_the_day.dart';
import '../utils/comms_card_of_the_day_pdf.dart';
import '../utils/comms_one_time_pad_font.dart';
import '../utils/comms_sheet_pdf_export.dart';

Future<void> showCommsCardOfTheDayPreview({
  required BuildContext context,
  required String planName,
  required CommsCardOfTheDay card,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _CommsCardOfTheDayPreviewDialog(
      planName: planName,
      card: card,
    ),
  );
}

class _CommsCardOfTheDayPreviewDialog extends StatefulWidget {
  const _CommsCardOfTheDayPreviewDialog({
    required this.planName,
    required this.card,
  });

  final String planName;
  final CommsCardOfTheDay card;

  @override
  State<_CommsCardOfTheDayPreviewDialog> createState() =>
      _CommsCardOfTheDayPreviewDialogState();
}

class _CommsCardOfTheDayPreviewDialogState
    extends State<_CommsCardOfTheDayPreviewDialog> {
  var _printing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final card = widget.card;
    return AlertDialog(
      title: Text(l10n.commsCardOfTheDayTitle),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.planName,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                card.label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                l10n.commsCardOfTheDayDateValue(
                  DateFormat.yMMMMEEEEd().format(card.date.toLocal()),
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.commsCardOfTheDayInstructions,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              CommsCardOfTheDayView(card: card),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _printing ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.actionClose),
        ),
        FilledButton.icon(
          onPressed: _printing ? null : _printPdf,
          icon: _printing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.print),
          label: Text(l10n.commsSheetPrintPdf),
        ),
      ],
    );
  }

  Future<void> _printPdf() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _printing = true);
    try {
      final mono = await loadCommsOneTimePadPdfFont();
      final dateStamp = dateOnlyIso(widget.card.date);
      final saved = await saveCommsSheetPdf(
        fileName: 'wayfinder-card-of-the-day-$dateStamp.pdf',
        build: (context) => buildCommsCardOfTheDayPdfWidgets(
          planName: widget.planName,
          card: widget.card,
          title: l10n.commsCardOfTheDayTitle,
          instructions: l10n.commsCardOfTheDayInstructions,
          dateLabel: l10n.commsCardOfTheDayDatePrefix,
          digitKeyTitle: l10n.commsCardOfTheDayDigitKeyTitle,
          itemColumn: l10n.commsCardOfTheDayItemLabel,
          codeWordColumn: l10n.commsCardOfTheDayCodeWordLabel,
          placesTitle: l10n.commsCardOfTheDayPlaces,
          peopleTitle: l10n.commsCardOfTheDayPeople,
          objectsTitle: l10n.commsCardOfTheDayObjects,
          directionsTitle: l10n.commsCardOfTheDayDirections,
          conditionsTitle: l10n.commsCardOfTheDayConditions,
          otherTitle: l10n.commsCardOfTheDayOther,
          emptyCategory: l10n.commsCardOfTheDayCategoryEmpty,
          digitKeyMissing: l10n.commsCardOfTheDayDigitKeyMissing,
          monoFont: mono,
        ),
      );
      if (!mounted || !saved) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.commsSheetPrintPdfSaved)),
      );
    } finally {
      if (mounted) {
        setState(() => _printing = false);
      }
    }
  }
}

class CommsCardOfTheDayView extends StatelessWidget {
  const CommsCardOfTheDayView({super.key, required this.card});

  final CommsCardOfTheDay card;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.commsCardOfTheDayDigitKeyTitle,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 6),
        if (card.hasValidDigitKey)
          Table(
            border: TableBorder.all(color: theme.dividerColor),
            children: [
              TableRow(
                children: [
                  for (var d = 0; d < 10; d++)
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        '$d',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                ],
              ),
              TableRow(
                children: [
                  for (var d = 0; d < 10; d++)
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        card.digitKey[d],
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontFamily: commsOneTimePadFontFamily,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          )
        else
          Text(
            l10n.commsCardOfTheDayDigitKeyMissing,
            style: theme.textTheme.bodySmall,
          ),
        const SizedBox(height: 16),
        _CategoryView(
          title: l10n.commsCardOfTheDayPlaces,
          entries: card.places,
          itemLabel: l10n.commsCardOfTheDayItemLabel,
          codeWordLabel: l10n.commsCardOfTheDayCodeWordLabel,
          emptyLabel: l10n.commsCardOfTheDayCategoryEmpty,
        ),
        _CategoryView(
          title: l10n.commsCardOfTheDayPeople,
          entries: card.people,
          itemLabel: l10n.commsCardOfTheDayItemLabel,
          codeWordLabel: l10n.commsCardOfTheDayCodeWordLabel,
          emptyLabel: l10n.commsCardOfTheDayCategoryEmpty,
        ),
        _CategoryView(
          title: l10n.commsCardOfTheDayObjects,
          entries: card.objects,
          itemLabel: l10n.commsCardOfTheDayItemLabel,
          codeWordLabel: l10n.commsCardOfTheDayCodeWordLabel,
          emptyLabel: l10n.commsCardOfTheDayCategoryEmpty,
        ),
        _CategoryView(
          title: l10n.commsCardOfTheDayDirections,
          entries: card.directions,
          itemLabel: l10n.commsCardOfTheDayItemLabel,
          codeWordLabel: l10n.commsCardOfTheDayCodeWordLabel,
          emptyLabel: l10n.commsCardOfTheDayCategoryEmpty,
        ),
        _CategoryView(
          title: l10n.commsCardOfTheDayConditions,
          entries: card.conditions,
          itemLabel: l10n.commsCardOfTheDayItemLabel,
          codeWordLabel: l10n.commsCardOfTheDayCodeWordLabel,
          emptyLabel: l10n.commsCardOfTheDayCategoryEmpty,
        ),
        _CategoryView(
          title: l10n.commsCardOfTheDayOther,
          entries: card.other,
          itemLabel: l10n.commsCardOfTheDayItemLabel,
          codeWordLabel: l10n.commsCardOfTheDayCodeWordLabel,
          emptyLabel: l10n.commsCardOfTheDayCategoryEmpty,
        ),
      ],
    );
  }
}

class _CategoryView extends StatelessWidget {
  const _CategoryView({
    required this.title,
    required this.entries,
    required this.itemLabel,
    required this.codeWordLabel,
    required this.emptyLabel,
  });

  final String title;
  final List<CommsCardOfTheDayEntry> entries;
  final String itemLabel;
  final String codeWordLabel;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filled = [
      for (final e in entries)
        if (!e.isBlank) e,
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          if (filled.isEmpty)
            Text(emptyLabel, style: theme.textTheme.bodySmall)
          else
            DataTable(
              headingRowHeight: 32,
              dataRowMinHeight: 28,
              dataRowMaxHeight: 36,
              columnSpacing: 16,
              horizontalMargin: 0,
              columns: [
                DataColumn(label: Text(itemLabel)),
                DataColumn(label: Text(codeWordLabel)),
              ],
              rows: [
                for (final entry in filled)
                  DataRow(
                    cells: [
                      DataCell(Text(entry.item)),
                      DataCell(
                        Text(
                          entry.codeWord,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
