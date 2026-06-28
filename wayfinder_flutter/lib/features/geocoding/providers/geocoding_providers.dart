import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../search/providers/search_query_provider.dart';
import '../data/geocoding_repository.dart';
import '../models/geocoding_models.dart';
import 'geocoding_server_provider.dart';

const emptyGeocodingSearchReadiness = GeocodingSearchReadiness(
  isPlacesDataReady: false,
  isAddressDataReady: false,
  isPlacesSearchReady: false,
  isAddressSearchReady: false,
  isFullSearchReady: false,
  indexesBuilding: false,
  readyIndexCount: 0,
  totalIndexCount: 0,
);

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
    final repository = ref.read(geocodingRepositoryProvider);
    if (!repository.isConfigured) {
      return emptyGeocodingSearchReadiness;
    }
    if (!await repository.isServerReachable()) {
      return const GeocodingSearchReadiness(
        isPlacesDataReady: false,
        isAddressDataReady: false,
        isPlacesSearchReady: false,
        isAddressSearchReady: false,
        isFullSearchReady: false,
        indexesBuilding: false,
        readyIndexCount: 0,
        totalIndexCount: 0,
        statusMessage: 'Geocoding server unavailable',
      );
    }
    final readiness = await repository.getSearchReadiness();
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

final geocodingSettingsProvider =
    FutureProvider<GeocodingImportState>((ref) async {
  final repository = ref.watch(geocodingRepositoryProvider);
  if (!repository.isConfigured) {
    throw StateError('Geocoding server URL is not configured.');
  }
  return repository.getSettings();
});

final geocodingSearchProvider =
    FutureProvider.autoDispose.family<List<GeocodingPlaceResult>, String>(
  (ref, query) async {
    final repository = ref.read(geocodingRepositoryProvider);
    if (!repository.isConfigured) {
      return const [];
    }
    final reachable = await ref.watch(geocodingServerReachableProvider.future);
    if (!reachable) {
      return const [];
    }

    final trimmed = query.trim();
    if (trimmed.length < mapSearchMinGeocodingLength) {
      return const [];
    }

    return repository.searchPlaces(trimmed);
  },
);

void refreshGeocoding(WidgetRef ref) {
  ref.invalidate(geocodingSettingsProvider);
  ref.invalidate(geocodingSearchReadinessProvider);
}
