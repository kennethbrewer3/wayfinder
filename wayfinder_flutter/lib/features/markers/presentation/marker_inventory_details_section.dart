import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../models/marker_inventory.dart';
import '../providers/markers_provider.dart';

class MarkerInventoryDetailsSection extends ConsumerWidget {
  const MarkerInventoryDetailsSection({
    super.key,
    required this.marker,
  });

  final MapMarker marker;

  MapMarker _resolvedMarker(WidgetRef ref) {
    final markers = ref.watch(markersProvider).valueOrNull;
    if (markers == null) {
      return marker;
    }
    for (final candidate in markers) {
      if (candidate.id == marker.id) {
        return candidate;
      }
    }
    return marker;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final inventory = MarkerInventory.fromMarkerInventoryJson(
      _resolvedMarker(ref).inventoryJson,
    );
    if (inventory.isEmpty) {
      return const SizedBox.shrink();
    }

    final dateFormat = DateFormat.yMMMd();
    final now = DateTime.now().toUtc();

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
              Text(
                l10n.markerInventoryTitle,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              for (final (index, item) in inventory.items.indexed) ...[
                if (index > 0) const Divider(height: 16),
                _InventoryDetailRow(
                  item: item,
                  l10n: l10n,
                  dateFormat: dateFormat,
                  now: now,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InventoryDetailRow extends StatelessWidget {
  const _InventoryDetailRow({
    required this.item,
    required this.l10n,
    required this.dateFormat,
    required this.now,
  });

  final MarkerInventoryItem item;
  final AppLocalizations l10n;
  final DateFormat dateFormat;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final qty = item.quantity == item.quantity.roundToDouble()
        ? item.quantity.toInt().toString()
        : item.quantity.toString();
    final expiryTone = _expiryTone(item, now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 2),
        Text(
          l10n.markerInventoryDetailQuantity(qty, item.unit),
          style: theme.textTheme.bodyMedium,
        ),
        Text(
          l10n.markerInventoryDetailCategory(
            _categoryLabel(l10n, item.category),
          ),
          style: theme.textTheme.bodySmall,
        ),
        Text(
          item.expiresAt == null
              ? l10n.markerInventoryDetailNoExpiry
              : l10n.markerInventoryDetailExpiry(
                  dateFormat.format(item.expiresAt!.toLocal()),
                ),
          style: theme.textTheme.bodySmall?.copyWith(
            color: expiryTone == null
                ? null
                : switch (expiryTone) {
                    _ExpiryTone.expired => theme.colorScheme.error,
                    _ExpiryTone.soon => theme.colorScheme.tertiary,
                  },
            fontWeight: expiryTone == null ? null : FontWeight.w600,
          ),
        ),
        Text(
          item.lastAuditedAt == null
              ? l10n.markerInventoryDetailNeverAudited
              : l10n.markerInventoryDetailLastAudited(
                  dateFormat.format(item.lastAuditedAt!.toLocal()),
                ),
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  static _ExpiryTone? _expiryTone(MarkerInventoryItem item, DateTime now) {
    final expiresAt = item.expiresAt;
    if (expiresAt == null) {
      return null;
    }
    final utc = expiresAt.toUtc();
    if (utc.isBefore(now)) {
      return _ExpiryTone.expired;
    }
    if (!utc.isAfter(now.add(const Duration(days: 90)))) {
      return _ExpiryTone.soon;
    }
    return null;
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

enum _ExpiryTone { expired, soon }
