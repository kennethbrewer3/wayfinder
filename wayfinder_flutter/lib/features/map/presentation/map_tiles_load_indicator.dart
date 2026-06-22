import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/presentation/animated_status_dot_icon_button.dart';
import '../../settings/providers/pmtiles_providers.dart';
import '../models/pmtiles_load_status.dart';
import '../providers/pmtiles_load_status_provider.dart';

class MapTilesLoadIndicator extends ConsumerWidget {
  const MapTilesLoadIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveStatus = _effectiveStatus(ref);

    return AnimatedStatusDotIconButton(
      isReady: effectiveStatus.isReady,
      isLoading: effectiveStatus.isLoading,
      tooltip: effectiveStatus.isReady
          ? 'Map tiles ready'
          : effectiveStatus.isLoading
              ? 'Map tiles loading'
              : 'Map tiles not ready',
      icon: Icons.layers_outlined,
      onPressed: () => _showStatusDialog(context, ref),
    );
  }

  PmtilesLoadStatus _effectiveStatus(WidgetRef ref) {
    final metadataAsync = ref.watch(pmtilesEnabledMetadataProvider);
    final status = ref.watch(pmtilesLoadStatusProvider);

    if (metadataAsync.isLoading) {
      return status.copyWith(
        isReady: false,
        isLoading: true,
        statusMessage: 'Loading map tile catalog…',
      );
    }

    if (metadataAsync.hasError) {
      return PmtilesLoadStatus(
        isReady: false,
        isLoading: false,
        failureMessage: metadataAsync.error.toString(),
        statusMessage: 'Failed to load map tile catalog.',
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
            final status = _effectiveStatus(ref);
            return AlertDialog(
              title: Text(
                status.isReady
                    ? 'Map tiles ready'
                    : status.isLoading
                        ? 'Loading map tiles'
                        : 'Map tiles not ready',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (status.isLoading) ...[
                    ActivityProgressBar(
                      progress: _loadProgress(status),
                      label: _loadProgressLabel(status),
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
                    Text('Opening: ${status.loadingLayerName}'),
                    const SizedBox(height: 8),
                    const Text(
                      'Large .pmtiles archives can take several minutes to open '
                      'before tiles appear. Panning and zooming will fetch tiles '
                      'as the map becomes ready.',
                    ),
                  ],
                  if (!status.isLoading && status.enabledCount > 0) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Layers prepared: ${status.loadedCount} of ${status.enabledCount}',
                    ),
                  ],
                  if (status.activeLayerName != null) ...[
                    const SizedBox(height: 8),
                    Text('Active layer: ${status.activeLayerName}'),
                  ],
                  if (status.isReady) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Tiles for the current map view should be visible. If the '
                      'map is still blank, try zooming to the layer coverage area.',
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('OK'),
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

  String _loadProgressLabel(PmtilesLoadStatus status) {
    if (status.loadingLayerName != null &&
        status.loadedCount >= status.enabledCount) {
      return 'Opening ${status.loadingLayerName}…';
    }
    if (status.enabledCount > 0) {
      return 'Layers prepared: ${status.loadedCount} of ${status.enabledCount}';
    }
    return 'Working…';
  }
}
