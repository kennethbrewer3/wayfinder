import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/app_globals.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/serverpod_client.dart';
import '../data/marker_icon_repository.dart';
import '../models/marker_icon_catalog.dart';
import '../models/marker_icon_category_catalog.dart';

final markerIconRepositoryProvider = Provider<MarkerIconRepository>(
  (ref) => MarkerIconRepository(
    client: ref.watch(serverClientProvider),
    webServerUrl: appServerConfig.webUrl,
  ),
);

final markerIconRevisionProvider = StateProvider<int>((ref) => 0);

final markerIconCatalogProvider = FutureProvider<MarkerIconCatalog>((ref) async {
  ref.watch(markerIconRevisionProvider);
  try {
    final repository = ref.watch(markerIconRepositoryProvider);
    return await repository.loadCatalog();
  } catch (_) {
    return MarkerIconCatalog.defaults();
  }
});

final markerIconRemoteEntriesProvider =
    FutureProvider<List<MarkerIconCatalogEntry>>((ref) async {
  ref.watch(markerIconRevisionProvider);
  final repository = ref.watch(markerIconRepositoryProvider);
  return repository.listRemoteEntries();
});

void refreshMarkerIcons(WidgetRef ref) {
  final revision = ref.read(markerIconRevisionProvider) + 1;
  AppLogger.logMarkers.info('🔄 refreshMarkerIcons', data: 'revision=$revision');
  ref.read(markerIconRevisionProvider.notifier).state = revision;
}

final markerIconCategoryCatalogProvider =
    FutureProvider<MarkerIconCategoryCatalog>((ref) async {
  ref.watch(markerIconRevisionProvider);
  try {
    final repository = ref.watch(markerIconRepositoryProvider);
    final categories = await repository.listCategories();
    return MarkerIconCategoryCatalog(categories);
  } catch (_) {
    return MarkerIconCategoryCatalog.fallback();
  }
});
