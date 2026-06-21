import 'package:serverpod/serverpod.dart';

import '../core/wayfinder_log.dart';
import 'geocoding_search_index_status.dart';

/// Ensures pg_trgm indexes exist for geocoding ILIKE search.
///
/// Index metadata is also declared in [Protocol.targetTableDefinitions] so
/// Serverpod's schema check accepts them across restarts. Re-apply that patch
/// after `serverpod generate` if geocoding models change.
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
  USING gin (("housenumber" || ' ' || "street") gin_trgm_ops)
''',
  ];

  static Future<void> ensureReady(Session session) async {
    final existing = await _loadExistingIndexNames(session);
    final missing = indexNames.where((name) => !existing.contains(name)).toList();
    if (missing.isEmpty) {
      WfLog.info(null, 'geocoding', '🔎 Geocoding search indexes already present');
      return;
    }

    GeocodingSearchIndexStatus.markBuildStarted();
    await session.db.unsafeExecute(
      'CREATE EXTENSION IF NOT EXISTS pg_trgm',
    );

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
