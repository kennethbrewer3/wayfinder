import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final readinessAsync = ref.watch(geocodingSearchReadinessProvider);

    readinessAsync.whenData((readiness) {
      if (readiness.isFullSearchReady && !_notifiedReady) {
        _notifiedReady = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Full search is ready — places and addresses.'),
            ),
          );
        });
      }
    });

    return readinessAsync.when(
      loading: () => const AnimatedStatusDotIconButton(
        isReady: false,
        isLoading: true,
        tooltip: 'Checking search readiness…',
        icon: Icons.travel_explore,
      ),
      error: (error, stackTrace) => AnimatedStatusDotIconButton(
        isReady: false,
        isLoading: false,
        tooltip: 'Search readiness unavailable',
        icon: Icons.travel_explore,
        onPressed: () => _showReadinessDialog(
          context,
          const GeocodingSearchReadiness(
            isAddressSearchReady: false,
            isFullSearchReady: false,
            indexesBuilding: false,
            readyIndexCount: 0,
            totalIndexCount: 0,
            statusMessage: 'Could not reach the server to check search status.',
          ),
        ),
      ),
      data: (readiness) => AnimatedStatusDotIconButton(
        isReady: readiness.isFullSearchReady,
        isLoading: readiness.indexesBuilding,
        tooltip: readiness.isFullSearchReady
            ? 'Full search ready'
            : readiness.indexesBuilding
                ? 'Building search indexes…'
                : 'Full search not ready',
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
                    ? 'Full search ready'
                    : readiness.isAddressSearchReady
                        ? 'Address search ready'
                        : 'Search not ready yet',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isLoading && !readiness.isFullSearchReady) ...[
                    ActivityProgressBar(
                      progress: readiness.buildProgress,
                      label: readiness.totalIndexCount > 0
                          ? 'Indexes built: ${readiness.readyIndexCount} of ${readiness.totalIndexCount}'
                          : readinessAsync.isLoading
                              ? 'Checking search status…'
                              : 'Building search indexes…',
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (readiness.statusMessage != null)
                    Text(readiness.statusMessage!),
                  if (readiness.isFullSearchReady) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'You can search for places and street addresses from the map search bar.',
                    ),
                  ] else if (readiness.isAddressSearchReady) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Street address search is ready. Place-name search is still being prepared.',
                    ),
                  ] else ...[
                    if (!isLoading && readiness.totalIndexCount > 0) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Indexes built: ${readiness.readyIndexCount} of ${readiness.totalIndexCount}',
                      ),
                    ],
                    if (!isLoading && progressPercent != null) ...[
                      const SizedBox(height: 8),
                      Text('$progressPercent% complete'),
                    ],
                    if (etaLabel != null) ...[
                      const SizedBox(height: 12),
                      Text('Estimated time remaining: $etaLabel'),
                    ],
                    if (readiness.currentIndexName != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Current index: ${readiness.currentIndexName}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
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
}
