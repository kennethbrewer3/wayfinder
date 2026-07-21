import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../providers/watch_log_provider.dart';
import 'watch_log_details_section.dart';

Future<WatchLogEntry?> showWatchLogEntryDialog({
  required BuildContext context,
  required WidgetRef ref,
  WatchLogEntry? existing,
  UuidValue? markerId,
  UuidValue? zoneId,
}) {
  return showDialog<WatchLogEntry>(
    context: context,
    builder: (context) {
      return WatchLogEntryDialog(
        existing: existing,
        markerId: markerId ?? existing?.markerId,
        zoneId: zoneId ?? existing?.zoneId,
      );
    },
  ).then((result) async {
    if (result == null) {
      return null;
    }
    if (existing == null) {
      return ref.read(watchLogEntriesProvider.notifier).create(result);
    }
    return ref.read(watchLogEntriesProvider.notifier).updateEntry(result);
  });
}

class WatchLogEntryDialog extends StatefulWidget {
  const WatchLogEntryDialog({
    super.key,
    this.existing,
    this.markerId,
    this.zoneId,
  });

  final WatchLogEntry? existing;
  final UuidValue? markerId;
  final UuidValue? zoneId;

  @override
  State<WatchLogEntryDialog> createState() => _WatchLogEntryDialogState();
}

class _WatchLogEntryDialogState extends State<WatchLogEntryDialog> {
  late DateTime _occurredAt;
  late WatchLogSeverity _severity;
  late final TextEditingController _authorController;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _occurredAt = existing?.occurredAt.toLocal() ?? DateTime.now();
    _severity = WatchLogSeverity.parse(existing?.severity);
    _authorController = TextEditingController(text: existing?.author ?? '');
    _textController = TextEditingController(text: existing?.text ?? '');
  }

  @override
  void dispose() {
    _authorController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) {
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_occurredAt),
    );
    if (time == null || !mounted) {
      return;
    }
    setState(() {
      _occurredAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.watchLogTextRequired)),
      );
      return;
    }
    final now = DateTime.now().toUtc();
    final existing = widget.existing;
    final author = _authorController.text.trim();
    Navigator.of(context).pop(
      WatchLogEntry(
        id: existing?.id,
        occurredAt: _occurredAt.toUtc(),
        author: author.isEmpty ? null : author,
        severity: _severity.storageValue,
        text: text,
        markerId: widget.markerId,
        zoneId: widget.zoneId,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final whenLabel = DateFormat.yMMMd().add_Hm().format(_occurredAt);

    return AlertDialog(
      title: Text(
        widget.existing == null
            ? l10n.watchLogAddEntryTitle
            : l10n.watchLogEditEntryTitle,
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.watchLogSubtitle),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.watchLogOccurredAtLabel),
                subtitle: Text(whenLabel),
                trailing: const Icon(Icons.schedule),
                onTap: _pickDateTime,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _authorController,
                decoration: InputDecoration(
                  labelText: l10n.watchLogAuthorLabel,
                  hintText: l10n.watchLogAuthorHint,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<WatchLogSeverity>(
                initialValue: _severity,
                decoration: InputDecoration(
                  labelText: l10n.watchLogSeverityLabel,
                ),
                items: [
                  for (final severity in WatchLogSeverity.values)
                    DropdownMenuItem(
                      value: severity,
                      child: Text(watchLogSeverityLabel(l10n, severity)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _severity = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: l10n.watchLogTextLabel,
                  hintText: l10n.watchLogTextHint,
                ),
                maxLines: 4,
                autofocus: widget.existing == null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(
            widget.existing == null ? l10n.actionCreate : l10n.actionSave,
          ),
        ),
      ],
    );
  }
}
