import 'package:latlong2/latlong.dart';
import 'package:xml/xml.dart';

import '../models/geo_exchange_models.dart';

GeoExchangeBundle parseKml(String contents) {
  final document = XmlDocument.parse(contents);
  final waypoints = <GeoWaypoint>[];
  final tracks = <GeoTrack>[];

  for (final placemark in document.findAllElements('Placemark')) {
    final name = _childText(placemark, 'name') ?? 'Placemark';
    final description = _childText(placemark, 'description');

    final pointCoords = placemark.findAllElements('Point').expand(
      (point) => point.findElements('coordinates'),
    );
    for (final coords in pointCoords) {
      final points = _parseCoordinateList(coords.innerText);
      if (points.isNotEmpty) {
        waypoints.add(
          GeoWaypoint(
            name: name,
            point: points.first,
            description: description,
          ),
        );
      }
    }

    final lineCoords = placemark.findAllElements('LineString').expand(
      (line) => line.findElements('coordinates'),
    );
    for (final coords in lineCoords) {
      final points = _parseCoordinateList(coords.innerText);
      if (points.length >= 2) {
        tracks.add(
          GeoTrack(name: name, points: points, description: description),
        );
      }
    }
  }

  return GeoExchangeBundle(waypoints: waypoints, tracks: tracks);
}

String encodeKml(GeoExchangeBundle bundle) {
  final builder = XmlBuilder();
  builder.processing('xml', 'version="1.0" encoding="UTF-8"');
  builder.element(
    'kml',
    nest: () {
      builder.attribute('xmlns', 'http://www.opengis.net/kml/2.2');
      builder.element(
        'Document',
        nest: () {
          builder.element('name', nest: 'Wayfinder export');
          for (final waypoint in bundle.waypoints) {
            builder.element(
              'Placemark',
              nest: () {
                builder.element('name', nest: waypoint.name);
                if (waypoint.description != null &&
                    waypoint.description!.trim().isNotEmpty) {
                  builder.element('description', nest: waypoint.description);
                }
                builder.element(
                  'Point',
                  nest: () {
                    builder.element(
                      'coordinates',
                      nest: _formatCoordinate(
                        waypoint.point,
                        elevation: waypoint.elevation,
                      ),
                    );
                  },
                );
              },
            );
          }
          for (final track in bundle.tracks.where((t) => t.isValid)) {
            builder.element(
              'Placemark',
              nest: () {
                builder.element('name', nest: track.name);
                if (track.description != null &&
                    track.description!.trim().isNotEmpty) {
                  builder.element('description', nest: track.description);
                }
                builder.element(
                  'LineString',
                  nest: () {
                    builder.element('tessellate', nest: '1');
                    builder.element(
                      'coordinates',
                      nest: track.points
                          .map(_formatCoordinate)
                          .join('\n'),
                    );
                  },
                );
              },
            );
          }
        },
      );
    },
  );
  return builder.buildDocument().toXmlString(pretty: true);
}

List<LatLng> _parseCoordinateList(String raw) {
  final points = <LatLng>[];
  for (final token in raw.trim().split(RegExp(r'\s+'))) {
    if (token.isEmpty) {
      continue;
    }
    final parts = token.split(',');
    if (parts.length < 2) {
      continue;
    }
    final lng = double.tryParse(parts[0]);
    final lat = double.tryParse(parts[1]);
    if (lat == null || lng == null) {
      continue;
    }
    points.add(LatLng(lat, lng));
  }
  return points;
}

String _formatCoordinate(LatLng point, {double? elevation}) {
  final ele = elevation ?? 0;
  return '${point.longitude},${point.latitude},$ele';
}

String? _childText(XmlElement parent, String name) {
  final values = parent.findElements(name);
  if (values.isEmpty) {
    return null;
  }
  final text = values.first.innerText.trim();
  return text.isEmpty ? null : text;
}
