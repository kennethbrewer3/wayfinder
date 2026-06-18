import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_globals.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/serverpod_client.dart';
import '../data/pmtiles_repository.dart';
import '../models/pmtiles_archive_entry.dart';
import '../models/pmtiles_file.dart';
import '../models/pmtiles_group.dart';

final pmtilesRepositoryProvider = Provider<PmtilesRepository>(
  (ref) => PmtilesRepository(
    client: ref.watch(serverClientProvider),
    webServerUrl: appServerConfig.webUrl,
  ),
);

final pmtilesRevisionProvider = StateProvider<int>((ref) => 0);

final pmtilesCatalogProvider = FutureProvider<List<PmtilesFile>>((ref) async {
  ref.watch(pmtilesRevisionProvider);
  AppLogger.logPmtiles.debug('🔄 Provider refresh: pmtilesCatalogProvider');
  final repository = ref.watch(pmtilesRepositoryProvider);
  return repository.listFiles();
});

final pmtilesGroupsProvider = FutureProvider<List<PmtilesGroup>>((ref) async {
  ref.watch(pmtilesRevisionProvider);
  AppLogger.logPmtiles.debug('🔄 Provider refresh: pmtilesGroupsProvider');
  final repository = ref.watch(pmtilesRepositoryProvider);
  return repository.listGroups();
});

/// Enabled PMTiles archives with bounds supplied by the server catalog.
final pmtilesEnabledMetadataProvider =
    FutureProvider<List<PmtilesArchiveEntry>>((ref) async {
  ref.watch(pmtilesRevisionProvider);
  final log = AppLogger.logPmtiles;
  log.debug('🔄 Provider refresh: pmtilesEnabledMetadataProvider');

  final repository = ref.watch(pmtilesRepositoryProvider);
  final entries = await repository.resolveEnabledEntries();
  if (entries.isEmpty) {
    log.warn('🗺️ No enabled PMTiles archives');
    return const [];
  }

  final withBounds = entries.where((entry) => entry.boundsKnown).length;
  log.success(
    '🗺️ PMTiles catalog entries ready',
    data: 'count=${entries.length} withBounds=$withBounds',
  );
  return entries;
});

void refreshPmtiles(WidgetRef ref) {
  final revision = ref.read(pmtilesRevisionProvider) + 1;
  AppLogger.logPmtiles.info('🔄 refreshPmtiles', data: 'revision=$revision');
  ref.read(pmtilesRevisionProvider.notifier).state = revision;
}
