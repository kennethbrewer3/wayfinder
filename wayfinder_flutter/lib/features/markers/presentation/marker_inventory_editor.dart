import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../models/marker_inventory.dart';

class MarkerInventoryEditor extends StatelessWidget {
  const MarkerInventoryEditor({
    super.key,
    required this.items,
    required this.onChanged,
    this.initiallyExpanded = false,
  });

  final List<MarkerInventoryItem> items;
  final ValueChanged<List<MarkerInventoryItem>> onChanged;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ExpansionTile(
      initiallyExpanded: initiallyExpanded || items.isNotEmpty,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 4),
      title: Text(l10n.markerInventoryTitle),
      subtitle: Text(
        items.isEmpty
            ? l10n.markerInventoryEmptyHelp
            : l10n.markerInventoryItemCount(items.length),
        style: theme.textTheme.bodySmall,
      ),
      children: [
        for (final (index, item) in items.indexed) ...[
          if (index > 0) const SizedBox(height: 8),
          _InventoryItemCard(
            key: ValueKey(item.id),
            item: item,
            onChanged: (updated) {
              final next = [...items];
              next[index] = updated;
              onChanged(next);
            },
            onRemove: () {
              final next = [...items]..removeAt(index);
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
                ...items,
                MarkerInventoryItem(
                  id: newMarkerInventoryItemId(),
                  name: '',
                  quantity: 1,
                  unit: 'ea',
                  category: MarkerInventoryCategory.food,
                  lastAuditedAt: DateTime.now().toUtc(),
                ),
              ]);
            },
            icon: const Icon(Icons.add),
            label: Text(l10n.markerInventoryAddItem),
          ),
        ),
      ],
    );
  }
}

class _InventoryItemCard extends StatelessWidget {
  const _InventoryItemCard({
    super.key,
    required this.item,
    required this.onChanged,
    required this.onRemove,
  });

  final MarkerInventoryItem item;
  final ValueChanged<MarkerInventoryItem> onChanged;
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
                    l10n.markerInventoryItemHeading,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  tooltip: l10n.markerInventoryRemoveItem,
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            TextFormField(
              initialValue: item.name,
              decoration: InputDecoration(
                labelText: l10n.markerInventoryNameLabel,
              ),
              textInputAction: TextInputAction.next,
              onChanged: (value) => onChanged(item.copyWith(name: value)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _formatQuantity(item.quantity),
                    decoration: InputDecoration(
                      labelText: l10n.markerInventoryQuantityLabel,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    onChanged: (value) {
                      final parsed = double.tryParse(value.trim());
                      if (parsed != null) {
                        onChanged(item.copyWith(quantity: parsed));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: markerInventoryUnitOptions.contains(item.unit)
                        ? item.unit
                        : markerInventoryUnitOptions.first,
                    decoration: InputDecoration(
                      labelText: l10n.markerInventoryUnitLabel,
                    ),
                    items: [
                      for (final unit in markerInventoryUnitOptions)
                        DropdownMenuItem(value: unit, child: Text(unit)),
                      if (!markerInventoryUnitOptions.contains(item.unit))
                        DropdownMenuItem(
                          value: item.unit,
                          child: Text(item.unit),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        onChanged(item.copyWith(unit: value));
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<MarkerInventoryCategory>(
              initialValue: item.category,
              decoration: InputDecoration(
                labelText: l10n.markerInventoryCategoryLabel,
              ),
              items: [
                for (final category in MarkerInventoryCategory.values)
                  DropdownMenuItem(
                    value: category,
                    child: Text(_categoryLabel(l10n, category)),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  onChanged(item.copyWith(category: value));
                }
              },
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: item.expiresAt?.toLocal() ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      helpText: l10n.markerInventoryExpiryLabel,
                    );
                    if (picked != null) {
                      onChanged(
                        item.copyWith(
                          expiresAt: DateTime.utc(
                            picked.year,
                            picked.month,
                            picked.day,
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.event_outlined),
                  label: Text(
                    item.expiresAt == null
                        ? l10n.markerInventorySetExpiry
                        : l10n.markerInventoryExpiryValue(
                            dateFormat.format(item.expiresAt!.toLocal()),
                          ),
                  ),
                ),
                if (item.expiresAt != null)
                  TextButton(
                    onPressed: () => onChanged(item.copyWith(expiresAt: null)),
                    child: Text(l10n.markerInventoryClearExpiry),
                  ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate:
                          item.lastAuditedAt?.toLocal() ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      helpText: l10n.markerInventoryLastAuditedLabel,
                    );
                    if (picked != null) {
                      onChanged(
                        item.copyWith(
                          lastAuditedAt: DateTime.utc(
                            picked.year,
                            picked.month,
                            picked.day,
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.fact_check_outlined),
                  label: Text(
                    item.lastAuditedAt == null
                        ? l10n.markerInventorySetLastAudited
                        : l10n.markerInventoryLastAuditedValue(
                            dateFormat.format(item.lastAuditedAt!.toLocal()),
                          ),
                  ),
                ),
                TextButton(
                  onPressed: () => onChanged(
                    item.copyWith(lastAuditedAt: DateTime.now().toUtc()),
                  ),
                  child: Text(l10n.markerInventoryMarkAuditedNow),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatQuantity(double quantity) {
    if (quantity == quantity.roundToDouble()) {
      return quantity.toInt().toString();
    }
    return quantity.toString();
  }

  static String _categoryLabel(
    AppLocalizations l10n,
    MarkerInventoryCategory category,
  ) {
    return switch (category) {
      MarkerInventoryCategory.food => l10n.markerInventoryCategoryFood,
      MarkerInventoryCategory.water => l10n.markerInventoryCategoryWater,
      MarkerInventoryCategory.medical => l10n.markerInventoryCategoryMedical,
      MarkerInventoryCategory.ammo => l10n.markerInventoryCategoryAmmo,
      MarkerInventoryCategory.other => l10n.markerInventoryCategoryOther,
    };
  }
}

/// Drops blank-named items and normalizes for persistence.
List<MarkerInventoryItem> sanitizeMarkerInventoryItems(
  List<MarkerInventoryItem> items,
) {
  return [
    for (final item in items)
      if (item.name.trim().isNotEmpty)
        item.copyWith(
          name: item.name.trim(),
          unit: item.unit.trim().isEmpty ? 'ea' : item.unit.trim(),
        ),
  ];
}
