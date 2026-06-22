import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'geocoding_import_status.dart';
import 'geocoding_search_indexes.dart';

/// Reports whether geocoding search indexes exist and are building.
class GeocodingSearchIndexStatus {
  GeocodingSearchIndexStatus({
    required this.isAddressSearchReady,
    required this.isFullSearchReady,
    required this.indexesBuilding,
    required this.readyIndexCount,
    required this.totalIndexCount,
    this.buildProgress,
    this.etaSeconds,
    this.currentIndexName,
    this.statusMessage,
  });

  final bool isAddressSearchReady;
  final bool isFullSearchReady;
  final bool indexesBuilding;
  final int readyIndexCount;
  final int totalIndexCount;
  final double? buildProgress;
  final int? etaSeconds;
  final String? currentIndexName;
  final String? statusMessage;

  static const _addressIndexNames = [
    'geocode_housenumber_street_trgm_idx',
    'geocode_housenumber_housenumber_trgm_idx',
    'geocode_housenumber_label_trgm_idx',
  ];

  static const _placeIndexNames = [
    'geocode_place_name_trgm_idx',
    'geocode_place_display_name_trgm_idx',
  ];

  static DateTime? _buildStartedAt;
  static DateTime? _currentIndexStartedAt;
  static final Map<String, int> _completedIndexDurationsMs = {};

  static void markBuildStarted() {
    _buildStartedAt = DateTime.now();
    _currentIndexStartedAt = _buildStartedAt;
    _completedIndexDurationsMs.clear();
  }

  static void markIndexBuildStarted(String indexName) {
    _currentIndexStartedAt = DateTime.now();
  }

  static void markIndexCompleted(String indexName) {
    final startedAt = _currentIndexStartedAt;
    if (startedAt != null) {
      _completedIndexDurationsMs[indexName] =
          DateTime.now().difference(startedAt).inMilliseconds;
    }
    _currentIndexStartedAt = DateTime.now();
  }

  static Future<GeocodingSearchIndexStatus> get(
    Session session,
    GeocodingSettings settings,
  ) async {
    final placesDataReady = GeocodingImportStatus.isSearchable(
      settings.importStatus,
      settings.importedRowCount,
    );
    final addressDataReady = GeocodingImportStatus.isSearchable(
      settings.housenumbersImportStatus,
      settings.housenumbersImportedRowCount,
    );

    final existingIndexes = await _loadExistingIndexNames(session);
    final readyAddressIndexes = _addressIndexNames
        .where(existingIndexes.contains)
        .length;
    final readyPlaceIndexes =
        _placeIndexNames.where(existingIndexes.contains).length;
    final readyIndexCount = readyAddressIndexes + readyPlaceIndexes;
    final totalIndexCount = GeocodingSearchIndexes.indexNames.length;

    final progress = await _loadBuildProgress(session);
    final indexesBuilding = progress != null;

    final isAddressSearchReady =
        addressDataReady && readyAddressIndexes == _addressIndexNames.length;
    final isFullSearchReady = placesDataReady &&
        isAddressSearchReady &&
        readyPlaceIndexes == _placeIndexNames.length;

    double? buildProgress;
    int? etaSeconds;
    String? currentIndexName;
    String? statusMessage;

    if (!addressDataReady && !placesDataReady) {
      statusMessage = 'Geocoding data has not been imported yet.';
    } else if (isFullSearchReady) {
      statusMessage = 'Place and address search are ready.';
    } else if (isAddressSearchReady && !placesDataReady) {
      statusMessage = 'Address search is ready. Place data is not imported.';
    } else if (indexesBuilding) {
      final activeProgress = progress;
      currentIndexName = activeProgress.indexName;
      if (activeProgress.blocksTotal > 0) {
        buildProgress =
            (readyIndexCount + activeProgress.fraction) / totalIndexCount;
        etaSeconds = _estimateEtaSeconds(
          progress: activeProgress,
          readyIndexCount: readyIndexCount,
          totalIndexCount: totalIndexCount,
        );
      } else {
        buildProgress = readyIndexCount / totalIndexCount;
      }
      statusMessage = 'Building search indexes ($currentIndexName)…';
    } else if (addressDataReady || placesDataReady) {
      buildProgress = readyIndexCount / totalIndexCount;
      statusMessage = readyIndexCount == 0
          ? 'Search indexes have not been built yet. Restart the server or wait for indexing to begin.'
          : 'Search indexes are partially built ($readyIndexCount of $totalIndexCount).';
      etaSeconds = _estimateRemainingIndexEta(
        readyIndexCount: readyIndexCount,
        totalIndexCount: totalIndexCount,
      );
    }

    return GeocodingSearchIndexStatus(
      isAddressSearchReady: isAddressSearchReady,
      isFullSearchReady: isFullSearchReady,
      indexesBuilding: indexesBuilding,
      readyIndexCount: readyIndexCount,
      totalIndexCount: totalIndexCount,
      buildProgress: buildProgress,
      etaSeconds: etaSeconds,
      currentIndexName: currentIndexName,
      statusMessage: statusMessage,
    );
  }

  static Future<Set<String>> _loadExistingIndexNames(Session session) async {
    final quotedNames = GeocodingSearchIndexes.indexNames
        .map((name) => "'$name'")
        .join(', ');
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

  static Future<_IndexBuildProgress?> _loadBuildProgress(
    Session session,
  ) async {
    final rows = await session.db.unsafeQuery(
      '''
SELECT
  c.relname AS index_name,
  p.blocks_done,
  p.blocks_total
FROM pg_stat_progress_create_index p
JOIN pg_class c ON c.oid = p.index_relid
WHERE p.relid::regclass::text IN ('geocode_place', 'geocode_housenumber')
LIMIT 1
''',
    );
    if (rows.isEmpty) {
      return null;
    }

    final row = rows.first;
    final indexName = row[0] as String?;
    final blocksDone = (row[1] as num?)?.toInt() ?? 0;
    final blocksTotal = (row[2] as num?)?.toInt() ?? 0;
    if (indexName == null) {
      return null;
    }

    return _IndexBuildProgress(
      indexName: indexName,
      blocksDone: blocksDone,
      blocksTotal: blocksTotal,
    );
  }

  static int? _estimateEtaSeconds({
    required _IndexBuildProgress progress,
    required int readyIndexCount,
    required int totalIndexCount,
  }) {
    final startedAt = _currentIndexStartedAt ?? _buildStartedAt;
    if (progress.blocksTotal <= 0 || progress.blocksDone <= 0) {
      return _estimateRemainingIndexEta(
        readyIndexCount: readyIndexCount,
        totalIndexCount: totalIndexCount,
      );
    }

    final elapsedSeconds = startedAt == null
        ? 0
        : DateTime.now().difference(startedAt).inSeconds;
    if (elapsedSeconds <= 0) {
      return _estimateRemainingIndexEta(
        readyIndexCount: readyIndexCount,
        totalIndexCount: totalIndexCount,
      );
    }

    final blocksRemaining = progress.blocksTotal - progress.blocksDone;
    final secondsPerBlock = elapsedSeconds / progress.blocksDone;
    final currentIndexEta = (blocksRemaining * secondsPerBlock).round();
    final remainingIndexes = totalIndexCount - readyIndexCount - 1;
    final averageIndexSeconds = _averageCompletedIndexSeconds();
    return currentIndexEta + (remainingIndexes * averageIndexSeconds);
  }

  static int? _estimateRemainingIndexEta({
    required int readyIndexCount,
    required int totalIndexCount,
  }) {
    final remaining = totalIndexCount - readyIndexCount;
    if (remaining <= 0) {
      return null;
    }
    final averageIndexSeconds = _averageCompletedIndexSeconds();
    return remaining * averageIndexSeconds;
  }

  static int _averageCompletedIndexSeconds() {
    if (_completedIndexDurationsMs.isEmpty) {
      return 600;
    }
    final totalMs =
        _completedIndexDurationsMs.values.fold<int>(0, (sum, value) => sum + value);
    return (totalMs / _completedIndexDurationsMs.length / 1000).round().clamp(30, 3600);
  }

  Map<String, Object?> toJson() {
    return {
      'isAddressSearchReady': isAddressSearchReady,
      'isFullSearchReady': isFullSearchReady,
      'indexesBuilding': indexesBuilding,
      'readyIndexCount': readyIndexCount,
      'totalIndexCount': totalIndexCount,
      if (buildProgress != null) 'buildProgress': buildProgress,
      if (etaSeconds != null) 'etaSeconds': etaSeconds,
      if (currentIndexName != null) 'currentIndexName': currentIndexName,
      if (statusMessage != null) 'statusMessage': statusMessage,
    };
  }
}

class _IndexBuildProgress {
  const _IndexBuildProgress({
    required this.indexName,
    required this.blocksDone,
    required this.blocksTotal,
  });

  final String indexName;
  final int blocksDone;
  final int blocksTotal;

  double get fraction {
    if (blocksTotal <= 0) {
      return 0;
    }
    return blocksDone / blocksTotal;
  }
}
