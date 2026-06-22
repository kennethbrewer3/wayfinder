import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/providers/pmtiles_providers.dart';
import '../models/pmtiles_load_status.dart';
import '../providers/pmtiles_load_status_provider.dart';

class MapTilesLoadIndicator extends ConsumerWidget {
  const MapTilesLoadIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metadataAsync = ref.watch(pmtilesEnabledMetadataProvider);
    final status = ref.watch(pmtilesLoadStatusProvider);

    final effectiveStatus = metadataAsync.isLoading
        ? status.copyWith(
            isReady: false,
            isLoading: true,
            statusMessage: 'Loading map tile catalog…',
          )
        : metadataAsync.hasError
            ? PmtilesLoadStatus(
                isReady: false,
                isLoading: false,
                failureMessage: metadataAsync.error.toString(),
                statusMessage: 'Failed to load map tile catalog.',
              )
            : status;

    return _StatusDotIconButton(
      isReady: effectiveStatus.isReady,
      tooltip: effectiveStatus.isReady
          ? 'Map tiles ready'
          : effectiveStatus.isLoading
              ? 'Map tiles loading'
              : 'Map tiles not ready',
      icon: Icons.layers_outlined,
      onPressed: () => _showStatusDialog(context, effectiveStatus),
    );
  }

  void _showStatusDialog(BuildContext context, PmtilesLoadStatus status) {
    showDialog<void>(
      context: context,
      builder: (context) {
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
              if (status.enabledCount > 0) ...[
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class _StatusDotIconButton extends StatelessWidget {
  const _StatusDotIconButton({
    required this.isReady,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final bool isReady;
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final indicatorColor = isReady ? Colors.green : Colors.red;

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon),
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: indicatorColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
