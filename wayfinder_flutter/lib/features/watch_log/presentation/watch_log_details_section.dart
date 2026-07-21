import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../providers/watch_log_provider.dart';
import 'watch_log_entry_dialog.dart';

class WatchLogDetailsSection extends ConsumerWidget {
  const WatchLogDetailsSection({
    super.key,
    this.markerId,
    this.zoneId,
    this.maxVisible = 5,
  });

  final UuidValue? markerId;
  final UuidValue? zoneId;
  final int maxVisible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final entriesAsync = ref.watch(watchLogEntriesProvider);

    return entriesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (all) {
        final entries = [
          for (final entry in all)
            if ((markerId != null && entry.markerId == markerId) ||
                (zoneId != null && entry.zoneId == zoneId))
              entry,
        ];
        final visible = entries.take(maxVisible).toList();
        final remaining = entries.length - visible.length;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.55,
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.watchLogTitle,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          await showWatchLogEntryDialog(
                            context: context,
                            ref: ref,
                            markerId: markerId,
                            zoneId: zoneId,
                          );
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(l10n.watchLogAddEntry),
                      ),
                    ],
                  ),
                  Text(
                    l10n.watchLogObjectHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (visible.isEmpty)
                    Text(
                      l10n.watchLogEmptyForObject,
                      style: theme.textTheme.bodySmall,
                    )
                  else
                    for (final (index, entry) in visible.indexed) ...[
                      if (index > 0) const Divider(height: 16),
                      _WatchLogEntryTile(
                        entry: entry,
                        onEdit: () async {
                          await showWatchLogEntryDialog(
                            context: context,
                            ref: ref,
                            existing: entry,
                          );
                        },
                        onDelete: () async {
                          await ref
                              .read(watchLogEntriesProvider.notifier)
                              .delete(entry.id);
                        },
                      ),
                    ],
                  if (remaining > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.watchLogMoreEntries(remaining),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WatchLogEntryTile extends StatelessWidget {
  const _WatchLogEntryTile({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final WatchLogEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final severity = WatchLogSeverity.parse(entry.severity);
    final when = DateFormat.yMMMd().add_Hm().format(entry.occurredAt.toLocal());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _severityIcon(severity),
              size: 16,
              color: _severityColor(theme, severity),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '$when · ${watchLogSeverityLabel(l10n, severity)}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            IconButton(
              tooltip: l10n.actionEdit,
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              tooltip: l10n.actionDelete,
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, size: 18),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        if (entry.author != null && entry.author!.trim().isNotEmpty)
          Text(
            entry.author!,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        Text(entry.text, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

IconData _severityIcon(WatchLogSeverity severity) {
  return switch (severity) {
    WatchLogSeverity.info => Icons.info_outline,
    WatchLogSeverity.notice => Icons.campaign_outlined,
    WatchLogSeverity.warning => Icons.warning_amber_outlined,
    WatchLogSeverity.critical => Icons.error_outline,
  };
}

Color _severityColor(ThemeData theme, WatchLogSeverity severity) {
  return switch (severity) {
    WatchLogSeverity.info => theme.colorScheme.primary,
    WatchLogSeverity.notice => theme.colorScheme.tertiary,
    WatchLogSeverity.warning => theme.colorScheme.tertiary,
    WatchLogSeverity.critical => theme.colorScheme.error,
  };
}

String watchLogSeverityLabel(AppLocalizations l10n, WatchLogSeverity severity) {
  return switch (severity) {
    WatchLogSeverity.info => l10n.watchLogSeverityInfo,
    WatchLogSeverity.notice => l10n.watchLogSeverityNotice,
    WatchLogSeverity.warning => l10n.watchLogSeverityWarning,
    WatchLogSeverity.critical => l10n.watchLogSeverityCritical,
  };
}
