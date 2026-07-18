/// Heuristic: PMTiles filenames that look like offline elevation (DEM) packs.
///
/// Name the archive with one of these tokens (case-insensitive), e.g.
/// `virginia-terrarium.pmtiles` or `midatlantic-dem.pmtiles`. DEM packs are
/// sampled for height and are not drawn as the map basemap.
bool looksLikeElevationDemArchive(String fileName) {
  final lower = fileName.toLowerCase();
  const tokens = [
    'terrarium',
    'terrain-rgb',
    'terrain_rgb',
    'mapbox-terrain',
    '-dem.',
    '_dem.',
    '-dem-',
    '_dem_',
    'elevation',
    'srtm',
    'aster-gdem',
  ];
  for (final token in tokens) {
    if (lower.contains(token)) {
      return true;
    }
  }
  // Bare "...dem.pmtiles" / "...DEM.pmtiles"
  final base = lower.split('/').last;
  return RegExp(r'(^|[_\-\s])dem([_\-\s.]|$)').hasMatch(base);
}

/// Prefer Terrarium encoding unless the name clearly says Mapbox Terrain-RGB.
enum DemEncodingHint { terrarium, mapbox }

DemEncodingHint demEncodingHintForFileName(String fileName) {
  final lower = fileName.toLowerCase();
  if (lower.contains('terrain-rgb') ||
      lower.contains('terrain_rgb') ||
      lower.contains('mapbox-terrain') ||
      lower.contains('mapbox_terrain')) {
    return DemEncodingHint.mapbox;
  }
  return DemEncodingHint.terrarium;
}
