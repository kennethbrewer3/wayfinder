import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../data/pmtiles_loader.dart';
import '../data/pmtiles_repository.dart';
import '../models/pmtiles_file.dart';
import '../models/pmtiles_map_layer.dart';

final pmtilesRepositoryProvider = Provider<PmtilesRepository>(
  (ref) => PmtilesRepository(),
);

final pmtilesRevisionProvider = StateProvider<int>((ref) => 0);

final pmtilesCatalogProvider = FutureProvider<List<PmtilesFile>>((ref) async {
  ref.watch(pmtilesRevisionProvider);
  AppLogger.logPmtiles.debug('🔄 Provider refresh: pmtilesCatalogProvider');
  final repository = ref.watch(pmtilesRepositoryProvider);
  await repository.repairPersistence();
  return repository.listFiles();
});

final activePmtilesIdProvider = FutureProvider<String?>((ref) async {
  ref.watch(pmtilesRevisionProvider);
  AppLogger.logPmtiles.debug('🔄 Provider refresh: activePmtilesIdProvider');
  return ref.watch(pmtilesRepositoryProvider).activeFileId();
});

final activePmtilesMapLayerProvider =
    FutureProvider<PmtilesMapLayerConfig?>((ref) async {
  ref.watch(pmtilesRevisionProvider);
  final log = AppLogger.logPmtiles;
  log.debug('🔄 Provider refresh: activePmtilesMapLayerProvider');

  final repository = ref.watch(pmtilesRepositoryProvider);
  await repository.repairPersistence();
  final source = await repository.resolveActiveSource();
  if (source == null) {
    log.warn('🗺️ No map layer — active source is null');
    return null;
  }

  final layer = await buildPmtilesMapLayer(source);
  log.success('🗺️ Map layer ready', data: layer.tileType.name);
  return layer;
});

void refreshPmtiles(WidgetRef ref) {
  final revision = ref.read(pmtilesRevisionProvider) + 1;
  AppLogger.logPmtiles.info('🔄 refreshPmtiles', data: 'revision=$revision');
  ref.read(pmtilesRevisionProvider.notifier).state = revision;
}
