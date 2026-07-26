import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/serverpod_client.dart';
import '../../access/providers/access_session_provider.dart';
import '../../markers/providers/markers_provider.dart';
import '../../lines/providers/zones_provider.dart';

final _deletedMarkersProvider = FutureProvider.autoDispose<List<MapMarker>>((
  ref,
) {
  return ref.watch(serverClientProvider).mapMarker.listDeletedMarkers();
});

final _deletedZonesProvider = FutureProvider.autoDispose<List<MapZone>>((ref) {
  return ref.watch(serverClientProvider).mapZone.listDeletedZones();
});

class SettingsTrashTab extends ConsumerStatefulWidget {
  const SettingsTrashTab({super.key});

  @override
  ConsumerState<SettingsTrashTab> createState() => _SettingsTrashTabState();
}

class _SettingsTrashTabState extends ConsumerState<SettingsTrashTab> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canEdit = !ref.watch(mapEditsLockedByRoleProvider);
    final markersAsync = ref.watch(_deletedMarkersProvider);
    final zonesAsync = ref.watch(_deletedZonesProvider);

    if (!canEdit) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(l10n.mapObjectTrashPermissionDenied),
        ),
      );
    }

    return markersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(l10n.mapObjectTrashLoadFailed('$error')),
      ),
      data: (markers) {
        return zonesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(l10n.mapObjectTrashLoadFailed('$error')),
          ),
          data: (zones) {
            if (markers.isEmpty && zones.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    l10n.mapObjectTrashHelp,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  Text(l10n.mapObjectTrashEmpty),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        l10n.mapObjectTrashHelp,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.mapObjectTrashRestoreAll,
                      onPressed: _busy
                          ? null
                          : () => _restoreAll(markers: markers, zones: zones),
                      icon: const Icon(Icons.restore_from_trash),
                    ),
                    IconButton(
                      tooltip: l10n.mapObjectTrashPurgeAll,
                      onPressed: _busy
                          ? null
                          : () => _purgeAll(markers: markers, zones: zones),
                      icon: const Icon(Icons.delete_forever),
                    ),
                  ],
                ),
                if (markers.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    l10n.mapObjectTrashMarkersSection,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  for (final marker in markers)
                    _TrashTile(
                      title: marker.name,
                      subtitle: _deletedSubtitle(
                        l10n,
                        deletedAt: marker.deletedAt,
                        deletedBy: marker.deletedByUsername,
                      ),
                      enabled: !_busy,
                      onRestore: () async {
                        await ref
                            .read(serverClientProvider)
                            .mapMarker
                            .restoreMarker(marker.id);
                        ref.invalidate(_deletedMarkersProvider);
                        ref.invalidate(markersProvider);
                      },
                      onPurge: () async {
                        final confirmed = await _confirmPurge(
                          context,
                          l10n,
                          marker.name,
                        );
                        if (!confirmed) {
                          return;
                        }
                        await ref
                            .read(serverClientProvider)
                            .mapMarker
                            .purgeDeletedMarker(marker.id);
                        ref.invalidate(_deletedMarkersProvider);
                      },
                      l10n: l10n,
                    ),
                ],
                if (zones.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    l10n.mapObjectTrashZonesSection,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  for (final zone in zones)
                    _TrashTile(
                      title: zone.name,
                      subtitle: _deletedSubtitle(
                        l10n,
                        deletedAt: zone.deletedAt,
                        deletedBy: zone.deletedByUsername,
                      ),
                      enabled: !_busy,
                      onRestore: () async {
                        await ref
                            .read(serverClientProvider)
                            .mapZone
                            .restoreZone(zone.id);
                        ref.invalidate(_deletedZonesProvider);
                        ref.read(zonesProvider.notifier).reload();
                      },
                      onPurge: () async {
                        final confirmed = await _confirmPurge(
                          context,
                          l10n,
                          zone.name,
                        );
                        if (!confirmed) {
                          return;
                        }
                        await ref
                            .read(serverClientProvider)
                            .mapZone
                            .purgeDeletedZone(zone.id);
                        ref.invalidate(_deletedZonesProvider);
                      },
                      l10n: l10n,
                    ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _restoreAll({
    required List<MapMarker> markers,
    required List<MapZone> zones,
  }) async {
    setState(() => _busy = true);
    try {
      final client = ref.read(serverClientProvider);
      for (final marker in markers) {
        await client.mapMarker.restoreMarker(marker.id);
      }
      for (final zone in zones) {
        await client.mapZone.restoreZone(zone.id);
      }
      ref.invalidate(_deletedMarkersProvider);
      ref.invalidate(_deletedZonesProvider);
      ref.invalidate(markersProvider);
      ref.read(zonesProvider.notifier).reload();
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _purgeAll({
    required List<MapMarker> markers,
    required List<MapZone> zones,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirmPurgeAll(context, l10n);
    if (!confirmed) {
      return;
    }

    setState(() => _busy = true);
    try {
      final client = ref.read(serverClientProvider);
      for (final marker in markers) {
        await client.mapMarker.purgeDeletedMarker(marker.id);
      }
      for (final zone in zones) {
        await client.mapZone.purgeDeletedZone(zone.id);
      }
      ref.invalidate(_deletedMarkersProvider);
      ref.invalidate(_deletedZonesProvider);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  static String _deletedSubtitle(
    AppLocalizations l10n, {
    required DateTime? deletedAt,
    required String? deletedBy,
  }) {
    final user = (deletedBy == null || deletedBy.trim().isEmpty)
        ? l10n.mapObjectAttributionUnknown
        : deletedBy.trim();
    final when = deletedAt?.toLocal().toString() ?? '';
    final by = l10n.mapObjectTrashDeletedBy(user);
    return when.isEmpty ? by : '$by · $when';
  }

  static Future<bool> _confirmPurge(
    BuildContext context,
    AppLocalizations l10n,
    String name,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.mapObjectTrashPurgeConfirmTitle),
        content: Text(l10n.mapObjectTrashPurgeConfirmBody(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionClose),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.mapObjectTrashPurge),
          ),
        ],
      ),
    );
    return result == true;
  }

  static Future<bool> _confirmPurgeAll(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.mapObjectTrashPurgeAllConfirmTitle),
        content: Text(l10n.mapObjectTrashPurgeAllConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionClose),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.mapObjectTrashPurgeAll),
          ),
        ],
      ),
    );
    return result == true;
  }
}

class _TrashTile extends StatelessWidget {
  const _TrashTile({
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onRestore,
    required this.onPurge,
    required this.l10n,
  });

  final String title;
  final String subtitle;
  final bool enabled;
  final Future<void> Function() onRestore;
  final Future<void> Function() onPurge;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              tooltip: l10n.mapObjectTrashRestore,
              onPressed: enabled ? () => onRestore() : null,
              icon: const Icon(Icons.restore_from_trash),
            ),
            IconButton(
              tooltip: l10n.mapObjectTrashPurge,
              onPressed: enabled ? () => onPurge() : null,
              icon: const Icon(Icons.delete_forever),
            ),
          ],
        ),
      ),
    );
  }
}
