import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'geocoding_contribution_content_key.dart';

const geocodeContributionsArchiveVersion = 1;
const geocodeContributionsArchiveType = 'geocode_contributions';

abstract final class GeocodingContributionService {
  static const _exportBatchSize = 2000;
  static const _importBatchSize = 500;

  static Future<int> count(Session session) {
    return GeocodeContribution.db.count(session);
  }

  static Future<List<GeocodeContribution>> list(Session session) {
    return GeocodeContribution.db.find(
      session,
      orderBy: (table) => table.name,
    );
  }

  static Future<GeocodeContribution> create(
    Session session, {
    required String name,
    required double latitude,
    required double longitude,
    String? notes,
    String? countryCode,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const FormatException('Field "name" is required.');
    }

    final now = DateTime.now().toUtc();
    final contentKey = GeocodingContributionContentKey.compute(
      name: trimmedName,
      latitude: latitude,
      longitude: longitude,
    );

    final existing = await GeocodeContribution.db.findFirstRow(
      session,
      where: (table) => table.contentKey.equals(contentKey),
    );
    if (existing != null) {
      throw FormatException(
        'A location with the same name and coordinates already exists.',
      );
    }

    return GeocodeContribution.db.insertRow(
      session,
      GeocodeContribution(
        name: trimmedName,
        latitude: latitude,
        longitude: longitude,
        notes: _normalizeOptionalText(notes),
        countryCode: _normalizeCountryCode(countryCode),
        contentKey: contentKey,
        importedFromCrowd: false,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  static Future<GeocodeContribution> update(
    Session session, {
    required int id,
    required String name,
    required double latitude,
    required double longitude,
    String? notes,
    String? countryCode,
  }) async {
    final existing = await GeocodeContribution.db.findById(session, id);
    if (existing == null) {
      throw StateError('Contribution not found.');
    }

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const FormatException('Field "name" is required.');
    }

    final contentKey = GeocodingContributionContentKey.compute(
      name: trimmedName,
      latitude: latitude,
      longitude: longitude,
    );

    if (contentKey != existing.contentKey) {
      final duplicate = await GeocodeContribution.db.findFirstRow(
        session,
        where: (table) => table.contentKey.equals(contentKey),
      );
      if (duplicate != null && duplicate.id != id) {
        throw FormatException(
          'A location with the same name and coordinates already exists.',
        );
      }
    }

    return GeocodeContribution.db.updateRow(
      session,
      existing.copyWith(
        name: trimmedName,
        latitude: latitude,
        longitude: longitude,
        notes: _normalizeOptionalText(notes),
        countryCode: _normalizeCountryCode(countryCode),
        contentKey: contentKey,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }

  static Future<bool> delete(Session session, int id) async {
    final existing = await GeocodeContribution.db.findById(session, id);
    if (existing == null) {
      return false;
    }
    await GeocodeContribution.db.deleteRow(session, existing);
    return true;
  }

  static Future<int> clearAll(Session session) async {
    final count = await GeocodeContribution.db.count(session);
    await session.db.unsafeExecute(
      'TRUNCATE "geocode_contribution" RESTART IDENTITY',
    );
    return count;
  }

  static Future<String> exportArchive(Session session) async {
    final buffer = StringBuffer()
      ..write('{')
      ..write('"version":$geocodeContributionsArchiveVersion,')
      ..write('"type":"$geocodeContributionsArchiveType",')
      ..write('"exportedAt":"${DateTime.now().toUtc().toIso8601String()}",')
      ..write('"rows":[');

    var offset = 0;
    var rowCount = 0;
    var first = true;
    while (true) {
      final batch = await GeocodeContribution.db.find(
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
        buffer.write(jsonEncode(_encodeContributionRow(row)));
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

  static Future<int> importArchive(
    Session session,
    String archiveJson, {
    bool replaceExisting = false,
  }) async {
    final body = _decodeArchiveObject(archiveJson);
    _validateArchive(body);

    if (replaceExisting) {
      await session.db.unsafeExecute(
        'TRUNCATE "geocode_contribution" RESTART IDENTITY',
      );
    }

    final rows = _parseContributionRows(body['rows']);
    return mergeContributions(session, rows);
  }

  static Future<int> mergeContributions(
    Session session,
    List<GeocodeContribution> rows, {
    bool markImportedFromCrowd = false,
  }) async {
    var imported = 0;
    for (var index = 0; index < rows.length; index += _importBatchSize) {
      final end = (index + _importBatchSize).clamp(0, rows.length);
      final batch = rows.sublist(index, end);

      for (final row in batch) {
        final existing = await GeocodeContribution.db.findFirstRow(
          session,
          where: (table) => table.contentKey.equals(row.contentKey),
        );
        if (existing != null) {
          await GeocodeContribution.db.updateRow(
            session,
            existing.copyWith(
              name: row.name,
              latitude: row.latitude,
              longitude: row.longitude,
              notes: row.notes,
              countryCode: row.countryCode,
              importedFromCrowd:
                  markImportedFromCrowd || existing.importedFromCrowd,
              updatedAt: DateTime.now().toUtc(),
            ),
          );
        } else {
          await GeocodeContribution.db.insertRow(session, row);
        }
        imported++;
      }
    }
    return imported;
  }

  static Future<List<GeocodeContribution>> listForAnonymousExport(
    Session session, {
    bool onlyLocal = true,
  }) async {
    if (!onlyLocal) {
      return list(session);
    }
    return GeocodeContribution.db.find(
      session,
      where: (table) => table.importedFromCrowd.equals(false),
      orderBy: (table) => table.name,
    );
  }

  static Map<String, Object?> encodeContributionJson(GeocodeContribution row) {
    return {
      'id': row.id,
      'name': row.name,
      'latitude': row.latitude,
      'longitude': row.longitude,
      'notes': row.notes,
      'countryCode': row.countryCode,
      'contentKey': row.contentKey,
      'importedFromCrowd': row.importedFromCrowd,
      'createdAt': row.createdAt.toIso8601String(),
      'updatedAt': row.updatedAt.toIso8601String(),
    };
  }

  static Map<String, dynamic> _encodeContributionRow(GeocodeContribution row) {
    return {
      'name': row.name,
      'latitude': row.latitude,
      'longitude': row.longitude,
      'notes': row.notes,
      'countryCode': row.countryCode,
      'contentKey': row.contentKey,
      'importedFromCrowd': row.importedFromCrowd,
    };
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

  static void _validateArchive(Map<String, dynamic> body) {
    final version = body['version'];
    if (version is! int || version != geocodeContributionsArchiveVersion) {
      throw FormatException(
        'Unsupported archive version: $version (expected $geocodeContributionsArchiveVersion).',
      );
    }

    final type = body['type'];
    if (type != geocodeContributionsArchiveType) {
      throw FormatException(
        'Unsupported archive type: $type (expected $geocodeContributionsArchiveType).',
      );
    }
  }

  static List<GeocodeContribution> _parseContributionRows(Object? raw) {
    if (raw is! List) {
      throw const FormatException('Archive field "rows" must be a JSON array.');
    }

    final now = DateTime.now().toUtc();
    return [
      for (final entry in raw)
        if (entry is Map<String, dynamic>)
          _parseContributionRow(entry, now: now)
        else
          throw const FormatException(
            'Each contribution archive row must be a JSON object.',
          ),
    ];
  }

  static GeocodeContribution _parseContributionRow(
    Map<String, dynamic> entry, {
    required DateTime now,
  }) {
    final name = (entry['name'] as String?)?.trim() ?? '';
    if (name.isEmpty) {
      throw const FormatException('Each contribution row requires a "name".');
    }

    final latitude = (entry['latitude'] as num?)?.toDouble();
    final longitude = (entry['longitude'] as num?)?.toDouble();
    if (latitude == null || longitude == null) {
      throw const FormatException(
        'Each contribution row requires "latitude" and "longitude".',
      );
    }

    final contentKey =
        (entry['contentKey'] as String?)?.trim() ??
        GeocodingContributionContentKey.compute(
          name: name,
          latitude: latitude,
          longitude: longitude,
        );

    return GeocodeContribution(
      name: name,
      latitude: latitude,
      longitude: longitude,
      notes: _normalizeOptionalText(entry['notes'] as String?),
      countryCode: _normalizeCountryCode(entry['countryCode'] as String?),
      contentKey: contentKey,
      importedFromCrowd: entry['importedFromCrowd'] as bool? ?? false,
      createdAt: now,
      updatedAt: now,
    );
  }

  static String? _normalizeOptionalText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  static String? _normalizeCountryCode(String? value) {
    final trimmed = value?.trim().toUpperCase();
    if (trimmed == null || trimmed.length != 2) {
      return null;
    }
    return trimmed;
  }
}
