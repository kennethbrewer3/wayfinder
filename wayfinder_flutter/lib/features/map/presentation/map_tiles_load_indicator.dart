import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/presentation/animated_status_dot_icon_button.dart';
import '../models/pmtiles_load_status.dart';
import '../providers/pmtiles_load_status_provider.dart';

/// Centered map-area overlay while PMTiles layers are opening / preparing.
///
/// Mounted inside the map canvas so status [setState]s rebuild it immediately.
class MapTilesLoadingOverlay extends ConsumerWidget {
  const MapTilesLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final status = ref.watch(pmtilesLoadStatusProvider);
    if (!status.isLoading) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final fileName = status.loadingLayerName?.trim();
    final hasFile = fileName != null && fileName.isNotEmpty;
    final detail = status.statusMessage?.trim();
    final failure = status.failureMessage?.trim();

    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Material(
            elevation: 3,
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surface.withValues(alpha: 0.94),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.mapTilesLoadingTitle,
                      style: theme.textTheme.titleSmall,
                      textAlign: TextAlign.center,
                    ),
                    if (hasFile) ...[
                      const SizedBox(height: 10),
                      Text(
                        fileName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (detail != null && detail.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        detail,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (failure != null && failure.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        failure,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 12),
                    ActivityProgressBar(
                      progress: _loadProgress(status),
                      label: _loadProgressLabel(status, l10n),
                    ),
                    if (hasFile) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.mapTilesLargeArchiveHelp,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double? _loadProgress(PmtilesLoadStatus status) {
    if (status.enabledCount <= 0) {
      return null;
    }
    // Archive open has no byte progress — show an indeterminate bar until at
    // least one archive is cached (0% looked like a hang).
    if (status.loadedCount <= 0) {
      return null;
    }
    if (status.loadingLayerName != null &&
        status.loadedCount >= status.enabledCount) {
      return null;
    }
    return status.loadedCount / status.enabledCount;
  }

  String _loadProgressLabel(PmtilesLoadStatus status, AppLocalizations l10n) {
    final fileName = status.loadingLayerName?.trim();
    if (fileName != null && fileName.isNotEmpty && status.loadedCount <= 0) {
      return l10n.mapTilesOpeningProgress(fileName);
    }
    if (status.enabledCount > 0) {
      return l10n.mapTilesLayersPrepared(
        status.loadedCount,
        status.enabledCount,
      );
    }
    return status.statusMessage?.trim().isNotEmpty == true
        ? status.statusMessage!.trim()
        : l10n.mapTilesCatalogLoading;
  }
}
