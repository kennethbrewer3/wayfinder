import 'package:serverpod/serverpod.dart';

import '../core/endpoint_logging.dart';
import '../generated/protocol.dart';
import 'geocoding_archive_service.dart';
import 'geocoding_constants.dart';
import 'geocoding_housenumbers_importer.dart';
import 'geocoding_importer.dart';
import 'geocoding_search.dart';
import 'geocoding_settings_store.dart';

class GeocodingEndpoint extends Endpoint with EndpointLogging {
  static const _tag = 'geocoding';

  Future<GeocodingSettings> getSettings(Session session) {
    return loggedCall(
      session,
      _tag,
      'getSettings',
      () => GeocodingSettingsStore.getOrCreate(session),
    );
  }

  Future<GeocodingSettings> updateSourceUrl(
    Session session,
    String sourceUrl, {
    List<String>? countryCodes,
  }) {
    return loggedCall(
      session,
      _tag,
      'updateSourceUrl',
      () async {
        final trimmed = sourceUrl.trim();
        if (trimmed.isEmpty) {
          throw FormatException('Geocoding source URL is required.');
        }

        final settings = await GeocodingSettingsStore.getOrCreate(session);
        return GeocodingSettingsStore.update(
          session,
          settings.copyWith(
            sourceUrl: trimmed,
            countryCodes: _joinCountryCodes(countryCodes),
          ),
        );
      },
      onSuccess: (settings) => 'url="${settings.sourceUrl}"',
    );
  }

  Future<GeocodingSettings> startImport(
    Session session, {
    String? sourceUrl,
    List<String>? countryCodes,
  }) {
    return loggedCall(
      session,
      _tag,
      'startImport',
      () => GeocodingImporter.startImport(
        session,
        sourceUrl: sourceUrl,
        countryCodes: countryCodes,
      ),
      onSuccess: (settings) => 'status=${settings.importStatus}',
    );
  }

  Future<GeocodingSettings> startHousenumbersImport(
    Session session, {
    String? sourceUrl,
  }) {
    return loggedCall(
      session,
      _tag,
      'startHousenumbersImport',
      () => GeocodingHousenumbersImporter.startImport(
        session,
        sourceUrl: sourceUrl,
      ),
      onSuccess: (settings) =>
          'status=${settings.housenumbersImportStatus}',
    );
  }

  Future<List<GeocodeSearchResult>> searchPlaces(
    Session session,
    String query,
  ) {
    return loggedCall(
      session,
      _tag,
      'searchPlaces',
      () => GeocodingSearch.search(session, query: query),
      onSuccess: (results) => 'query="$query" count=${results.length}',
    );
  }

  Future<bool> isSearchReady(Session session) {
    return loggedCall(
      session,
      _tag,
      'isSearchReady',
      () async {
        final settings = await GeocodingSettingsStore.getOrCreate(session);
        return (settings.importStatus == GeocodingConstants.statusCompleted &&
                settings.importedRowCount > 0) ||
            (settings.housenumbersImportStatus ==
                    GeocodingConstants.statusCompleted &&
                settings.housenumbersImportedRowCount > 0);
      },
    );
  }

  Future<String> exportPlacesArchive(Session session) {
    return loggedCall(
      session,
      _tag,
      'exportPlacesArchive',
      () => GeocodingArchiveService.exportPlaces(session),
    );
  }

  Future<String> exportHousenumbersArchive(Session session) {
    return loggedCall(
      session,
      _tag,
      'exportHousenumbersArchive',
      () => GeocodingArchiveService.exportHousenumbers(session),
    );
  }

  Future<int> importPlacesArchive(Session session, String archiveJson) {
    return loggedCall(
      session,
      _tag,
      'importPlacesArchive',
      () => GeocodingArchiveService.importPlaces(session, archiveJson),
      onSuccess: (count) => 'rows=$count',
    );
  }

  Future<int> importHousenumbersArchive(Session session, String archiveJson) {
    return loggedCall(
      session,
      _tag,
      'importHousenumbersArchive',
      () => GeocodingArchiveService.importHousenumbers(session, archiveJson),
      onSuccess: (count) => 'rows=$count',
    );
  }

  Future<int> clearPlaces(Session session) {
    return loggedCall(
      session,
      _tag,
      'clearPlaces',
      () => GeocodingArchiveService.clearPlaces(session),
      onSuccess: (count) => 'removed=$count',
    );
  }

  Future<int> clearHousenumbers(Session session) {
    return loggedCall(
      session,
      _tag,
      'clearHousenumbers',
      () => GeocodingArchiveService.clearHousenumbers(session),
      onSuccess: (count) => 'removed=$count',
    );
  }
}

String? _joinCountryCodes(List<String>? countryCodes) {
  if (countryCodes == null || countryCodes.isEmpty) {
    return null;
  }
  final normalized = countryCodes
      .map((code) => code.trim().toUpperCase())
      .where((code) => code.length == 2)
      .toList()
    ..sort();
  return normalized.isEmpty ? null : normalized.join(',');
}
