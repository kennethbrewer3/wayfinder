import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/presentation/animated_status_dot_icon_button.dart';
import '../data/geocoding_repository.dart';
import '../models/geocoding_models.dart';
import '../providers/geocoding_providers.dart';
import 'geocoding_import_progress_panel.dart';

final geocodingSearchReadinessProvider =
    AsyncNotifierProvider<GeocodingSearchReadinessNotifier, GeocodingSearchReadiness>(
  GeocodingSearchReadinessNotifier.new,
);

class GeocodingSearchReadinessNotifier
    extends AsyncNotifier<GeocodingSearchReadiness> {
  Timer? _pollTimer;

  @override
  Future<GeocodingSearchReadiness> build() async {
    ref.onDispose(() => _pollTimer?.cancel());
    final readiness =
        await ref.read(geocodingRepositoryProvider).getSearchReadiness();
    _schedulePolling(readiness);
    return readiness;
  }

  void _schedulePolling(GeocodingSearchReadiness readiness) {
    _pollTimer?.cancel();
    if (readiness.isFullSearchReady) {
      return;
    }

    final interval = readiness.indexesBuilding
        ? const Duration(seconds: 5)
        : const Duration(seconds: 15);
    _pollTimer = Timer(interval, () {
      ref.invalidateSelf();
    });
  }
}

class AddressSearchReadinessIndicator extends ConsumerStatefulWidget {
  const AddressSearchReadinessIndicator({super.key});

  @override
  ConsumerState<AddressSearchReadinessIndicator> createState() =>
      _AddressSearchReadinessIndicatorState();
}

class _AddressSearchReadinessIndicatorState
    extends ConsumerState<AddressSearchReadinessIndicator> {
  bool _notifiedReady = false;
  Timer? _importPollTimer;

  @override
  void dispose() {
    _importPollTimer?.cancel();
    super.dispose();
  }

  void _scheduleImportPolling({required bool isRunning}) {
    _importPollTimer?.cancel();
    if (!isRunning) {
      return;
    }
    _importPollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      refreshGeocoding(ref);
    });
  }

  String? _importTooltip(
    AppLocalizations l10n,
    GeocodingImportState? settings,
  ) {
    if (settings == null || !settings.isRunning) {
      return null;
    }

    if (settings.isPlacesRunning) {
      final phase = resolveGeocodingImportPhase(
        isRunning: true,
        status: settings.importStatus,
        progress: settings.importProgress,
      );
      return l10n.searchReadinessImportInProgressTooltip(
        geocodingImportPhaseTitle(l10n, phase, isAddresses: false),
      );
    }

    final phase = resolveGeocodingImportPhase(
      isRunning: true,
      status: settings.housenumbersImportStatus,
      progress: settings.housenumbersImportProgress,
    );
    return l10n.searchReadinessImportInProgressTooltip(
      geocodingImportPhaseTitle(l10n, phase, isAddresses: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final readinessAsync = ref.watch(geocodingSearchReadinessProvider);
    final settingsAsync = ref.watch(geocodingSettingsProvider);
    final importSettings = settingsAsync.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final importRunning = importSettings?.isRunning ?? false;

    ref.listen(geocodingSettingsProvider, (previous, next) {
      next.whenData((settings) {
        _scheduleImportPolling(isRunning: settings.isRunning);
      });
    });

    if (importRunning && _importPollTimer == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scheduleImportPolling(isRunning: true);
        }
      });
    }

    readinessAsync.whenData((readiness) {
      if (readiness.isFullSearchReady && !_notifiedReady) {
        _notifiedReady = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.searchReadinessReadySnackBar),
            ),
          );
        });
      }
    });

    final importTooltip = _importTooltip(l10n, importSettings);

    return readinessAsync.when(
      loading: () => AnimatedStatusDotIconButton(
        isReady: false,
        isLoading: true,
        tooltip: importTooltip ?? l10n.searchReadinessCheckingTooltip,
        icon: Icons.travel_explore,
        onPressed: importRunning
            ? () => _showReadinessDialog(
                  context,
                  importSettings: importSettings,
                )
            : null,
      ),
      error: (error, stackTrace) => AnimatedStatusDotIconButton(
        isReady: false,
        isLoading: false,
        tooltip: importTooltip ?? l10n.searchReadinessUnavailableTooltip,
        icon: Icons.travel_explore,
        onPressed: () => _showReadinessDialog(
          context,
          initialReadiness: GeocodingSearchReadiness(
            isAddressSearchReady: false,
            isFullSearchReady: false,
            indexesBuilding: false,
            readyIndexCount: 0,
            totalIndexCount: 0,
            statusMessage: l10n.searchReadinessServerUnreachable,
          ),
          importSettings: importSettings,
        ),
      ),
      data: (readiness) => AnimatedStatusDotIconButton(
        isReady: readiness.isFullSearchReady && !importRunning,
        isLoading: readiness.indexesBuilding || importRunning,
        tooltip: importTooltip ??
            (readiness.isFullSearchReady
                ? l10n.searchReadinessFullReadyTooltip
                : readiness.indexesBuilding
                    ? l10n.searchReadinessBuildingTooltip
                    : l10n.searchReadinessNotReadyTooltip),
        icon: Icons.travel_explore,
        onPressed: () => _showReadinessDialog(
          context,
          initialReadiness: readiness,
          importSettings: importSettings,
        ),
      ),
    );
  }

  void _showReadinessDialog(
    BuildContext context, {
    GeocodingSearchReadiness? initialReadiness,
    GeocodingImportState? importSettings,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Consumer(
          builder: (context, ref, _) {
            final l10n = AppLocalizations.of(context)!;
            final readinessAsync = ref.watch(geocodingSearchReadinessProvider);
            final settingsAsync = ref.watch(geocodingSettingsProvider);
            final settings = settingsAsync.maybeWhen(
              data: (value) => value,
              orElse: () => importSettings,
            );
            final readiness = readinessAsync.maybeWhen(
              data: (value) => value,
              orElse: () =>
                  initialReadiness ??
                  GeocodingSearchReadiness(
                    isAddressSearchReady: false,
                    isFullSearchReady: false,
                    indexesBuilding: false,
                    readyIndexCount: 0,
                    totalIndexCount: 0,
                  ),
            );
            final isLoading =
                readinessAsync.isLoading || readiness.indexesBuilding;
            final progressPercent = readiness.buildProgress == null
                ? null
                : (readiness.buildProgress! * 100).round();
            final etaLabel = readiness.etaLabel;

            final dialogTitle = settings != null && settings.isPlacesRunning
                ? l10n.searchReadinessImportPlacesDialogTitle
                : settings != null && settings.isHousenumbersRunning
                    ? l10n.searchReadinessImportAddressesDialogTitle
                    : readiness.isFullSearchReady
                        ? l10n.searchReadinessFullReadyTitle
                        : readiness.isAddressSearchReady
                            ? l10n.searchReadinessAddressReadyTitle
                            : l10n.searchReadinessNotReadyTitle;

            return AlertDialog(
              title: Text(dialogTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (settings != null && settings.isPlacesRunning)
                      GeocodingImportProgressPanel(
                        importStatus: settings.importStatus,
                        progress: settings.importProgress,
                        importedRowCount: settings.importedRowCount,
                        rowLabel: l10n.geocodingRowLabelRows,
                        isAddresses: false,
                        showTopSpacing: false,
                      )
                    else if (settings != null && settings.isHousenumbersRunning)
                      GeocodingImportProgressPanel(
                        importStatus: settings.housenumbersImportStatus,
                        progress: settings.housenumbersImportProgress,
                        importedRowCount: settings.housenumbersImportedRowCount,
                        rowLabel: l10n.geocodingRowLabelAddresses,
                        isAddresses: true,
                        showTopSpacing: false,
                      )
                    else ...[
                      if (isLoading && !readiness.isFullSearchReady) ...[
                        ActivityProgressBar(
                          progress: readiness.buildProgress,
                          label: readiness.totalIndexCount > 0
                              ? l10n.searchReadinessIndexesBuilt(
                                  readiness.readyIndexCount,
                                  readiness.totalIndexCount,
                                )
                              : readinessAsync.isLoading
                                  ? l10n.searchReadinessCheckingStatus
                                  : l10n.searchReadinessBuildingTooltip,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (readiness.statusMessage != null)
                        Text(readiness.statusMessage!),
                      if (readiness.isFullSearchReady) ...[
                        const SizedBox(height: 12),
                        Text(l10n.searchReadinessFullReadyMessage),
                      ] else if (readiness.isAddressSearchReady) ...[
                        const SizedBox(height: 12),
                        Text(l10n.searchReadinessAddressOnlyMessage),
                      ] else ...[
                        if (!isLoading && readiness.totalIndexCount > 0) ...[
                          const SizedBox(height: 12),
                          Text(
                            l10n.searchReadinessIndexesBuilt(
                              readiness.readyIndexCount,
                              readiness.totalIndexCount,
                            ),
                          ),
                        ],
                        if (!isLoading && progressPercent != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            l10n.searchReadinessPercentComplete(
                              progressPercent,
                            ),
                          ),
                        ],
                        if (etaLabel != null) ...[
                          const SizedBox(height: 12),
                          Text(l10n.searchReadinessEta(etaLabel)),
                        ],
                        if (readiness.currentIndexName != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            l10n.searchReadinessCurrentIndex(
                              readiness.currentIndexName!,
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ],
                  ],
                ),
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
}
