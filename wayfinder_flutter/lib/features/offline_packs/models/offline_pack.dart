import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

/// Geographic area whose basemap tiles are cached for offline use.
class OfflinePackRegion {
  const OfflinePackRegion({
    required this.south,
    required this.west,
    required this.north,
    required this.east,
    required this.minZoom,
    required this.maxZoom,
  });

  final double south;
  final double west;
  final double north;
  final double east;
  final int minZoom;
  final int maxZoom;

  LatLng get southWest => LatLng(south, west);
  LatLng get northEast => LatLng(north, east);

  Map<String, dynamic> toJson() => {
    'south': south,
    'west': west,
    'north': north,
    'east': east,
    'minZoom': minZoom,
    'maxZoom': maxZoom,
  };

  factory OfflinePackRegion.fromJson(Map<String, dynamic> json) {
    return OfflinePackRegion(
      south: (json['south'] as num).toDouble(),
      west: (json['west'] as num).toDouble(),
      north: (json['north'] as num).toDouble(),
      east: (json['east'] as num).toDouble(),
      minZoom: (json['minZoom'] as num).toInt(),
      maxZoom: (json['maxZoom'] as num).toInt(),
    );
  }
}

/// One enabled basemap archive included in the offline tile cache.
class OfflinePackBasemap {
  const OfflinePackBasemap({
    required this.catalogId,
    required this.name,
    required this.tileType,
    required this.minZoom,
    required this.maxZoom,
    required this.south,
    required this.west,
    required this.north,
    required this.east,
  });

  final String catalogId;
  final String name;

  /// PMTiles [TileType] name: `mvt`, `png`, `jpeg`, `webp`, …
  final String tileType;
  final int minZoom;
  final int maxZoom;
  final double south;
  final double west;
  final double north;
  final double east;

  bool get isVector => tileType == 'mvt';

  Map<String, dynamic> toJson() => {
    'catalogId': catalogId,
    'name': name,
    'tileType': tileType,
    'minZoom': minZoom,
    'maxZoom': maxZoom,
    'south': south,
    'west': west,
    'north': north,
    'east': east,
  };

  factory OfflinePackBasemap.fromJson(Map<String, dynamic> json) {
    return OfflinePackBasemap(
      catalogId: json['catalogId'] as String,
      name: json['name'] as String? ?? 'Basemap',
      tileType: json['tileType'] as String? ?? 'mvt',
      minZoom: (json['minZoom'] as num?)?.toInt() ?? 0,
      maxZoom: (json['maxZoom'] as num?)?.toInt() ?? 14,
      south: (json['south'] as num?)?.toDouble() ?? -85,
      west: (json['west'] as num?)?.toDouble() ?? -180,
      north: (json['north'] as num?)?.toDouble() ?? 85,
      east: (json['east'] as num?)?.toDouble() ?? 180,
    );
  }
}

/// User-prepared offline pack: selected layers + tile region.
class OfflinePackMeta {
  const OfflinePackMeta({
    required this.id,
    required this.layerIds,
    required this.region,
    required this.preparedAt,
    required this.name,
    this.layerNames = const [],
    this.basemaps = const [],
    this.includeSeasonalOverlays = false,
    this.tileCount = 0,
    this.markerCount = 0,
    this.zoneCount = 0,
    this.seasonalOverlayCount = 0,
    this.routeCount = 0,
    this.includePackedRoutes = false,
  });

  /// Stable id for multi-pack storage and tile namespacing.
  final String id;
  final String name;

  /// Display names of packed layers (captured at prepare time).
  final List<String> layerNames;
  final List<UuidValue> layerIds;
  final OfflinePackRegion region;
  final DateTime preparedAt;
  final List<OfflinePackBasemap> basemaps;
  final bool includeSeasonalOverlays;
  final int tileCount;
  final int markerCount;
  final int zoneCount;
  final int seasonalOverlayCount;

  /// Precomputed OSM routes stored in the pack snapshot.
  final int routeCount;
  final bool includePackedRoutes;

  Set<String> get layerIdKeys => {
    for (final id in layerIds) id.uuid,
  };

  OfflinePackBasemap? basemapFor(String catalogId) {
    for (final basemap in basemaps) {
      if (basemap.catalogId == catalogId) {
        return basemap;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'layerNames': layerNames,
    'layerIds': [for (final id in layerIds) id.uuid],
    'region': region.toJson(),
    'preparedAt': preparedAt.toIso8601String(),
    'basemaps': [for (final b in basemaps) b.toJson()],
    'includeSeasonalOverlays': includeSeasonalOverlays,
    'tileCount': tileCount,
    'markerCount': markerCount,
    'zoneCount': zoneCount,
    'seasonalOverlayCount': seasonalOverlayCount,
    'routeCount': routeCount,
    'includePackedRoutes': includePackedRoutes,
  };

  factory OfflinePackMeta.fromJson(Map<String, dynamic> json) {
    return OfflinePackMeta(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Offline pack',
      layerNames: [
        for (final raw in json['layerNames'] as List? ?? const [])
          raw as String,
      ],
      layerIds: [
        for (final raw in json['layerIds'] as List? ?? const [])
          UuidValue.fromString(raw as String),
      ],
      region: OfflinePackRegion.fromJson(
        json['region'] as Map<String, dynamic>,
      ),
      preparedAt: DateTime.parse(json['preparedAt'] as String),
      basemaps: [
        for (final raw in json['basemaps'] as List? ?? const [])
          OfflinePackBasemap.fromJson(raw as Map<String, dynamic>),
      ],
      includeSeasonalOverlays:
          json['includeSeasonalOverlays'] as bool? ?? false,
      tileCount: (json['tileCount'] as num?)?.toInt() ?? 0,
      markerCount: (json['markerCount'] as num?)?.toInt() ?? 0,
      zoneCount: (json['zoneCount'] as num?)?.toInt() ?? 0,
      seasonalOverlayCount:
          (json['seasonalOverlayCount'] as num?)?.toInt() ?? 0,
      routeCount: (json['routeCount'] as num?)?.toInt() ?? 0,
      includePackedRoutes: json['includePackedRoutes'] as bool? ?? false,
    );
  }

  OfflinePackMeta copyWith({
    String? id,
    String? name,
    List<String>? layerNames,
    List<UuidValue>? layerIds,
    OfflinePackRegion? region,
    DateTime? preparedAt,
    List<OfflinePackBasemap>? basemaps,
    bool? includeSeasonalOverlays,
    int? tileCount,
    int? markerCount,
    int? zoneCount,
    int? seasonalOverlayCount,
    int? routeCount,
    bool? includePackedRoutes,
  }) {
    return OfflinePackMeta(
      id: id ?? this.id,
      name: name ?? this.name,
      layerNames: layerNames ?? this.layerNames,
      layerIds: layerIds ?? this.layerIds,
      region: region ?? this.region,
      preparedAt: preparedAt ?? this.preparedAt,
      basemaps: basemaps ?? this.basemaps,
      includeSeasonalOverlays:
          includeSeasonalOverlays ?? this.includeSeasonalOverlays,
      tileCount: tileCount ?? this.tileCount,
      markerCount: markerCount ?? this.markerCount,
      zoneCount: zoneCount ?? this.zoneCount,
      seasonalOverlayCount: seasonalOverlayCount ?? this.seasonalOverlayCount,
      routeCount: routeCount ?? this.routeCount,
      includePackedRoutes: includePackedRoutes ?? this.includePackedRoutes,
    );
  }
}
