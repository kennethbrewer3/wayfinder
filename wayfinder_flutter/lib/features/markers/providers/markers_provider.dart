import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/serverpod_client.dart';
import '../../offline_packs/providers/offline_snapshot_provider.dart';
import '../../offline_packs/providers/server_reachability_provider.dart';

final markersProvider = FutureProvider<List<MapMarker>>((ref) async {
  if (ref.watch(offlineModeActiveProvider)) {
    final snapshot = await ref.watch(offlineSnapshotProvider.future);
    final markers = snapshot?.markers ?? const <MapMarker>[];
    AppLogger.logMarkers.info(
      '📍 Markers from offline pack',
      data: 'count=${markers.length}',
    );
    return markers;
  }

  AppLogger.logMarkers.debug('📡 Fetching markers from server');
  try {
    final client = ref.watch(serverClientProvider);
    final markers = await client.mapMarker.listMarkers();
    AppLogger.logMarkers.success(
      '📡 Markers loaded',
      data: 'count=${markers.length}',
    );
    return markers;
  } catch (error, stackTrace) {
    AppLogger.logMarkers.error(
      '📡 Failed to load markers',
      error: error,
      stackTrace: stackTrace,
    );
    rethrow;
  }
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  if (ref.watch(offlineModeActiveProvider)) {
    return const [];
  }
  AppLogger.logZones.debug('📡 Fetching categories from server');
  try {
    final client = ref.watch(serverClientProvider);
    final categories = await client.category.listCategories();
    AppLogger.logZones.success(
      '📡 Categories loaded',
      data: 'count=${categories.length}',
    );
    return categories;
  } catch (error, stackTrace) {
    AppLogger.logZones.error(
      '📡 Failed to load categories',
      error: error,
      stackTrace: stackTrace,
    );
    rethrow;
  }
});
