import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../web/rest/rest_json.dart';
import 'geocoding_constants.dart';
import 'geocoding_housenumbers_importer.dart';
import 'geocoding_importer.dart';
import 'geocoding_settings_store.dart';

const geocodePlacesArchiveVersion = 1;
const geocodePlacesArchiveType = 'geocode_places';
const geocodeHousenumbersArchiveVersion = 1;
const geocodeHousenumbersArchiveType = 'geocode_housenumbers';

abstract final class GeocodingArchiveService {
  static const _exportBatchSize = 2000;
  static const _importBatchSize = 500;

  static void _ensureArchiveAllowed() {
    if (GeocodingImporter.isRunning) {
      throw StateError(
        'Cannot archive place data while a place-name import is running.',
      );
    }
    if (GeocodingHousenumbersImporter.isRunning) {
      throw StateError(
        'Cannot archive housenumber data while a housenumbers import is running.',
      );
    }
  }

  static Future<String> exportPlaces(Session session) async {
    _ensureArchiveAllowed();

    final buffer = StringBuffer()
      ..write('{')
      ..write('"version":$geocodePlacesArchiveVersion,')
      ..write('"type":"$geocodePlacesArchiveType",')
      ..write('"exportedAt":"${DateTime.now().toUtc().toIso8601String()}",')
      ..write('"rows":[');

    var offset = 0;
    var rowCount = 0;
    var first = true;
    while (true) {
      final batch = await GeocodePlace.db.find(
        session,
        limit: _exportBatchSize,
        offset: offset,
        orderBy: (table) => table.id,
      );
      if (batch.isEmpty) {
        break;
      }

      for (final row in batch) {
        if (!first) {
          buffer.write(',');
        }
        buffer.write(jsonEncode(_encodePlace(row)));
        first = false;
        rowCount++;
      }

      offset += batch.length;
      if (batch.length < _exportBatchSize) {
        break;
      }
    }

    buffer
      ..write('],')
      ..write('"rowCount":$rowCount')
      ..write('}');
    return buffer.toString();
  }

  static Future<String> exportHousenumbers(Session session) async {
    _ensureArchiveAllowed();

    final buffer = StringBuffer()
      ..write('{')
      ..write('"version":$geocodeHousenumbersArchiveVersion,')
      ..write('"type":"$geocodeHousenumbersArchiveType",')
      ..write('"exportedAt":"${DateTime.now().toUtc().toIso8601String()}",')
      ..write('"rows":[');

    var offset = 0;
    var rowCount = 0;
    var first = true;
    while (true) {
      final batch = await GeocodeHousenumber.db.find(
        session,
        limit: _exportBatchSize,
        offset: offset,
        orderBy: (table) => table.id,
      );
      if (batch.isEmpty) {
        break;
      }

      for (final row in batch) {
        if (!first) {
          buffer.write(',');
        }
        buffer.write(jsonEncode(_encodeHousenumber(row)));
        first = false;
        rowCount++;
      }

      offset += batch.length;
      if (batch.length < _exportBatchSize) {
        break;
      }
    }

    buffer
      ..write('],')
      ..write('"rowCount":$rowCount')
      ..write('}');
    return buffer.toString();
  }

  static Future<int> importPlaces(
    Session session,
    String archiveJson,
  ) async {
    _ensureArchiveAllowed();

    final body = _decodeArchiveObject(archiveJson);
    _validateArchive(
      body,
      expectedType: geocodePlacesArchiveType,
      expectedVersion: geocodePlacesArchiveVersion,
    );

    final rows = _parsePlaceRows(body['rows']);
    await session.db.unsafeExecute('TRUNCATE "geocode_place" RESTART IDENTITY');

    var imported = 0;
    for (var index = 0; index < rows.length; index += _importBatchSize) {
      final end = (index + _importBatchSize).clamp(0, rows.length);
      final batch = rows.sublist(index, end);
      await GeocodePlace.db.insert(session, batch);
      imported += batch.length;
    }

    await _updatePlacesSettingsAfterArchiveChange(
      session,
      importedRowCount: imported,
    );
    return imported;
  }

  static Future<int> importHousenumbers(
    Session session,
    String archiveJson,
  ) async {
    _ensureArchiveAllowed();

    final body = _decodeArchiveObject(archiveJson);
    _validateArchive(
      body,
      expectedType: geocodeHousenumbersArchiveType,
      expectedVersion: geocodeHousenumbersArchiveVersion,
    );

    final rows = _parseHousenumberRows(body['rows']);
    await session.db
        .unsafeExecute('TRUNCATE "geocode_housenumber" RESTART IDENTITY');

    var imported = 0;
    for (var index = 0; index < rows.length; index += _importBatchSize) {
      final end = (index + _importBatchSize).clamp(0, rows.length);
      final batch = rows.sublist(index, end);
      await GeocodeHousenumber.db.insert(session, batch);
      imported += batch.length;
    }

    await _updateHousenumbersSettingsAfterArchiveChange(
      session,
      importedRowCount: imported,
    );
    return imported;
  }

  static Future<int> clearPlaces(Session session) async {
    _ensureArchiveAllowed();

    final count = await GeocodePlace.db.count(session);
    await session.db.unsafeExecute('TRUNCATE "geocode_place" RESTART IDENTITY');
    await _updatePlacesSettingsAfterArchiveChange(session, importedRowCount: 0);
    return count;
  }

  static Future<int> clearHousenumbers(Session session) async {
    _ensureArchiveAllowed();

    final count = await GeocodeHousenumber.db.count(session);
    await session.db
        .unsafeExecute('TRUNCATE "geocode_housenumber" RESTART IDENTITY');
    await _updateHousenumbersSettingsAfterArchiveChange(
      session,
      importedRowCount: 0,
    );
    return count;
  }

  static Map<String, dynamic> _encodePlace(GeocodePlace row) {
    final json = RestJson.encodeModel(row);
    json.remove('id');
    return json;
  }

  static Map<String, dynamic> _encodeHousenumber(GeocodeHousenumber row) {
    final json = RestJson.encodeModel(row);
    json.remove('id');
    return json;
  }

  static Map<String, dynamic> _decodeArchiveObject(String archiveJson) {
    final trimmed = archiveJson.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Archive file is empty.');
    }

    final decoded = jsonDecode(trimmed);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Archive file must be a JSON object.');
    }
    return decoded;
  }

  static void _validateArchive(
    Map<String, dynamic> body, {
    required String expectedType,
    required int expectedVersion,
  }) {
    final version = body['version'];
    if (version is! int || version != expectedVersion) {
      throw FormatException(
        'Unsupported archive version: $version (expected $expectedVersion).',
      );
    }

    final type = body['type'];
    if (type != expectedType) {
      throw FormatException(
        'Unsupported archive type: $type (expected $expectedType).',
      );
    }
  }

  static List<GeocodePlace> _parsePlaceRows(Object? raw) {
    if (raw is! List) {
      throw const FormatException('Archive field "rows" must be a JSON array.');
    }

    return [
      for (final entry in raw)
        if (entry is Map<String, dynamic>)
          GeocodePlace(
            name: entry['name'] as String,
            displayName: entry['displayName'] as String?,
            latitude: (entry['latitude'] as num).toDouble(),
            longitude: (entry['longitude'] as num).toDouble(),
            placeRank: entry['placeRank'] as int,
            importance: (entry['importance'] as num).toDouble(),
            countryCode: entry['countryCode'] as String?,
            featureClass: entry['featureClass'] as String?,
            featureType: entry['featureType'] as String?,
          )
        else
          throw const FormatException(
            'Each place archive row must be a JSON object.',
          ),
    ];
  }

  static List<GeocodeHousenumber> _parseHousenumberRows(Object? raw) {
    if (raw is! List) {
      throw const FormatException('Archive field "rows" must be a JSON array.');
    }

    return [
      for (final entry in raw)
        if (entry is Map<String, dynamic>)
          GeocodeHousenumber(
            streetId: entry['streetId'] as String,
            street: entry['street'] as String,
            housenumber: entry['housenumber'] as String,
            latitude: (entry['latitude'] as num).toDouble(),
            longitude: (entry['longitude'] as num).toDouble(),
          )
        else
          throw const FormatException(
            'Each housenumber archive row must be a JSON object.',
          ),
    ];
  }

  static Future<void> _updatePlacesSettingsAfterArchiveChange(
    Session session, {
    required int importedRowCount,
  }) async {
    final settings = await GeocodingSettingsStore.getOrCreate(session);
    await GeocodingSettingsStore.update(
      session,
      settings.copyWith(
        importStatus: importedRowCount > 0
            ? GeocodingConstants.statusCompleted
            : GeocodingConstants.statusIdle,
        importedRowCount: importedRowCount,
        importProgress: importedRowCount > 0 ? 1 : 0,
        importError: null,
        importedAt: importedRowCount > 0 ? DateTime.now().toUtc() : null,
      ),
    );
  }

  static Future<void> _updateHousenumbersSettingsAfterArchiveChange(
    Session session, {
    required int importedRowCount,
  }) async {
    final settings = await GeocodingSettingsStore.getOrCreate(session);
    await GeocodingSettingsStore.update(
      session,
      settings.copyWith(
        housenumbersImportStatus: importedRowCount > 0
            ? GeocodingConstants.statusCompleted
            : GeocodingConstants.statusIdle,
        housenumbersImportedRowCount: importedRowCount,
        housenumbersImportProgress: importedRowCount > 0 ? 1 : 0,
        housenumbersImportError: null,
        housenumbersImportedAt:
            importedRowCount > 0 ? DateTime.now().toUtc() : null,
      ),
    );
  }
}
