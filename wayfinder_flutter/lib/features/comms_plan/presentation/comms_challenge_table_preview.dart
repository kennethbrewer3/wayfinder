import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../models/comms_challenge_table.dart';
import '../utils/comms_challenge_table_pdf.dart';
import '../utils/comms_sheet_pdf_export.dart';

Future<void> showCommsChallengeTablePreview({
  required BuildContext context,
  required String planName,
  required CommsChallengeTable table,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _CommsChallengeTablePreviewDialog(
      planName: planName,
      table: table,
    ),
  );
}

class _CommsChallengeTablePreviewDialog extends StatefulWidget {
  const _CommsChallengeTablePreviewDialog({
    required this.planName,
    required this.table,
  });

  final String planName;
  final CommsChallengeTable table;

  @override
  State<_CommsChallengeTablePreviewDialog> createState() =>
      _CommsChallengeTablePreviewDialogState();
}

class _CommsChallengeTablePreviewDialogState
    extends State<_CommsChallengeTablePreviewDialog> {
  var _printing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final table = widget.table;
    return AlertDialog(
      title: Text(l10n.commsChallengeTableTitle),
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
                table.label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                l10n.commsChallengeTableGeneratedAt(
                  DateFormat.yMMMd().add_Hm().format(
                    table.generatedAt.toLocal(),
                  ),
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.commsChallengeTableInstructions,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              CommsChallengeTableView(table: table),
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
      final stamp = DateFormat('yyyyMMdd-HHmmss').format(
        widget.table.generatedAt.toLocal(),
      );
      final saved = await saveCommsSheetPdf(
        fileName: 'wayfinder-auth-sheet-$stamp.pdf',
        build: (context) => buildCommsChallengeTablePdfWidgets(
          planName: widget.planName,
          table: widget.table,
          title: l10n.commsChallengeTableTitle,
          instructions: l10n.commsChallengeTableInstructions,
          generatedLabel: l10n.commsChallengeTableGeneratedPrefix,
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

class CommsChallengeTableView extends StatelessWidget {
  const CommsChallengeTableView({super.key, required this.table});

  final CommsChallengeTable table;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 36,
        dataRowMinHeight: 32,
        dataRowMaxHeight: 36,
        columnSpacing: 12,
        horizontalMargin: 8,
        columns: [
          const DataColumn(label: Text('')),
          for (final col in table.columnLabels)
            DataColumn(
              label: Text(
                col,
                style: theme.textTheme.labelLarge,
              ),
            ),
        ],
        rows: [
          for (var r = 0; r < table.rowCount; r++)
            DataRow(
              cells: [
                DataCell(
                  Text(
                    table.rowLabels[r],
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                for (var c = 0; c < table.columnCount; c++)
                  DataCell(
                    Text(
                      table.cells[r][c],
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
