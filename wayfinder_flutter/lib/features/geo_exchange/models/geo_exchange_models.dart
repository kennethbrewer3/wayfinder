import 'package:latlong2/latlong.dart';

enum GeoExchangeFormat { gpx, kml, geojson }

extension GeoExchangeFormatX on GeoExchangeFormat {
  String get fileExtension => switch (this) {
    GeoExchangeFormat.gpx => 'gpx',
    GeoExchangeFormat.kml => 'kml',
    GeoExchangeFormat.geojson => 'geojson',
  };

  String get label => switch (this) {
    GeoExchangeFormat.gpx => 'GPX',
    GeoExchangeFormat.kml => 'KML',
    GeoExchangeFormat.geojson => 'GeoJSON',
  };
}

class GeoWaypoint {
  const GeoWaypoint({
    required this.name,
    required this.point,
    this.elevation,
    this.description,
  });

  final String name;
  final LatLng point;
  final double? elevation;
  final String? description;
}

class GeoTrack {
  const GeoTrack({
    required this.name,
    required this.points,
    this.description,
  });

  final String name;
  final List<LatLng> points;
  final String? description;

  bool get isValid => points.length >= 2;
}

class GeoExchangeBundle {
  const GeoExchangeBundle({
    this.waypoints = const [],
    this.tracks = const [],
  });

  final List<GeoWaypoint> waypoints;
  final List<GeoTrack> tracks;

  bool get isEmpty => waypoints.isEmpty && tracks.isEmpty;

  int get featureCount => waypoints.length + tracks.length;
}

class GeoImportResult {
  const GeoImportResult({
    required this.markersCreated,
    required this.linesCreated,
  });

  final int markersCreated;
  final int linesCreated;

  int get total => markersCreated + linesCreated;
}
