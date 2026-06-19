import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../../geocoding/geocoding_archive_service.dart';
import '../../geocoding/geocoding_constants.dart';
import '../../geocoding/geocoding_housenumbers_importer.dart';
import '../../geocoding/geocoding_importer.dart';
import '../../geocoding/geocoding_search.dart';
import '../../geocoding/geocoding_settings_store.dart';
import 'rest_json.dart';

abstract final class GeocodingRestHandlers {
  static Future<Result> getSettings(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final settings = await GeocodingSettingsStore.getOrCreate(session);
      return RestJson.ok(_encodeSettings(settings));
    });
  }

  static Future<Result> updateSettings(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final body = await RestJson.readObject(request);
      final sourceUrl = (body['sourceUrl'] as String?)?.trim();
      if (sourceUrl == null || sourceUrl.isEmpty) {
        throw const FormatException('Field "sourceUrl" is required');
      }

      final countryCodes = _parseCountryCodes(body['countryCodes']);

      final settings = await GeocodingSettingsStore.getOrCreate(session);
      final updated = await GeocodingSettingsStore.update(
        session,
        settings.copyWith(
          sourceUrl: sourceUrl,
          countryCodes: _joinCountryCodes(countryCodes),
        ),
      );
      return RestJson.ok(_encodeSettings(updated));
    });
  }

  static Future<Result> startImport(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final body = await RestJson.readObject(request);
      final sourceUrl = (body['sourceUrl'] as String?)?.trim();
      final countryCodes = _parseCountryCodes(body['countryCodes']);
      final settings = await GeocodingImporter.startImport(
        session,
        sourceUrl: sourceUrl,
        countryCodes: countryCodes,
      );
      return RestJson.ok(_encodeSettings(settings));
    });
  }

  static Future<Result> startHousenumbersImport(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final body = await RestJson.readObject(request);
      final sourceUrl = (body['sourceUrl'] as String?)?.trim();
      final settings = await GeocodingHousenumbersImporter.startImport(
        session,
        sourceUrl: sourceUrl,
      );
      return RestJson.ok(_encodeSettings(settings));
    });
  }

  static Future<Result> search(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final query = request.url.queryParameters['q']?.trim() ?? '';
      final results = await GeocodingSearch.search(session, query: query);
      return RestJson.ok(RestJson.encodeModels(results));
    });
  }

  static Future<Result> exportPlaces(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final payload = await GeocodingArchiveService.exportPlaces(session);
      return Response.ok(
        body: Body.fromString(payload, mimeType: MimeType.json),
      );
    });
  }

  static Future<Result> exportHousenumbers(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final payload = await GeocodingArchiveService.exportHousenumbers(session);
      return Response.ok(
        body: Body.fromString(payload, mimeType: MimeType.json),
      );
    });
  }

  static Future<Result> importPlaces(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final archiveJson = await request.readAsString();
      final rowCount = await GeocodingArchiveService.importPlaces(
        session,
        archiveJson,
      );
      final settings = await GeocodingSettingsStore.getOrCreate(session);
      return RestJson.ok({
        'rowCount': rowCount,
        ..._encodeSettings(settings),
      });
    });
  }

  static Future<Result> importHousenumbers(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final archiveJson = await request.readAsString();
      final rowCount = await GeocodingArchiveService.importHousenumbers(
        session,
        archiveJson,
      );
      final settings = await GeocodingSettingsStore.getOrCreate(session);
      return RestJson.ok({
        'rowCount': rowCount,
        ..._encodeSettings(settings),
      });
    });
  }

  static Future<Result> clearPlaces(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final removed = await GeocodingArchiveService.clearPlaces(session);
      final settings = await GeocodingSettingsStore.getOrCreate(session);
      return RestJson.ok({
        'removed': removed,
        ..._encodeSettings(settings),
      });
    });
  }

  static Future<Result> clearHousenumbers(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final removed = await GeocodingArchiveService.clearHousenumbers(session);
      final settings = await GeocodingSettingsStore.getOrCreate(session);
      return RestJson.ok({
        'removed': removed,
        ..._encodeSettings(settings),
      });
    });
  }

  static Map<String, Object?> _encodeSettings(GeocodingSettings settings) {
    return {
      'sourceUrl': settings.sourceUrl,
      'countryCodes': settings.countryCodes,
      'importStatus': settings.importStatus,
      'importedRowCount': settings.importedRowCount,
      'importProgress': settings.importProgress,
      'importError': settings.importError,
      'importedAt': settings.importedAt?.toIso8601String(),
      'housenumbersSourceUrl': settings.housenumbersSourceUrl,
      'housenumbersImportStatus': settings.housenumbersImportStatus,
      'housenumbersImportedRowCount': settings.housenumbersImportedRowCount,
      'housenumbersImportProgress': settings.housenumbersImportProgress,
      'housenumbersImportError': settings.housenumbersImportError,
      'housenumbersImportedAt': settings.housenumbersImportedAt?.toIso8601String(),
      'isReady':
          (settings.importStatus == GeocodingConstants.statusCompleted &&
                  settings.importedRowCount > 0) ||
              (settings.housenumbersImportStatus ==
                      GeocodingConstants.statusCompleted &&
                  settings.housenumbersImportedRowCount > 0),
      'isPlacesReady': settings.importStatus ==
              GeocodingConstants.statusCompleted &&
          settings.importedRowCount > 0,
      'isHousenumbersReady': settings.housenumbersImportStatus ==
              GeocodingConstants.statusCompleted &&
          settings.housenumbersImportedRowCount > 0,
      'isRunning': GeocodingImporter.isRunning ||
          GeocodingHousenumbersImporter.isRunning ||
          settings.importStatus == GeocodingConstants.statusDownloading ||
          settings.importStatus == GeocodingConstants.statusImporting ||
          settings.housenumbersImportStatus ==
              GeocodingConstants.statusDownloading ||
          settings.housenumbersImportStatus ==
              GeocodingConstants.statusImporting,
      'isPlacesRunning': GeocodingImporter.isRunning ||
          settings.importStatus == GeocodingConstants.statusDownloading ||
          settings.importStatus == GeocodingConstants.statusImporting,
      'isHousenumbersRunning': GeocodingHousenumbersImporter.isRunning ||
          settings.housenumbersImportStatus ==
              GeocodingConstants.statusDownloading ||
          settings.housenumbersImportStatus ==
              GeocodingConstants.statusImporting,
    };
  }

  static List<String>? _parseCountryCodes(Object? raw) {
    if (raw == null) {
      return null;
    }
    if (raw is String) {
      if (raw.trim().isEmpty) {
        return null;
      }
      return raw.split(',');
    }
    if (raw is List) {
      return raw.whereType<String>().toList();
    }
    return null;
  }

  static String? _joinCountryCodes(List<String>? countryCodes) {
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
}
