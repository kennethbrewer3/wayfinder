import 'dart:typed_data';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:pmtiles/pmtiles.dart';
import 'package:vector_tile/vector_tile.dart';

import '../../../core/logging/app_logger.dart';
import '../../settings/data/pmtiles_loader.dart';
import '../../settings/models/pmtiles_archive_entry.dart';
import 'pmtiles_viewport.dart';

/// How well an archive covers the viewport center at the current zoom.
class ArchiveCenterTileScore {
  const ArchiveCenterTileScore({
    required this.entry,
    required this.tileFound,
    required this.tileZoom,
    required this.featureCount,
    required this.mapFeatureCount,
  });

  final PmtilesArchiveEntry entry;
  final bool tileFound;
  final int tileZoom;
  final int featureCount;
  final int mapFeatureCount;

  bool get hasMapContent => mapFeatureCount > 0;

  static ArchiveCenterTileScore none(PmtilesArchiveEntry entry) {
    return ArchiveCenterTileScore(
      entry: entry,
      tileFound: false,
      tileZoom: 0,
      featureCount: 0,
      mapFeatureCount: 0,
    );
  }

  String get debugLabel =>
      '${entry.name}: map=$mapFeatureCount total=$featureCount'
      '${tileFound ? ' z$tileZoom' : ' (missing)'}';
}

/// Layers that do not indicate land cover for the target state archive.
final _incidentalLayerPattern = RegExp(
  r'^(water|ocean|marine|sea|background|earth|placeholder|boundaries)$',
  caseSensitive: false,
);

/// Counts vector features in a tile, ignoring water/background-only layers.
ArchiveCenterTileScore scoreVectorTileBytes({
  required PmtilesArchiveEntry entry,
  required int tileZoom,
  required List<int> bytes,
}) {
  if (bytes.isEmpty) {
    return ArchiveCenterTileScore.none(entry);
  }

  try {
    final vectorTile = VectorTile.fromBytes(bytes: Uint8List.fromList(bytes));
    var featureCount = 0;
    var mapFeatureCount = 0;
    for (final layer in vectorTile.layers) {
      final layerFeatures = layer.features.length;
      featureCount += layerFeatures;
      if (!_incidentalLayerPattern.hasMatch(layer.name)) {
        mapFeatureCount += layerFeatures;
      }
    }
    return ArchiveCenterTileScore(
      entry: entry,
      tileFound: true,
      tileZoom: tileZoom,
      featureCount: featureCount,
      mapFeatureCount: mapFeatureCount,
    );
  } catch (_) {
    return ArchiveCenterTileScore.none(entry);
  }
}

Future<ArchiveCenterTileScore> scoreArchiveAtCenter({
  required PmtilesArchiveEntry entry,
  required LatLng center,
  required double viewportZoom,
}) async {
  final displayZoom = tileZoomForViewport(viewportZoom)
      .clamp(entry.minZoom, entry.maxZoom);
  final zoomsToTry = <int>[
    displayZoom,
    if (displayZoom > entry.minZoom) displayZoom - 1,
  ];

  final archive = await openPmtilesArchive(entry.source);
  try {
    ArchiveCenterTileScore? best;
    for (final zoom in zoomsToTry) {
      final coords = latLngToTile(center, zoom);
      final tileId = ZXY(coords.z, coords.x, coords.y).toTileId();
      final tile = await archive.tile(tileId);
      try {
        final bytes = tile.bytes();
        final score = scoreVectorTileBytes(
          entry: entry,
          tileZoom: zoom,
          bytes: bytes,
        );
        if (best == null ||
            score.mapFeatureCount > best.mapFeatureCount ||
            (score.mapFeatureCount == best.mapFeatureCount &&
                score.featureCount > best.featureCount)) {
          best = score;
        }
        if (score.hasMapContent) {
          return score;
        }
      } catch (_) {
        continue;
      }
    }
    return best ?? ArchiveCenterTileScore.none(entry);
  } finally {
    await archive.close();
  }
}

/// Prefers archives probed at higher zoom (more detail), then richer tiles.
int compareArchiveCenterTileScores(
  ArchiveCenterTileScore a,
  ArchiveCenterTileScore b,
) {
  final probeZoom = b.tileZoom.compareTo(a.tileZoom);
  if (probeZoom != 0) {
    return probeZoom;
  }
  final mapFeatures = b.mapFeatureCount.compareTo(a.mapFeatureCount);
  if (mapFeatures != 0) {
    return mapFeatures;
  }
  return b.featureCount.compareTo(a.featureCount);
}

ArchiveCenterTileScore? _pickBestScoredArchive(
  List<ArchiveCenterTileScore> scores,
) {
  if (scores.isEmpty) {
    return null;
  }

  final withMapContent = scores.where((score) => score.hasMapContent).toList()
    ..sort(compareArchiveCenterTileScores);
  if (withMapContent.isNotEmpty) {
    return withMapContent.first;
  }

  final withAnyTile = scores.where((score) => score.tileFound).toList()
    ..sort(compareArchiveCenterTileScores);
  if (withAnyTile.isNotEmpty) {
    return withAnyTile.first;
  }

  return null;
}

/// Result of choosing an archive for the current viewport.
class ArchiveSelectionResult {
  const ArchiveSelectionResult({
    required this.entry,
    required this.scores,
    required this.reason,
  });

  final PmtilesArchiveEntry? entry;
  final List<ArchiveCenterTileScore> scores;
  final String reason;

  String get debugSummary {
    if (scores.isEmpty) {
      return reason;
    }
    final lines = scores.map((score) => score.debugLabel).join('\n');
    return '$reason\n$lines';
  }
}

/// Chooses the archive whose center tile has the richest map content.
///
/// Selection steps:
/// 1. Consider enabled archives whose header bounds contain the map center.
/// 2. If none, fall back to archives overlapping the viewport.
/// 3. Open each candidate and read the center vector tile at the display zoom.
/// 4. Count map features (excluding water/background layers).
/// 5. Pick the archive with the highest map feature count.
Future<ArchiveSelectionResult> resolveActiveArchiveForViewport({
  required List<PmtilesArchiveEntry> entries,
  required LatLngBounds viewportBounds,
  required LatLng viewportCenter,
  required double viewportZoom,
}) async {
  if (entries.isEmpty) {
    return const ArchiveSelectionResult(
      entry: null,
      scores: [],
      reason: 'no enabled archives',
    );
  }

  final paddedViewport = expandLatLngBounds(viewportBounds);

  final containingCenter = rankArchivesContainingCenter(
    entries: entries,
    paddedViewport: paddedViewport,
    viewportCenter: viewportCenter,
    viewportZoom: viewportZoom,
  );

  final candidates = containingCenter.isNotEmpty
      ? containingCenter
      : selectArchivesForViewport(
          entries: entries,
          viewportBounds: viewportBounds,
          viewportCenter: viewportCenter,
          viewportZoom: viewportZoom,
          maxLayers: entries.length,
        );

  if (candidates.isEmpty) {
    return const ArchiveSelectionResult(
      entry: null,
      scores: [],
      reason: 'no archive overlaps viewport',
    );
  }

  final scores = await Future.wait(
    candidates.map(
      (entry) => scoreArchiveAtCenter(
        entry: entry,
        center: viewportCenter,
        viewportZoom: viewportZoom,
      ),
    ),
  );

  final best = _pickBestScoredArchive(scores);
  if (best != null) {
    AppLogger.logPmtiles.info(
      '🗺️ Selected archive by center tile score',
      data:
          'id=${best.entry.id} name="${best.entry.name}" mapFeatures=${best.mapFeatureCount} totalFeatures=${best.featureCount} zoom=${best.tileZoom}',
    );
    return ArchiveSelectionResult(
      entry: best.entry,
      scores: scores,
      reason: best.hasMapContent
          ? 'picked highest zoom detail at center'
          : 'picked best available center tile',
    );
  }

  AppLogger.logPmtiles.warn(
    '🗺️ No archive had usable center tile data; using bounds ranking',
    data:
        'center=${viewportCenter.latitude},${viewportCenter.longitude} candidates=${candidates.map((e) => e.name).join(', ')}',
  );
  return ArchiveSelectionResult(
    entry: candidates.first,
    scores: scores,
    reason: 'fallback to bounds ranking (no center tile data)',
  );
}
