import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/presentation/animated_status_dot_icon_button.dart';
import '../../settings/providers/pmtiles_providers.dart';
import '../models/pmtiles_load_status.dart';
import '../providers/pmtiles_load_status_provider.dart';

class MapTilesLoadIndicator extends ConsumerWidget {
  const MapTilesLoadIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final effectiveStatus = _effectiveStatus(ref, l10n);

    return AnimatedStatusDotIconButton(
      isReady: effectiveStatus.isReady,
      isLoading: effectiveStatus.isLoading,
      tooltip: effectiveStatus.isReady
          ? l10n.mapTilesReadyTooltip
          : effectiveStatus.isLoading
              ? l10n.mapTilesLoadingTooltip
              : l10n.mapTilesNotReadyTooltip,
      icon: Icons.layers_outlined,
      onPressed: () => _showStatusDialog(context, ref),
    );
  }

  PmtilesLoadStatus _effectiveStatus(WidgetRef ref, AppLocalizations l10n) {
    final metadataAsync = ref.watch(pmtilesEnabledMetadataProvider);
    final status = ref.watch(pmtilesLoadStatusProvider);

    if (metadataAsync.isLoading) {
      return status.copyWith(
        isReady: false,
        isLoading: true,
        statusMessage: l10n.statusLoading,
      );
    }

    if (metadataAsync.hasError) {
      return PmtilesLoadStatus(
        isReady: false,
        isLoading: false,
        failureMessage: metadataAsync.error.toString(),
        statusMessage: l10n.mapTilesCatalogLoadFailed,
      );
    }

    return status;
  }

  void _showStatusDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Consumer(
          builder: (context, ref, _) {
            final l10n = AppLocalizations.of(context)!;
            final status = _effectiveStatus(ref, l10n);
            return AlertDialog(
              title: Text(
                status.isReady
                    ? l10n.mapTilesReadyTooltip
                    : status.isLoading
                        ? l10n.mapTilesLoadingTitle
                        : l10n.mapTilesNotReadyTooltip,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (status.isLoading) ...[
                    ActivityProgressBar(
                      progress: _loadProgress(status),
                      label: _loadProgressLabel(status, l10n),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (status.statusMessage != null) Text(status.statusMessage!),
                  if (status.failureMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      status.failureMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  if (status.isLoading && status.loadingLayerName != null) ...[
                    const SizedBox(height: 12),
                    Text(l10n.mapTilesOpeningLayer(status.loadingLayerName!)),
                    const SizedBox(height: 8),
                    Text(l10n.mapTilesLargeArchiveHelp),
                  ],
                  if (!status.isLoading && status.enabledCount > 0) ...[
                    const SizedBox(height: 12),
                    Text(
                      l10n.mapTilesLayersPrepared(
                        status.loadedCount,
                        status.enabledCount,
                      ),
                    ),
                  ],
                  if (status.activeLayerName != null) ...[
                    const SizedBox(height: 8),
                    Text(l10n.mapTilesActiveLayer(status.activeLayerName!)),
                  ],
                  if (status.isReady) ...[
                    const SizedBox(height: 12),
                    Text(l10n.mapTilesReadyHelp),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.actionOk),
                ),
              ],
            );
          },
        );
      },
    );
  }

  double? _loadProgress(PmtilesLoadStatus status) {
    if (status.enabledCount <= 0) {
      return null;
    }
    if (status.loadingLayerName != null &&
        status.loadedCount >= status.enabledCount) {
      return null;
    }
    return status.loadedCount / status.enabledCount;
  }

  String _loadProgressLabel(PmtilesLoadStatus status, AppLocalizations l10n) {
    if (status.loadingLayerName != null &&
        status.loadedCount >= status.enabledCount) {
      return l10n.mapTilesOpeningProgress(status.loadingLayerName!);
    }
    if (status.enabledCount > 0) {
      return l10n.mapTilesLayersPrepared(
        status.loadedCount,
        status.enabledCount,
      );
    }
    return l10n.statusWorking;
  }
}
