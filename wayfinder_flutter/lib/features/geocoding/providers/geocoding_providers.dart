import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../search/providers/search_query_provider.dart';
import '../data/geocoding_repository.dart';
import '../models/geocoding_models.dart';

final geocodingSettingsProvider =
    FutureProvider<GeocodingImportState>((ref) async {
  return ref.watch(geocodingRepositoryProvider).getSettings();
});

final geocodingSearchProvider =
    FutureProvider.autoDispose.family<List<GeocodingPlaceResult>, String>(
  (ref, query) async {
    final trimmed = query.trim();
    if (trimmed.length < mapSearchMinGeocodingLength) {
      return const [];
    }

    return ref.read(geocodingRepositoryProvider).searchPlaces(trimmed);
  },
);

void refreshGeocoding(WidgetRef ref) {
  ref.invalidate(geocodingSettingsProvider);
}
