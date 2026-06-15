import 'pmtiles_file_store_io.dart'
    if (dart.library.html) 'pmtiles_file_store_web.dart' as platform;

import '../../../core/logging/app_logger.dart';
import 'pmtiles_file_store.dart';

PmtilesFileStore createPmtilesFileStore() {
  AppLogger.logStorage.debug('🏭 Resolving platform PMTiles file store');
  return platform.createPlatformPmtilesFileStore();
}
