import 'package:serverpod/serverpod.dart';

import '../core/wayfinder_log.dart';
import 'geocoding_search_index_status.dart';

/// Ensures pg_trgm indexes exist for geocoding ILIKE search.
///
/// Index metadata is also declared in [Protocol.targetTableDefinitions] so
/// Serverpod's schema check accepts them across restarts. Expression indexes
/// must use type `expression` and match Postgres's normalized definition (see
/// `pg_get_indexdef`). Re-apply that patch in `lib/src/generated/protocol.dart`
/// after `serverpod generate` if geocoding models change. Indexes are built
/// after `pod.start()` once migrations have created the geocoding tables.
abstract final class GeocodingSearchIndexes {
  static const indexNames = [
    'geocode_place_name_trgm_idx',
    'geocode_place_display_name_trgm_idx',
    'geocode_housenumber_street_trgm_idx',
    'geocode_housenumber_housenumber_trgm_idx',
    'geocode_housenumber_label_trgm_idx',
  ];

  static const _indexes = [
    '''
CREATE INDEX IF NOT EXISTS "geocode_place_name_trgm_idx"
  ON "geocode_place" USING gin ("name" gin_trgm_ops)
''',
    '''
CREATE INDEX IF NOT EXISTS "geocode_place_display_name_trgm_idx"
  ON "geocode_place" USING gin ("displayName" gin_trgm_ops)
''',
    '''
CREATE INDEX IF NOT EXISTS "geocode_housenumber_street_trgm_idx"
  ON "geocode_housenumber" USING gin ("street" gin_trgm_ops)
''',
    '''
CREATE INDEX IF NOT EXISTS "geocode_housenumber_housenumber_trgm_idx"
  ON "geocode_housenumber" USING gin ("housenumber" gin_trgm_ops)
''',
    '''
CREATE INDEX IF NOT EXISTS "geocode_housenumber_label_trgm_idx"
  ON "geocode_housenumber"
  USING gin (((housenumber || ' '::text) || street) gin_trgm_ops)
''',
  ];

  static Future<void> ensureReady(Session session) async {
    if (!await _geocodingTablesExist(session)) {
      WfLog.info(
        null,
        'geocoding',
        '🔎 Skipping search index build until geocoding tables exist',
      );
      return;
    }

    await session.db.unsafeExecute(
      'CREATE EXTENSION IF NOT EXISTS pg_trgm',
    );

    final existing = await _loadExistingIndexNames(session);
    final invalid = <String>[];
    for (final indexName in indexNames) {
      if (!existing.contains(indexName)) {
        continue;
      }
      if (!await _indexMatchesExpected(session, indexName)) {
        invalid.add(indexName);
      }
    }

    if (invalid.isNotEmpty) {
      WfLog.warn(
        session,
        'geocoding',
        '🔎 Recreating geocoding search indexes with incompatible metadata: '
        '${invalid.join(', ')}',
      );
      for (final indexName in invalid) {
        await session.db.unsafeExecute('DROP INDEX IF EXISTS "$indexName"');
        existing.remove(indexName);
      }
    }

    final missing = indexNames.where((name) => !existing.contains(name)).toList();
    if (missing.isEmpty) {
      WfLog.info(null, 'geocoding', '🔎 Geocoding search indexes already present');
      return;
    }

    GeocodingSearchIndexStatus.markBuildStarted();

    for (var i = 0; i < _indexes.length; i++) {
      final indexName = indexNames[i];
      if (existing.contains(indexName)) {
        continue;
      }
      GeocodingSearchIndexStatus.markIndexBuildStarted(indexName);
      await session.db.unsafeExecute(_indexes[i]);
      GeocodingSearchIndexStatus.markIndexCompleted(indexName);
    }

    WfLog.info(null, 'geocoding', '🔎 Geocoding search indexes ready');
  }

  static Future<bool> _indexMatchesExpected(
    Session session,
    String indexName,
  ) async {
    final rows = await session.db.unsafeQuery(
      '''
SELECT indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname = '$indexName'
''',
    );
    if (rows.isEmpty) {
      return false;
    }

    final definition = (rows.first[0] as String).toLowerCase();
    if (!definition.contains('using gin')) {
      return false;
    }
    if (!definition.contains('gin_trgm_ops')) {
      return false;
    }

    if (indexName == 'geocode_housenumber_label_trgm_idx') {
      return definition.contains('housenumber') && definition.contains('street');
    }

    return true;
  }

  static Future<bool> _geocodingTablesExist(Session session) async {
    final rows = await session.db.unsafeQuery(
      '''
SELECT 1
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('geocode_place', 'geocode_housenumber')
LIMIT 1
''',
    );
    return rows.isNotEmpty;
  }

  static Future<Set<String>> _loadExistingIndexNames(Session session) async {
    final quotedNames = indexNames.map((name) => "'$name'").join(', ');
    final rows = await session.db.unsafeQuery(
      '''
SELECT indexname
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname IN ($quotedNames)
''',
    );

    return {
      for (final row in rows)
        if (row[0] is String) row[0] as String,
    };
  }
}
