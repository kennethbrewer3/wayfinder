import 'dart:math' as math;
import 'dart:ui' show Size;

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../settings/models/pmtiles_archive_entry.dart';
import '../../settings/models/pmtiles_geo_bounds.dart';
import '../models/map_viewport.dart';

const _defaultMaxVisibleLayers = 1;
const _viewportPaddingFraction = 0.2;

LatLngBounds geoBoundsToLatLngBounds(PmtilesGeoBounds bounds) {
  return LatLngBounds.unsafe(
    south: bounds.south,
    west: bounds.west,
    north: bounds.north,
    east: bounds.east,
  );
}

LatLngBounds expandLatLngBounds(LatLngBounds bounds, {double fraction = 0.2}) {
  final latPadding = (bounds.north - bounds.south) * fraction;
  final lngPadding = bounds.longitudeWidth * fraction;
  return LatLngBounds.unsafe(
    south: math.max(LatLngBounds.minLatitude, bounds.south - latPadding),
    west: math.max(LatLngBounds.minLongitude, bounds.west - lngPadding),
    north: math.min(LatLngBounds.maxLatitude, bounds.north + latPadding),
    east: math.min(LatLngBounds.maxLongitude, bounds.east + lngPadding),
  );
}

LatLngBounds approximateVisibleBounds(
  MapViewport viewport, {
  Size? mapSize,
}) {
  final width = mapSize?.width ?? 256;
  final height = mapSize?.height ?? 256;
  final scale = math.pow(2, viewport.zoom);
  final latSpan = (height / 256) * 180 / scale;
  final lngSpan = (width / 256) * 360 / scale;
  return LatLngBounds.unsafe(
    south: (viewport.center.latitude - latSpan / 2).clamp(-90.0, 90.0),
    west: (viewport.center.longitude - lngSpan / 2).clamp(-180.0, 180.0),
    north: (viewport.center.latitude + latSpan / 2).clamp(-90.0, 90.0),
    east: (viewport.center.longitude + lngSpan / 2).clamp(-180.0, 180.0),
  );
}

/// Tile zoom used by [vector_map_tiles] for a fractional map zoom.
int tileZoomForViewport(double mapZoom) {
  return math.max(1, mapZoom.floor());
}

TileCoordinates latLngToTile(LatLng point, int zoom) {
  final scale = 1 << zoom;
  final latRad = point.latitude * math.pi / 180;
  final x = ((point.longitude + 180) / 360 * scale)
      .floor()
      .clamp(0, scale - 1)
      .toInt();
  final y = ((1 -
              math.log(math.tan(latRad) + 1 / math.cos(latRad)) / math.pi) /
          2 *
          scale)
      .floor()
      .clamp(0, scale - 1)
      .toInt();
  return TileCoordinates(x, y, zoom);
}

double _intersectionArea(PmtilesGeoBounds archive, LatLngBounds viewport) {
  final south = math.max(archive.south, viewport.south);
  final north = math.min(archive.north, viewport.north);
  final west = math.max(archive.west, viewport.west);
  final east = math.min(archive.east, viewport.east);
  if (south >= north || west >= east) {
    return 0;
  }
  return (north - south) * (east - west);
}

bool archiveIntersectsViewport({
  required PmtilesArchiveEntry entry,
  required LatLngBounds viewportBounds,
  required double viewportZoom,
}) {
  if (viewportZoom + 1 < entry.minZoom) {
    return false;
  }

  if (!entry.boundsKnown) {
    return true;
  }

  final archiveBounds = geoBoundsToLatLngBounds(entry.bounds);
  return archiveBounds.isOverlapping(viewportBounds);
}

/// Picks enabled archives that overlap the viewport, capped for performance.
///
/// When multiple archives overlap (common for neighboring states whose header
/// bounds are rectangles), prefers the archive whose bounds contain the map
/// center and has the smallest geographic area.
List<PmtilesArchiveEntry> selectArchivesForViewport({
  required List<PmtilesArchiveEntry> entries,
  required LatLngBounds viewportBounds,
  required LatLng viewportCenter,
  required double viewportZoom,
  int maxLayers = _defaultMaxVisibleLayers,
}) {
  if (entries.isEmpty) {
    return const [];
  }

  final paddedViewport = expandLatLngBounds(
    viewportBounds,
    fraction: _viewportPaddingFraction,
  );

  final withKnownBounds =
      entries.where((entry) => entry.boundsKnown).toList();
  final candidates = withKnownBounds.isEmpty ? entries : withKnownBounds;

  final matching = candidates
      .where(
        (entry) => archiveIntersectsViewport(
          entry: entry,
          viewportBounds: paddedViewport,
          viewportZoom: viewportZoom,
        ),
      )
      .toList();

  if (matching.isEmpty && withKnownBounds.isEmpty) {
    return entries.take(maxLayers).toList();
  }

  if (matching.isEmpty) {
    return const [];
  }

  final containingCenter = matching
      .where((entry) => entry.bounds.contains(viewportCenter))
      .toList();
  if (containingCenter.isNotEmpty) {
    containingCenter.sort(
      (a, b) => a.bounds.geographicArea.compareTo(b.bounds.geographicArea),
    );
    return containingCenter.take(maxLayers).toList();
  }

  if (matching.length <= maxLayers) {
    return matching;
  }

  matching.sort(
    (a, b) => _intersectionArea(b.bounds, paddedViewport)
        .compareTo(_intersectionArea(a.bounds, paddedViewport)),
  );
  return matching.take(maxLayers).toList();
}

/// Ranks enabled archives for the current viewport, best match first.
List<PmtilesArchiveEntry> rankArchivesForViewport({
  required List<PmtilesArchiveEntry> entries,
  required LatLngBounds viewportBounds,
  required LatLng viewportCenter,
  required double viewportZoom,
}) {
  if (entries.isEmpty) {
    return const [];
  }

  final paddedViewport = expandLatLngBounds(
    viewportBounds,
    fraction: _viewportPaddingFraction,
  );

  final withKnownBounds =
      entries.where((entry) => entry.boundsKnown).toList();
  final candidates = withKnownBounds.isEmpty ? entries : withKnownBounds;

  final matching = candidates
      .where(
        (entry) => archiveIntersectsViewport(
          entry: entry,
          viewportBounds: paddedViewport,
          viewportZoom: viewportZoom,
        ),
      )
      .toList();

  if (matching.isEmpty && withKnownBounds.isEmpty) {
    return List<PmtilesArchiveEntry>.from(entries);
  }

  if (matching.isEmpty) {
    return const [];
  }

  final containingCenter = matching
      .where((entry) => entry.bounds.contains(viewportCenter))
      .toList();
  if (containingCenter.isNotEmpty) {
    containingCenter.sort(
      (a, b) => a.bounds.geographicArea.compareTo(b.bounds.geographicArea),
    );
    final containingIds = containingCenter.map((entry) => entry.id).toSet();
    final remainder = matching
        .where((entry) => !containingIds.contains(entry.id))
        .toList()
      ..sort(
        (a, b) => _intersectionArea(b.bounds, paddedViewport)
            .compareTo(_intersectionArea(a.bounds, paddedViewport)),
      );
    return [...containingCenter, ...remainder];
  }

  matching.sort(
    (a, b) => _intersectionArea(b.bounds, paddedViewport)
        .compareTo(_intersectionArea(a.bounds, paddedViewport)),
  );
  return matching;
}
