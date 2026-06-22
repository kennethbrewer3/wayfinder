import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'geocoding_constants.dart';

abstract final class GeocodingSettingsStore {
  static Future<GeocodingSettings> getOrCreate(Session session) async {
    final existing = await GeocodingSettings.db.findFirstRow(session);
    if (existing != null) {
      return existing;
    }

    return GeocodingSettings.db.insertRow(
      session,
      GeocodingSettings(
        sourceUrl: GeocodingConstants.defaultSourceUrl,
        housenumbersSourceUrl: GeocodingConstants.defaultHousenumbersSourceUrl,
        importStatus: GeocodingConstants.statusIdle,
        importedRowCount: 0,
        importProgress: 0,
        housenumbersImportStatus: GeocodingConstants.statusIdle,
        housenumbersImportedRowCount: 0,
        housenumbersImportProgress: 0,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }

  static Future<GeocodingSettings> update(
    Session session,
    GeocodingSettings settings,
  ) {
    return GeocodingSettings.db.updateRow(
      session,
      settings.copyWith(updatedAt: DateTime.now().toUtc()),
    );
  }
}
