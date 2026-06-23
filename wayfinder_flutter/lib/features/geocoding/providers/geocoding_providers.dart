import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../search/providers/search_query_provider.dart';
import '../data/geocoding_repository.dart';
import '../models/geocoding_models.dart';
import 'geocoding_server_provider.dart';

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
}
