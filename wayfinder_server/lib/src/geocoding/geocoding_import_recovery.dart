import 'package:serverpod/serverpod.dart';

import '../core/wayfinder_log.dart';
import 'geocoding_constants.dart';
import 'geocoding_housenumbers_importer.dart';
import 'geocoding_importer.dart';
import 'geocoding_import_status.dart';
import 'geocoding_settings_store.dart';
import 'geocoding_staging_store.dart';

/// Detects geocoding imports left in an active DB state after a process restart.
abstract final class GeocodingImportRecovery {
  static const _interruptedMessage =
      'Import interrupted by a server restart. Cancel and start the import again.';

  /// Marks stale active imports as failed so the UI does not show a phantom
  /// download that is no longer running in memory.
  static Future<void> recoverStaleImportsOnStartup(Session session) async {
    final settings = await GeocodingSettingsStore.getOrCreate(session);
    var updated = settings;
    var changed = false;

    if (GeocodingImportStatus.isActive(settings.importStatus) &&
        !GeocodingImporter.isRunning) {
      WfLog.warn(
        session,
        'geocoding',
        '🌍 Recovering stale place-name import '
        'status=${settings.importStatus} '
        'progress=${(settings.importProgress * 100).toStringAsFixed(1)}% '
        'rows=${settings.importedRowCount}',
      );
      await GeocodingStagingStore.discardPlacesStaging(session);
      updated = updated.copyWith(
        importStatus: GeocodingConstants.statusFailed,
        importProgress: 0,
        importError: _interruptedMessage,
      );
      changed = true;
    }

    if (GeocodingImportStatus.isActive(settings.housenumbersImportStatus) &&
        !GeocodingHousenumbersImporter.isRunning) {
      WfLog.warn(
        session,
        'geocoding',
        '🏠 Recovering stale housenumbers import '
        'status=${settings.housenumbersImportStatus} '
        'progress=${(settings.housenumbersImportProgress * 100).toStringAsFixed(1)}% '
        'rows=${settings.housenumbersImportedRowCount}',
      );
      await GeocodingStagingStore.discardHousenumbersStaging(session);
      updated = updated.copyWith(
        housenumbersImportStatus: GeocodingConstants.statusFailed,
        housenumbersImportProgress: 0,
        housenumbersImportError: _interruptedMessage,
      );
      changed = true;
    }

    if (changed) {
      await GeocodingSettingsStore.update(session, updated);
      WfLog.info(
        session,
        'geocoding',
        '♻️ Cleared stale geocoding import state — restart the import from Settings',
      );
    }
  }
}
