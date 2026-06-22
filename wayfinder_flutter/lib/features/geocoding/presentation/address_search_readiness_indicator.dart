import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      loading: () => const _ReadinessIconButton(
        isReady: false,
        tooltip: 'Checking search readiness…',
        onPressed: null,
      ),
      error: (error, stackTrace) => _ReadinessIconButton(
        isReady: false,
        tooltip: 'Search readiness unavailable',
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
      data: (readiness) => _ReadinessIconButton(
        isReady: readiness.isFullSearchReady,
        tooltip: readiness.isFullSearchReady
            ? 'Full search ready'
            : 'Full search not ready',
        onPressed: () => _showReadinessDialog(context, readiness),
      ),
    );
  }

  void _showReadinessDialog(
    BuildContext context,
    GeocodingSearchReadiness readiness,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) {
        final etaLabel = readiness.etaLabel;
        final progressPercent = readiness.buildProgress == null
            ? null
            : (readiness.buildProgress! * 100).round();

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
                if (readiness.totalIndexCount > 0) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Indexes built: ${readiness.readyIndexCount} of ${readiness.totalIndexCount}',
                  ),
                ],
                if (progressPercent != null) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: readiness.buildProgress),
                  const SizedBox(height: 4),
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class _ReadinessIconButton extends StatelessWidget {
  const _ReadinessIconButton({
    required this.isReady,
    required this.tooltip,
    required this.onPressed,
  });

  final bool isReady;
  final String tooltip;
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
          const Icon(Icons.travel_explore),
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
