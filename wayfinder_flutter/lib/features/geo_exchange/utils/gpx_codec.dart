import 'package:latlong2/latlong.dart';
import 'package:xml/xml.dart';

import '../models/geo_exchange_models.dart';

GeoExchangeBundle parseGpx(String contents) {
  final document = XmlDocument.parse(contents);
  final waypoints = <GeoWaypoint>[];
  final tracks = <GeoTrack>[];

  for (final wpt in document.findAllElements('wpt')) {
    final point = _latLngFromElement(wpt);
    if (point == null) {
      continue;
    }
    waypoints.add(
      GeoWaypoint(
        name: _childText(wpt, 'name') ?? 'Waypoint',
        point: point,
        elevation: double.tryParse(_childText(wpt, 'ele') ?? ''),
        description: _childText(wpt, 'desc'),
      ),
    );
  }

  for (final rte in document.findAllElements('rte')) {
    final points = <LatLng>[];
    for (final rtept in rte.findElements('rtept')) {
      final point = _latLngFromElement(rtept);
      if (point != null) {
        points.add(point);
      }
    }
    if (points.length >= 2) {
      tracks.add(
        GeoTrack(
          name: _childText(rte, 'name') ?? 'Route',
          points: points,
          description: _childText(rte, 'desc'),
        ),
      );
    }
  }

  for (final trk in document.findAllElements('trk')) {
    final points = <LatLng>[];
    for (final trkpt in trk.findAllElements('trkpt')) {
      final point = _latLngFromElement(trkpt);
      if (point != null) {
        points.add(point);
      }
    }
    if (points.length >= 2) {
      tracks.add(
        GeoTrack(
          name: _childText(trk, 'name') ?? 'Track',
          points: points,
          description: _childText(trk, 'desc'),
        ),
      );
    }
  }

  return GeoExchangeBundle(waypoints: waypoints, tracks: tracks);
}

String encodeGpx(GeoExchangeBundle bundle) {
  final builder = XmlBuilder();
  builder.processing('xml', 'version="1.0" encoding="UTF-8"');
  builder.element(
    'gpx',
    nest: () {
      builder.attribute('version', '1.1');
      builder.attribute('creator', 'Wayfinder');
      builder.attribute('xmlns', 'http://www.topografix.com/GPX/1/1');

      for (final waypoint in bundle.waypoints) {
        builder.element(
          'wpt',
          nest: () {
            builder.attribute('lat', waypoint.point.latitude.toString());
            builder.attribute('lon', waypoint.point.longitude.toString());
            builder.element('name', nest: waypoint.name);
            if (waypoint.elevation != null) {
              builder.element('ele', nest: waypoint.elevation!.toString());
            }
            if (waypoint.description != null &&
                waypoint.description!.trim().isNotEmpty) {
              builder.element('desc', nest: waypoint.description);
            }
          },
        );
      }

      for (final track in bundle.tracks.where((t) => t.isValid)) {
        builder.element(
          'trk',
          nest: () {
            builder.element('name', nest: track.name);
            if (track.description != null &&
                track.description!.trim().isNotEmpty) {
              builder.element('desc', nest: track.description);
            }
            builder.element(
              'trkseg',
              nest: () {
                for (final point in track.points) {
                  builder.element(
                    'trkpt',
                    nest: () {
                      builder.attribute('lat', point.latitude.toString());
                      builder.attribute('lon', point.longitude.toString());
                    },
                  );
                }
              },
            );
          },
        );
      }
    },
  );
  return builder.buildDocument().toXmlString(pretty: true);
}

LatLng? _latLngFromElement(XmlElement element) {
  final lat = double.tryParse(element.getAttribute('lat') ?? '');
  final lon = double.tryParse(element.getAttribute('lon') ?? '');
  if (lat == null || lon == null) {
    return null;
  }
  return LatLng(lat, lon);
}

String? _childText(XmlElement parent, String name) {
  final values = parent.findElements(name);
  if (values.isEmpty) {
    return null;
  }
  final text = values.first.innerText.trim();
  return text.isEmpty ? null : text;
}
