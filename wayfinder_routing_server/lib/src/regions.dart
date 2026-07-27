/// Preset Geofabrik extract regions for one-click OSM import.
class RoutingRegion {
  const RoutingRegion({
    required this.id,
    required this.name,
    this.sourceUrl,
    this.description,
  });

  final String id;
  final String name;
  final String? sourceUrl;
  final String? description;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (sourceUrl != null) 'sourceUrl': sourceUrl,
    if (description != null) 'description': description,
  };
}

const presetRoutingRegions = <RoutingRegion>[
  RoutingRegion(
    id: 'monaco',
    name: 'Monaco',
    sourceUrl: 'https://download.geofabrik.de/europe/monaco-latest.osm.pbf',
    description: 'Tiny test region (~1 MB).',
  ),
  RoutingRegion(
    id: 'andorra',
    name: 'Andorra',
    sourceUrl: 'https://download.geofabrik.de/europe/andorra-latest.osm.pbf',
  ),
  RoutingRegion(
    id: 'liechtenstein',
    name: 'Liechtenstein',
    sourceUrl:
        'https://download.geofabrik.de/europe/liechtenstein-latest.osm.pbf',
  ),
  RoutingRegion(
    id: 'us',
    name: 'United States',
    sourceUrl: 'https://download.geofabrik.de/north-america/us-latest.osm.pbf',
    description: 'Large extract — allow hours to download and build.',
  ),
  RoutingRegion(
    id: 'ca',
    name: 'Canada',
    sourceUrl:
        'https://download.geofabrik.de/north-america/canada-latest.osm.pbf',
  ),
  RoutingRegion(
    id: 'de',
    name: 'Germany',
    sourceUrl: 'https://download.geofabrik.de/europe/germany-latest.osm.pbf',
  ),
  RoutingRegion(
    id: 'fr',
    name: 'France',
    sourceUrl: 'https://download.geofabrik.de/europe/france-latest.osm.pbf',
  ),
  RoutingRegion(
    id: 'gb',
    name: 'Great Britain',
    sourceUrl:
        'https://download.geofabrik.de/europe/great-britain-latest.osm.pbf',
  ),
  RoutingRegion(
    id: 'es',
    name: 'Spain',
    sourceUrl: 'https://download.geofabrik.de/europe/spain-latest.osm.pbf',
  ),
  RoutingRegion(
    id: 'it',
    name: 'Italy',
    sourceUrl: 'https://download.geofabrik.de/europe/italy-latest.osm.pbf',
  ),
  RoutingRegion(
    id: 'au',
    name: 'Australia',
    sourceUrl:
        'https://download.geofabrik.de/australia-oceania/australia-latest.osm.pbf',
  ),
  RoutingRegion(
    id: 'nz',
    name: 'New Zealand',
    sourceUrl:
        'https://download.geofabrik.de/australia-oceania/new-zealand-latest.osm.pbf',
  ),
  RoutingRegion(
    id: 'custom',
    name: 'Custom URL',
    description: 'Provide sourceUrl in the import request body.',
  ),
];

RoutingRegion? regionById(String id) {
  for (final region in presetRoutingRegions) {
    if (region.id == id) {
      return region;
    }
  }
  return null;
}

RoutingRegion? regionBySourceUrl(String url) {
  final trimmed = url.trim();
  for (final region in presetRoutingRegions) {
    if (region.id == 'custom') {
      continue;
    }
    final sourceUrl = region.sourceUrl;
    if (sourceUrl != null && sourceUrl.trim() == trimmed) {
      return region;
    }
  }
  return null;
}

/// Display label for status messages (`Monaco`, `custom region`, …).
String extractDisplayName({String? regionId, String? sourceUrl}) {
  if (regionId != null && regionId.isNotEmpty && regionId != 'custom') {
    final byId = regionById(regionId);
    if (byId != null) {
      return byId.name;
    }
  }
  if (sourceUrl != null && sourceUrl.trim().isNotEmpty) {
    final byUrl = regionBySourceUrl(sourceUrl);
    if (byUrl != null) {
      return byUrl.name;
    }
  }
  return 'custom region';
}

String? resolveSourceUrl({String? regionId, String? sourceUrl}) {
  if (sourceUrl != null && sourceUrl.trim().isNotEmpty) {
    return sourceUrl.trim();
  }
  if (regionId == null || regionId == 'custom') {
    return null;
  }
  return regionById(regionId)?.sourceUrl;
}
