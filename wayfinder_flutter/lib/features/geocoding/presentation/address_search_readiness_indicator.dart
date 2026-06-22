import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/presentation/animated_status_dot_icon_button.dart';
import '../data/geocoding_repository.dart';
import '../models/geocoding_models.dart';

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final readinessAsync = ref.watch(geocodingSearchReadinessProvider);

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

    return readinessAsync.when(
      loading: () => AnimatedStatusDotIconButton(
        isReady: false,
        isLoading: true,
        tooltip: l10n.searchReadinessCheckingTooltip,
        icon: Icons.travel_explore,
      ),
      error: (error, stackTrace) => AnimatedStatusDotIconButton(
        isReady: false,
        isLoading: false,
        tooltip: l10n.searchReadinessUnavailableTooltip,
        icon: Icons.travel_explore,
        onPressed: () => _showReadinessDialog(
          context,
          GeocodingSearchReadiness(
            isAddressSearchReady: false,
            isFullSearchReady: false,
            indexesBuilding: false,
            readyIndexCount: 0,
            totalIndexCount: 0,
            statusMessage: l10n.searchReadinessServerUnreachable,
          ),
        ),
      ),
      data: (readiness) => AnimatedStatusDotIconButton(
        isReady: readiness.isFullSearchReady,
        isLoading: readiness.indexesBuilding,
        tooltip: readiness.isFullSearchReady
            ? l10n.searchReadinessFullReadyTooltip
            : readiness.indexesBuilding
                ? l10n.searchReadinessBuildingTooltip
                : l10n.searchReadinessNotReadyTooltip,
        icon: Icons.travel_explore,
        onPressed: () => _showReadinessDialog(context, readiness),
      ),
    );
  }

  void _showReadinessDialog(
    BuildContext context,
    GeocodingSearchReadiness initialReadiness,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Consumer(
          builder: (context, ref, _) {
            final l10n = AppLocalizations.of(context)!;
            final readinessAsync = ref.watch(geocodingSearchReadinessProvider);
            final readiness = readinessAsync.maybeWhen(
              data: (value) => value,
              orElse: () => initialReadiness,
            );
            final isLoading = readinessAsync.isLoading || readiness.indexesBuilding;
            final progressPercent = readiness.buildProgress == null
                ? null
                : (readiness.buildProgress! * 100).round();
            final etaLabel = readiness.etaLabel;

            return AlertDialog(
              title: Text(
                readiness.isFullSearchReady
                    ? l10n.searchReadinessFullReadyTitle
                    : readiness.isAddressSearchReady
                        ? l10n.searchReadinessAddressReadyTitle
                        : l10n.searchReadinessNotReadyTitle,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      Text(l10n.searchReadinessPercentComplete(progressPercent)),
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
