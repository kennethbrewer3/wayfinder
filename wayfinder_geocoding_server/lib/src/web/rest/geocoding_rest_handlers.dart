import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../../geocoding/geocoding_archive_service.dart';
import '../../geocoding/geocoding_constants.dart';
import '../../geocoding/geocoding_contribution_service.dart';
import '../../geocoding/geocoding_crowdsource_service.dart';
import '../../geocoding/geocoding_housenumbers_importer.dart';
import '../../geocoding/geocoding_importer.dart';
import '../../geocoding/geocoding_import_status.dart';
import '../../geocoding/geocoding_search.dart';
import '../../geocoding/geocoding_search_index_status.dart';
import '../../geocoding/geocoding_settings_store.dart';
import 'rest_json.dart';

abstract final class GeocodingRestHandlers {
  static final _contributionIdParam = PathParam<String>(#id, (value) => value);
  static Future<Result> getSettings(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final settings = await GeocodingSettingsStore.getOrCreate(session);
      return RestJson.ok(await _encodeSettings(session, settings));
    });
  }

  static Future<Result> getSearchReadiness(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final settings = await GeocodingSettingsStore.getOrCreate(session);
      final status = await GeocodingSearchIndexStatus.get(session, settings);
      return RestJson.ok(status.toJson());
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
      final crowdsourceSourceUrl =
          (body['crowdsourceSourceUrl'] as String?)?.trim();

      final settings = await GeocodingSettingsStore.getOrCreate(session);
      final updated = await GeocodingSettingsStore.update(
        session,
        settings.copyWith(
          sourceUrl: sourceUrl,
          countryCodes: _joinCountryCodes(countryCodes),
          crowdsourceSourceUrl:
              crowdsourceSourceUrl != null && crowdsourceSourceUrl.isNotEmpty
              ? crowdsourceSourceUrl
              : settings.crowdsourceSourceUrl,
        ),
      );
      return RestJson.ok(await _encodeSettings(session, updated));
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
      return RestJson.ok(await _encodeSettings(session, settings));
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
      return RestJson.ok(await _encodeSettings(session, settings));
    });
  }

  static Future<Result> cancelImport(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final settings = await GeocodingImporter.cancelImport(session);
      return RestJson.ok(await _encodeSettings(session, settings));
    });
  }

  static Future<Result> cancelHousenumbersImport(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final settings = await GeocodingHousenumbersImporter.cancelImport(session);
      return RestJson.ok(await _encodeSettings(session, settings));
    });
  }

  static Future<Result> search(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final query = request.url.queryParameters['q']?.trim() ?? '';
      final nearLatitude = _parseOptionalDouble(
        request.url.queryParameters['nearLat'],
      );
      final nearLongitude = _parseOptionalDouble(
        request.url.queryParameters['nearLon'],
      );
      final results = await GeocodingSearch.search(
        session,
        query: query,
        nearLatitude: nearLatitude,
        nearLongitude: nearLongitude,
      );
      return RestJson.ok(RestJson.encodeModels(results));
    });
  }

  static double? _parseOptionalDouble(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return double.tryParse(value.trim());
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
        ...(await _encodeSettings(session, settings)),
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
        ...(await _encodeSettings(session, settings)),
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
        ...(await _encodeSettings(session, settings)),
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
        ...(await _encodeSettings(session, settings)),
      });
    });
  }

  static Future<Result> listContributions(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final rows = await GeocodingContributionService.list(session);
      return RestJson.ok([
        for (final row in rows)
          GeocodingContributionService.encodeContributionJson(row),
      ]);
    });
  }

  static Future<Result> createContribution(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final body = await RestJson.readObject(request);
      final name = (body['name'] as String?)?.trim() ?? '';
      final latitude = _parseRequiredDouble(body['latitude'], field: 'latitude');
      final longitude =
          _parseRequiredDouble(body['longitude'], field: 'longitude');
      final row = await GeocodingContributionService.create(
        session,
        name: name,
        latitude: latitude,
        longitude: longitude,
        notes: body['notes'] as String?,
        countryCode: body['countryCode'] as String?,
      );
      return RestJson.ok(
        GeocodingContributionService.encodeContributionJson(row),
      );
    });
  }

  static Future<Result> updateContribution(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final id = _parsePathId(request);
      final body = await RestJson.readObject(request);
      final name = (body['name'] as String?)?.trim() ?? '';
      final latitude = _parseRequiredDouble(body['latitude'], field: 'latitude');
      final longitude =
          _parseRequiredDouble(body['longitude'], field: 'longitude');
      final row = await GeocodingContributionService.update(
        session,
        id: id,
        name: name,
        latitude: latitude,
        longitude: longitude,
        notes: body['notes'] as String?,
        countryCode: body['countryCode'] as String?,
      );
      return RestJson.ok(
        GeocodingContributionService.encodeContributionJson(row),
      );
    });
  }

  static Future<Result> deleteContribution(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final id = _parsePathId(request);
      final removed = await GeocodingContributionService.delete(session, id);
      if (!removed) {
        return RestJson.error(404, 'Contribution not found.');
      }
      return RestJson.ok({'removed': true});
    });
  }

  static Future<Result> exportContributions(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final payload = await GeocodingContributionService.exportArchive(session);
      return Response.ok(
        body: Body.fromString(payload, mimeType: MimeType.json),
      );
    });
  }

  static Future<Result> importContributions(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final archiveJson = await request.readAsString();
      final rowCount = await GeocodingContributionService.importArchive(
        session,
        archiveJson,
      );
      final settings = await GeocodingSettingsStore.getOrCreate(session);
      return RestJson.ok({
        'rowCount': rowCount,
        ...(await _encodeSettings(session, settings)),
      });
    });
  }

  static Future<Result> clearContributions(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final removed = await GeocodingContributionService.clearAll(session);
      final settings = await GeocodingSettingsStore.getOrCreate(session);
      return RestJson.ok({
        'removed': removed,
        ...(await _encodeSettings(session, settings)),
      });
    });
  }

  static Future<Result> importCrowdsource(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final body = await RestJson.readObject(request);
      final sourceUrl = (body['sourceUrl'] as String?)?.trim();
      final rowCount = await GeocodingCrowdsourceService.importFromUrl(
        session,
        sourceUrl: sourceUrl,
      );
      final settings = await GeocodingSettingsStore.getOrCreate(session);
      return RestJson.ok({
        'rowCount': rowCount,
        ...(await _encodeSettings(session, settings)),
      });
    });
  }

  static Future<Result> submitCrowdsource(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final result = await GeocodingCrowdsourceService.submitAnonymous(session);
      return RestJson.ok({
        'submittedCount': result.submittedCount,
        'uploadedToGit': result.uploadedToGit,
        if (result.bundleJson != null) 'bundleJson': result.bundleJson,
        if (result.message != null) 'message': result.message,
      });
    });
  }

  static int _parsePathId(Request request) {
    final raw = request.pathParameters.get(_contributionIdParam);
    final id = int.tryParse(raw);
    if (id == null) {
      throw FormatException('Invalid contribution id: $raw');
    }
    return id;
  }

  static double _parseRequiredDouble(Object? value, {required String field}) {
    if (value is num) {
      return value.toDouble();
    }
    throw FormatException('Field "$field" is required.');
  }

  static Future<Map<String, Object?>> _encodeSettings(
    Session session,
    GeocodingSettings settings,
  ) async {
    final indexStatus = await GeocodingSearchIndexStatus.get(session, settings);
    final contributionCount = await GeocodingContributionService.count(session);
    final isContributionsReady = contributionCount > 0;
    return {
      'sourceUrl': settings.sourceUrl,
      'countryCodes': settings.countryCodes,
      'crowdsourceSourceUrl': settings.crowdsourceSourceUrl,
      'contributionCount': contributionCount,
      'isContributionsReady': isContributionsReady,
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
          GeocodingImportStatus.isSearchable(
            settings.importStatus,
            settings.importedRowCount,
          ) ||
          GeocodingImportStatus.isSearchable(
            settings.housenumbersImportStatus,
            settings.housenumbersImportedRowCount,
          ) ||
          isContributionsReady,
      'isPlacesReady': GeocodingImportStatus.isSearchable(
        settings.importStatus,
        settings.importedRowCount,
      ),
      'isHousenumbersReady': GeocodingImportStatus.isSearchable(
        settings.housenumbersImportStatus,
        settings.housenumbersImportedRowCount,
      ),
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
      ...indexStatus.toJson(),
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
