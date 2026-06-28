import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/presentation/animated_status_dot_icon_button.dart';
import '../data/geocoding_repository.dart';
import '../models/geocoding_models.dart';
import '../providers/geocoding_providers.dart';
import 'geocoding_import_progress_panel.dart';

String searchReadinessDialogTitle(
  AppLocalizations l10n,
  GeocodingSearchReadiness readiness,
) {
  if (readiness.isFullSearchReady) {
    return l10n.searchReadinessFullReadyTitle;
  }
  if (readiness.isPlacesSearchReady && readiness.isAddressSearchReady) {
    return l10n.searchReadinessFullReadyTitle;
  }
  if (readiness.isPlacesSearchReady) {
    return l10n.searchReadinessPlacesReadyTitle;
  }
  if (readiness.isAddressSearchReady) {
    return l10n.searchReadinessAddressReadyTitle;
  }
  if (readiness.indexesReady &&
      (!readiness.isPlacesDataReady || !readiness.isAddressDataReady)) {
    return l10n.searchReadinessWaitingForDataTitle;
  }
  if (readiness.indexesBuilding) {
    return l10n.searchReadinessBuildingTooltip;
  }
  return l10n.searchReadinessNotReadyTitle;
}

String searchReadinessTooltip(
  AppLocalizations l10n,
  GeocodingSearchReadiness readiness,
) {
  if (readiness.isFullSearchReady) {
    return l10n.searchReadinessFullReadyTooltip;
  }
  if (readiness.isPlacesSearchReady && readiness.isAddressSearchReady) {
    return l10n.searchReadinessFullReadyTooltip;
  }
  if (readiness.isPlacesSearchReady || readiness.isAddressSearchReady) {
    return readiness.isPlacesSearchReady
        ? l10n.searchReadinessPlacesOnlyTooltip
        : l10n.searchReadinessAddressReadyTitle;
  }
  if (readiness.indexesBuilding) {
    return l10n.searchReadinessBuildingTooltip;
  }
  if (readiness.indexesReady) {
    return l10n.searchReadinessWaitingForDataTitle;
  }
  return l10n.searchReadinessNotReadyTooltip;
}

String? searchReadinessSummaryMessage(
  AppLocalizations l10n,
  GeocodingSearchReadiness readiness,
) {
  if (readiness.isFullSearchReady) {
    return l10n.searchReadinessFullReadyMessage;
  }
  if (readiness.isPlacesSearchReady && !readiness.isAddressSearchReady) {
    return l10n.searchReadinessPlacesOnlyMessage;
  }
  if (readiness.isAddressSearchReady && !readiness.isPlacesSearchReady) {
    return l10n.searchReadinessAddressOnlyMessage;
  }
  if (readiness.indexesReady &&
      (!readiness.isPlacesDataReady || !readiness.isAddressDataReady)) {
    return l10n.searchReadinessWaitingForDataMessage;
  }
  return readiness.statusMessage;
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
    final repository = ref.watch(geocodingRepositoryProvider);
    if (!repository.isConfigured) {
      return AnimatedStatusDotIconButton(
        isReady: false,
        isLoading: false,
        tooltip: l10n.searchReadinessGeocodingNotConfiguredTooltip,
        icon: Icons.travel_explore,
        onPressed: () => _showReadinessDialog(
          context,
          initialReadiness: emptyGeocodingSearchReadiness,
        ),
      );
    }

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
            isPlacesDataReady: false,
            isAddressDataReady: false,
            isPlacesSearchReady: false,
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
        isReady: readiness.anySearchReady && !importRunning,
        isLoading: readiness.indexesBuilding || importRunning,
        tooltip: importTooltip ?? searchReadinessTooltip(l10n, readiness),
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
            final repository = ref.watch(geocodingRepositoryProvider);
            if (!repository.isConfigured) {
              return AlertDialog(
                title: Text(l10n.searchReadinessNotReadyTitle),
                content: Text(l10n.geocodingServerNotConfiguredMessage),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.actionClose),
                  ),
                ],
              );
            }

            final readinessAsync = ref.watch(geocodingSearchReadinessProvider);
            final settingsAsync = ref.watch(geocodingSettingsProvider);
            final settings = settingsAsync.maybeWhen(
              data: (value) => value,
              orElse: () => importSettings,
            );
            final readiness = readinessAsync.maybeWhen(
              data: (value) => value,
              orElse: () => initialReadiness ?? emptyGeocodingSearchReadiness,
            );
            final showIndexProgress = readiness.indexesBuilding ||
                (!readiness.indexesReady && readiness.totalIndexCount > 0);
            final progressPercent = readiness.buildProgress == null
                ? null
                : (readiness.buildProgress! * 100).round();
            final etaLabel = readiness.etaLabel;
            final summaryMessage =
                searchReadinessSummaryMessage(l10n, readiness);

            final dialogTitle = settings != null && settings.isPlacesRunning
                ? l10n.searchReadinessImportPlacesDialogTitle
                : settings != null && settings.isHousenumbersRunning
                    ? l10n.searchReadinessImportAddressesDialogTitle
                    : searchReadinessDialogTitle(l10n, readiness);

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
                      if (showIndexProgress) ...[
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
                      _SearchReadinessChecklist(readiness: readiness),
                      if (summaryMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(summaryMessage),
                      ],
                      if (showIndexProgress && progressPercent != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          l10n.searchReadinessPercentComplete(progressPercent),
                        ),
                      ],
                      if (showIndexProgress && etaLabel != null) ...[
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

class _SearchReadinessChecklist extends StatelessWidget {
  const _SearchReadinessChecklist({required this.readiness});

  final GeocodingSearchReadiness readiness;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.searchReadinessRequirementsTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        _SearchReadinessRequirementRow(
          label: l10n.searchReadinessRequirementPlacesData,
          isReady: readiness.isPlacesDataReady,
          readyLabel: l10n.searchReadinessRequirementReady,
          missingLabel: l10n.searchReadinessRequirementMissing,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 4),
        _SearchReadinessRequirementRow(
          label: l10n.searchReadinessRequirementAddressData,
          isReady: readiness.isAddressDataReady,
          readyLabel: l10n.searchReadinessRequirementReady,
          missingLabel: l10n.searchReadinessRequirementMissing,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 4),
        _SearchReadinessRequirementRow(
          label: l10n.searchReadinessRequirementIndexes,
          isReady: readiness.indexesReady,
          readyLabel: readiness.totalIndexCount > 0
              ? l10n.searchReadinessIndexesBuilt(
                  readiness.readyIndexCount,
                  readiness.totalIndexCount,
                )
              : l10n.searchReadinessRequirementReady,
          missingLabel: readiness.totalIndexCount > 0
              ? l10n.searchReadinessIndexesBuilt(
                  readiness.readyIndexCount,
                  readiness.totalIndexCount,
                )
              : l10n.searchReadinessRequirementMissing,
          colorScheme: colorScheme,
        ),
      ],
    );
  }
}

class _SearchReadinessRequirementRow extends StatelessWidget {
  const _SearchReadinessRequirementRow({
    required this.label,
    required this.isReady,
    required this.readyLabel,
    required this.missingLabel,
    required this.colorScheme,
  });

  final String label;
  final bool isReady;
  final String readyLabel;
  final String missingLabel;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isReady ? Icons.check_circle_outline : Icons.radio_button_unchecked,
          size: 18,
          color: isReady ? colorScheme.primary : colorScheme.outline,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              Text(
                isReady ? readyLabel : missingLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isReady
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
