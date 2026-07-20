import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/logging/app_logger.dart';
import '../../tides/providers/tides_providers.dart';

class SettingsTidesTab extends ConsumerStatefulWidget {
  const SettingsTidesTab({super.key});

  @override
  ConsumerState<SettingsTidesTab> createState() => _SettingsTidesTabState();
}

class _SettingsTidesTabState extends ConsumerState<SettingsTidesTab> {
  static final _log = AppLogger.logSettings;
  bool _importing = false;
  String? _importingRegionId;

  Future<void> _importRegion(TideCoastalRegion region) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _importing = true;
      _importingRegionId = region.id;
    });
    try {
      final pack = await ref
          .read(tidesRepositoryProvider)
          .importCoastalRegion(region.id);
      refreshTidePacks(ref);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.tidesImportSuccess(pack.name, pack.stationCount),
          ),
        ),
      );
    } catch (error, stackTrace) {
      _log.error(
        '🌊 Tide pack import failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tidesImportFailed(error.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _importing = false;
          _importingRegionId = null;
        });
      }
    }
  }

  Future<void> _setActive(TidePackInfo pack, bool active) async {
    try {
      await ref
          .read(tidesRepositoryProvider)
          .setPackActive(pack.id, active: active);
      refreshTidePacks(ref);
    } catch (error, stackTrace) {
      _log.error(
        '🌊 Tide pack setActive failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tidesActionFailed(error.toString()))),
      );
    }
  }

  Future<void> _deletePack(TidePackInfo pack) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.tidesDeletePack),
          content: Text(l10n.tidesDeletePackConfirm(pack.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.actionDelete),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }
    try {
      await ref.read(tidesRepositoryProvider).deletePack(pack.id);
      refreshTidePacks(ref);
    } catch (error, stackTrace) {
      _log.error(
        '🌊 Tide pack delete failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tidesActionFailed(error.toString()))),
      );
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final packsAsync = ref.watch(tidePacksProvider);
    final regionsAsync = ref.watch(tideCoastalRegionsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.tidesSettingsTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          l10n.tidesSettingsSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Text(l10n.tidesInstalledPacks, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        packsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text(l10n.tidesActionFailed(error.toString())),
          data: (packs) {
            if (packs.isEmpty) {
              return Text(l10n.tidesNoPacksInstalled);
            }
            return Column(
              children: [
                for (final pack in packs)
                  Card(
                    child: ListTile(
                      title: Text(pack.name),
                      subtitle: Text(
                        l10n.tidesPackMeta(
                          pack.stationCount,
                          _formatBytes(pack.sizeBytes),
                          DateFormat.yMMMd().format(pack.addedAt.toLocal()),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: pack.isActive,
                            onChanged: _importing
                                ? null
                                : (value) => unawaited(_setActive(pack, value)),
                          ),
                          IconButton(
                            tooltip: l10n.tidesDeletePack,
                            onPressed: _importing
                                ? null
                                : () => unawaited(_deletePack(pack)),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Text(l10n.tidesGetCoastalPacks, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          l10n.tidesGetCoastalPacksHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        if (_importing)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(l10n.tidesImportInProgress)),
              ],
            ),
          ),
        regionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text(l10n.tidesActionFailed(error.toString())),
          data: (regions) {
            return Column(
              children: [
                for (final region in regions)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(region.name),
                    subtitle: Text(
                      l10n.tidesRegionBbox(
                        region.minLatitude.toStringAsFixed(1),
                        region.minLongitude.toStringAsFixed(1),
                        region.maxLatitude.toStringAsFixed(1),
                        region.maxLongitude.toStringAsFixed(1),
                      ),
                    ),
                    trailing: FilledButton.tonal(
                      onPressed: _importing
                          ? null
                          : () => unawaited(_importRegion(region)),
                      child: _importingRegionId == region.id
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.tidesDownloadPack),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
