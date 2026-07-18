import 'dart:convert';

import 'package:latlong2/latlong.dart';

import '../models/geo_exchange_models.dart';

GeoExchangeBundle parseGeoJson(String contents) {
  final decoded = jsonDecode(contents);
  final waypoints = <GeoWaypoint>[];
  final tracks = <GeoTrack>[];

  void handleFeature(Map<String, dynamic> feature, {String? fallbackName}) {
    final geometry = feature['geometry'];
    if (geometry is! Map<String, dynamic>) {
      return;
    }
    final type = geometry['type'] as String?;
    final coordinates = geometry['coordinates'];
    final properties = feature['properties'];
    final props = properties is Map<String, dynamic> ? properties : const {};
    final name = (props['name'] as String?)?.trim().isNotEmpty == true
        ? (props['name'] as String).trim()
        : (fallbackName ?? 'Imported');
    final description = props['description'] as String?;

    if (type == 'Point' && coordinates is List && coordinates.length >= 2) {
      final lng = (coordinates[0] as num).toDouble();
      final lat = (coordinates[1] as num).toDouble();
      final ele = coordinates.length > 2
          ? (coordinates[2] as num).toDouble()
          : null;
      waypoints.add(
        GeoWaypoint(
          name: name,
          point: LatLng(lat, lng),
          elevation: ele,
          description: description,
        ),
      );
      return;
    }

    if (type == 'LineString' && coordinates is List) {
      final points = _coordsToLatLngs(coordinates);
      if (points.length >= 2) {
        tracks.add(
          GeoTrack(name: name, points: points, description: description),
        );
      }
      return;
    }

    if (type == 'MultiLineString' && coordinates is List) {
      var index = 1;
      for (final line in coordinates) {
        if (line is! List) {
          continue;
        }
        final points = _coordsToLatLngs(line);
        if (points.length >= 2) {
          tracks.add(
            GeoTrack(
              name: index == 1 ? name : '$name $index',
              points: points,
              description: description,
            ),
          );
          index++;
        }
      }
    }
  }

  if (decoded is Map<String, dynamic>) {
    final type = decoded['type'] as String?;
    if (type == 'FeatureCollection') {
      final features = decoded['features'];
      if (features is List) {
        var i = 1;
        for (final feature in features) {
          if (feature is Map<String, dynamic>) {
            handleFeature(feature, fallbackName: 'Feature $i');
            i++;
          }
        }
      }
    } else if (type == 'Feature') {
      handleFeature(decoded);
    } else if (decoded['geometry'] is Map<String, dynamic> ||
        decoded['coordinates'] != null) {
      handleFeature({
        'type': 'Feature',
        'geometry': decoded,
        'properties': const {},
      });
    }
  }

  return GeoExchangeBundle(waypoints: waypoints, tracks: tracks);
}

String encodeGeoJson(GeoExchangeBundle bundle) {
  final features = <Map<String, dynamic>>[
    for (final waypoint in bundle.waypoints)
      {
        'type': 'Feature',
        'properties': {
          'name': waypoint.name,
          if (waypoint.description != null &&
              waypoint.description!.trim().isNotEmpty)
            'description': waypoint.description,
        },
        'geometry': {
          'type': 'Point',
          'coordinates': [
            waypoint.point.longitude,
            waypoint.point.latitude,
            if (waypoint.elevation != null) waypoint.elevation,
          ],
        },
      },
    for (final track in bundle.tracks.where((t) => t.isValid))
      {
        'type': 'Feature',
        'properties': {
          'name': track.name,
          if (track.description != null && track.description!.trim().isNotEmpty)
            'description': track.description,
        },
        'geometry': {
          'type': 'LineString',
          'coordinates': [
            for (final point in track.points)
              [point.longitude, point.latitude],
          ],
        },
      },
  ];

  return const JsonEncoder.withIndent('  ').convert({
    'type': 'FeatureCollection',
    'features': features,
  });
}

List<LatLng> _coordsToLatLngs(List<dynamic> coordinates) {
  final points = <LatLng>[];
  for (final coord in coordinates) {
    if (coord is! List || coord.length < 2) {
      continue;
    }
    points.add(
      LatLng((coord[1] as num).toDouble(), (coord[0] as num).toDouble()),
    );
  }
  return points;
}
