import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../models/marker_checklists.dart';

class MarkerChecklistsEditor extends StatelessWidget {
  const MarkerChecklistsEditor({
    super.key,
    required this.checklists,
    required this.onChanged,
    this.initiallyExpanded = false,
  });

  final List<MarkerChecklist> checklists;
  final ValueChanged<List<MarkerChecklist>> onChanged;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ExpansionTile(
      initiallyExpanded: initiallyExpanded || checklists.isNotEmpty,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 4),
      title: Text(l10n.markerChecklistsTitle),
      subtitle: Text(
        checklists.isEmpty
            ? l10n.markerChecklistsEmptyHelp
            : l10n.markerChecklistsCount(checklists.length),
        style: theme.textTheme.bodySmall,
      ),
      children: [
        for (final (index, checklist) in checklists.indexed) ...[
          if (index > 0) const SizedBox(height: 8),
          _ChecklistCard(
            key: ValueKey(checklist.id),
            checklist: checklist,
            onChanged: (updated) {
              final next = [...checklists];
              next[index] = updated;
              onChanged(next);
            },
            onRemove: () {
              final next = [...checklists]..removeAt(index);
              onChanged(next);
            },
          ),
        ],
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              onChanged([
                ...checklists,
                MarkerChecklist(
                  id: newMarkerChecklistId(),
                  name: '',
                  lastAuditedAt: DateTime.now().toUtc(),
                  items: [
                    MarkerChecklistItem(
                      id: newMarkerChecklistItemId(),
                      label: '',
                    ),
                  ],
                ),
              ]);
            },
            icon: const Icon(Icons.add),
            label: Text(l10n.markerChecklistsAddChecklist),
          ),
        ),
      ],
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard({
    super.key,
    required this.checklist,
    required this.onChanged,
    required this.onRemove,
  });

  final MarkerChecklist checklist;
  final ValueChanged<MarkerChecklist> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd();

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.markerChecklistsChecklistHeading,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  tooltip: l10n.markerChecklistsRemoveChecklist,
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            TextFormField(
              initialValue: checklist.name,
              decoration: InputDecoration(
                labelText: l10n.markerChecklistsNameLabel,
                isDense: true,
              ),
              onChanged: (value) => onChanged(checklist.copyWith(name: value)),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: checklist.notes ?? '',
              decoration: InputDecoration(
                labelText: l10n.markerChecklistsNotesLabel,
                isDense: true,
              ),
              maxLines: 2,
              onChanged: (value) => onChanged(
                checklist.copyWith(notes: value.trim().isEmpty ? null : value),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    checklist.lastAuditedAt == null
                        ? l10n.markerChecklistsLastAuditedNever
                        : l10n.markerChecklistsLastAudited(
                            dateFormat.format(
                              checklist.lastAuditedAt!.toLocal(),
                            ),
                          ),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                TextButton(
                  onPressed: () => onChanged(
                    checklist.copyWith(lastAuditedAt: DateTime.now().toUtc()),
                  ),
                  child: Text(l10n.markerChecklistsMarkAudited),
                ),
              ],
            ),
            const SizedBox(height: 4),
            for (final (itemIndex, item) in checklist.items.indexed) ...[
              if (itemIndex > 0) const SizedBox(height: 4),
              _ChecklistItemRow(
                key: ValueKey(item.id),
                item: item,
                onChanged: (updated) {
                  final next = [...checklist.items];
                  next[itemIndex] = updated;
                  onChanged(checklist.copyWith(items: next));
                },
                onRemove: () {
                  final next = [...checklist.items]..removeAt(itemIndex);
                  onChanged(checklist.copyWith(items: next));
                },
              ),
            ],
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  onChanged(
                    checklist.copyWith(
                      items: [
                        ...checklist.items,
                        MarkerChecklistItem(
                          id: newMarkerChecklistItemId(),
                          label: '',
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.markerChecklistsAddItem),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistItemRow extends StatelessWidget {
  const _ChecklistItemRow({
    super.key,
    required this.item,
    required this.onChanged,
    required this.onRemove,
  });

  final MarkerChecklistItem item;
  final ValueChanged<MarkerChecklistItem> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: item.done,
          onChanged: (value) => onChanged(item.copyWith(done: value == true)),
        ),
        Expanded(
          child: Column(
            children: [
              TextFormField(
                initialValue: item.label,
                decoration: InputDecoration(
                  labelText: l10n.markerChecklistsItemLabel,
                  isDense: true,
                ),
                onChanged: (value) => onChanged(item.copyWith(label: value)),
              ),
              const SizedBox(height: 4),
              TextFormField(
                initialValue: item.notes ?? '',
                decoration: InputDecoration(
                  labelText: l10n.markerChecklistsItemNotesLabel,
                  isDense: true,
                ),
                onChanged: (value) => onChanged(
                  item.copyWith(notes: value.trim().isEmpty ? null : value),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: l10n.markerChecklistsRemoveItem,
          onPressed: onRemove,
          icon: const Icon(Icons.close, size: 18),
        ),
      ],
    );
  }
}
