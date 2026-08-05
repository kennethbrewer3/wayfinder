import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../models/comms_one_time_pad.dart';
import '../utils/comms_one_time_pad_font.dart';
import '../utils/comms_one_time_pad_pdf.dart';
import '../utils/comms_sheet_pdf_export.dart';

Future<void> showCommsOneTimePadPreview({
  required BuildContext context,
  required String planName,
  required CommsOneTimePad pad,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _CommsOneTimePadPreviewDialog(
      planName: planName,
      pad: pad,
    ),
  );
}

class _CommsOneTimePadPreviewDialog extends StatefulWidget {
  const _CommsOneTimePadPreviewDialog({
    required this.planName,
    required this.pad,
  });

  final String planName;
  final CommsOneTimePad pad;

  @override
  State<_CommsOneTimePadPreviewDialog> createState() =>
      _CommsOneTimePadPreviewDialogState();
}

class _CommsOneTimePadPreviewDialogState
    extends State<_CommsOneTimePadPreviewDialog> {
  var _printing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pad = widget.pad;
    return AlertDialog(
      title: Text(l10n.commsOneTimePadTitle),
      content: SizedBox(
        width: 420,
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
                pad.label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                l10n.commsOneTimePadGeneratedAt(
                  DateFormat.yMMMd().add_Hm().format(
                    pad.generatedAt.toLocal(),
                  ),
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.commsOneTimePadInstructions,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              CommsOneTimePadView(pad: pad),
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
      final stamp = DateFormat('yyyyMMdd-HHmmss').format(
        widget.pad.generatedAt.toLocal(),
      );
      final saved = await saveCommsSheetPdf(
        fileName: 'wayfinder-otp-$stamp.pdf',
        build: (context) => buildCommsOneTimePadPdfWidgets(
          planName: widget.planName,
          pad: widget.pad,
          title: l10n.commsOneTimePadTitle,
          instructions: l10n.commsOneTimePadInstructions,
          generatedLabel: l10n.commsOneTimePadGeneratedPrefix,
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

class CommsOneTimePadView extends StatelessWidget {
  const CommsOneTimePadView({super.key, required this.pad});

  final CommsOneTimePad pad;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mono = TextStyle(
      fontFamily: commsOneTimePadFontFamily,
      fontSize: theme.textTheme.titleSmall?.fontSize ?? 14,
      fontWeight: FontWeight.w700,
      height: 1.5,
      letterSpacing: 0,
      fontFeatures: const [FontFeature.tabularFigures()],
      color: theme.colorScheme.onSurface,
    );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: {
          0: const FixedColumnWidth(28),
          for (var c = 0; c < CommsOneTimePad.columnCount; c++)
            c + 1: const FixedColumnWidth(64),
        },
        children: [
          for (var r = 0; r < pad.groups.length; r++)
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Text(
                    (r + 1).toString().padLeft(2, '0'),
                    style: mono,
                    textAlign: TextAlign.right,
                  ),
                ),
                for (final group in pad.groups[r])
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    child: Text(
                      group,
                      style: mono,
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
