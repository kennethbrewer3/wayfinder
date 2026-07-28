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

/// Geofabrik slug → display name for US state / territory extracts.
/// Prefer these over [us] (entire country) for normal field use.
const _usStateExtracts = <String, String>{
  'alabama': 'Alabama',
  'alaska': 'Alaska',
  'arizona': 'Arizona',
  'arkansas': 'Arkansas',
  'california': 'California',
  'colorado': 'Colorado',
  'connecticut': 'Connecticut',
  'delaware': 'Delaware',
  'district-of-columbia': 'District of Columbia',
  'florida': 'Florida',
  'georgia': 'Georgia',
  'hawaii': 'Hawaii',
  'idaho': 'Idaho',
  'illinois': 'Illinois',
  'indiana': 'Indiana',
  'iowa': 'Iowa',
  'kansas': 'Kansas',
  'kentucky': 'Kentucky',
  'louisiana': 'Louisiana',
  'maine': 'Maine',
  'maryland': 'Maryland',
  'massachusetts': 'Massachusetts',
  'michigan': 'Michigan',
  'minnesota': 'Minnesota',
  'mississippi': 'Mississippi',
  'missouri': 'Missouri',
  'montana': 'Montana',
  'nebraska': 'Nebraska',
  'nevada': 'Nevada',
  'new-hampshire': 'New Hampshire',
  'new-jersey': 'New Jersey',
  'new-mexico': 'New Mexico',
  'new-york': 'New York',
  'north-carolina': 'North Carolina',
  'north-dakota': 'North Dakota',
  'ohio': 'Ohio',
  'oklahoma': 'Oklahoma',
  'oregon': 'Oregon',
  'pennsylvania': 'Pennsylvania',
  'puerto-rico': 'Puerto Rico',
  'rhode-island': 'Rhode Island',
  'south-carolina': 'South Carolina',
  'south-dakota': 'South Dakota',
  'tennessee': 'Tennessee',
  'texas': 'Texas',
  'utah': 'Utah',
  'vermont': 'Vermont',
  'virginia': 'Virginia',
  'washington': 'Washington',
  'west-virginia': 'West Virginia',
  'wisconsin': 'Wisconsin',
  'wyoming': 'Wyoming',
};

RoutingRegion _usStateRegion(String slug, String name) {
  final large = slug == 'california' || slug == 'texas';
  return RoutingRegion(
    id: 'us-$slug',
    name: '$name (US)',
    sourceUrl:
        'https://download.geofabrik.de/north-america/us/$slug-latest.osm.pbf',
    description: large
        ? 'Large state — plan for roughly 4–8 GB JAVA_XMX (MMAP).'
        : 'US state extract. Usually 2–4 GB JAVA_XMX (MMAP) is enough.',
  );
}

final List<RoutingRegion> _usStateRegions = [
  for (final entry in _usStateExtracts.entries)
    _usStateRegion(entry.key, entry.value),
];

final List<RoutingRegion> presetRoutingRegions = [
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
  // One GraphHopper graph at a time — import the state(s) you operate in.
  ..._usStateRegions,
  RoutingRegion(
    id: 'us',
    name: 'United States (entire)',
    sourceUrl: 'https://download.geofabrik.de/north-america/us-latest.osm.pbf',
    description:
        'Only for cross-country coverage. Prefer a single US state extract '
        'above. Entire US is multi‑GB, multi‑hour, and needs high JAVA_XMX.',
  ),
  RoutingRegion(
    id: 'ca',
    name: 'Canada',
    sourceUrl:
        'https://download.geofabrik.de/north-america/canada-latest.osm.pbf',
    description: 'Large country — plan for 8 GB+ JAVA_XMX (MMAP).',
  ),
  RoutingRegion(
    id: 'de',
    name: 'Germany',
    sourceUrl: 'https://download.geofabrik.de/europe/germany-latest.osm.pbf',
    description: 'Large — plan for 4–8 GB JAVA_XMX (MMAP).',
  ),
  RoutingRegion(
    id: 'fr',
    name: 'France',
    sourceUrl: 'https://download.geofabrik.de/europe/france-latest.osm.pbf',
    description: 'Large — plan for 4–8 GB JAVA_XMX (MMAP).',
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

/// True for Geofabrik US state/territory presets (`us-virginia`), not `us`.
bool isUsStateRegionId(String id) =>
    id.startsWith('us-') && id != 'us' && regionById(id)?.sourceUrl != null;

/// Stable merge marker so the same state set reuses the on-disk PBF.
String mergeSourceUrl(Iterable<String> regionIds) {
  final sorted =
      regionIds.map((id) => id.trim()).where((id) => id.isNotEmpty).toList()
        ..sort();
  return 'merge://${sorted.join('+')}';
}

String combinedRegionId(Iterable<String> regionIds) {
  final sorted =
      regionIds.map((id) => id.trim()).where((id) => id.isNotEmpty).toList()
        ..sort();
  return sorted.join('+');
}

String combinedDisplayName(Iterable<String> regionIds) {
  final names = <String>[];
  for (final id in regionIds) {
    final trimmed = id.trim();
    if (trimmed.isEmpty) {
      continue;
    }
    names.add(regionById(trimmed)?.name ?? trimmed);
  }
  if (names.isEmpty) {
    return 'custom region';
  }
  return names.join(' + ');
}

List<String> parseCombinedRegionId(String? regionId) {
  if (regionId == null || regionId.trim().isEmpty) {
    return const [];
  }
  if (!regionId.contains('+')) {
    return [regionId.trim()];
  }
  return [
    for (final part in regionId.split('+'))
      if (part.trim().isNotEmpty) part.trim(),
  ];
}
