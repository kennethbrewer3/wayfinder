import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_flutter/features/geo_exchange/models/geo_exchange_models.dart';
import 'package:wayfinder_flutter/features/geo_exchange/utils/geo_exchange_codec.dart';
import 'package:wayfinder_flutter/features/geo_exchange/utils/geo_exchange_detect.dart';

void main() {
  const sample = GeoExchangeBundle(
    waypoints: [
      GeoWaypoint(
        name: 'Camp',
        point: LatLng(38.8977, -77.0365),
        elevation: 12,
        description: 'Near the mall',
      ),
    ],
    tracks: [
      GeoTrack(
        name: 'Trail',
        points: [
          LatLng(38.90, -77.04),
          LatLng(38.91, -77.03),
          LatLng(38.92, -77.02),
        ],
        description: 'Ridge walk',
      ),
    ],
  );

  test('detects format from extension and content', () {
    expect(
      detectGeoExchangeFormat(fileName: 'a.gpx', contents: '<gpx></gpx>'),
      GeoExchangeFormat.gpx,
    );
    expect(
      detectGeoExchangeFormat(fileName: 'a.kml', contents: '<kml></kml>'),
      GeoExchangeFormat.kml,
    );
    expect(
      detectGeoExchangeFormat(
        fileName: 'a.geojson',
        contents: '{"type":"FeatureCollection","features":[]}',
      ),
      GeoExchangeFormat.geojson,
    );
    expect(
      detectGeoExchangeFormat(
        fileName: 'a.txt',
        contents: '<gpx version="1.1">',
      ),
      GeoExchangeFormat.gpx,
    );
  });

  test('GPX round-trip preserves waypoints and tracks', () {
    final encoded = encodeGeoExchange(sample, format: GeoExchangeFormat.gpx);
    final parsed = parseGeoExchange(contents: encoded, fileName: 'out.gpx');
    expect(parsed.waypoints, hasLength(1));
    expect(parsed.waypoints.single.name, 'Camp');
    expect(parsed.waypoints.single.point.latitude, closeTo(38.8977, 1e-6));
    expect(parsed.waypoints.single.elevation, 12);
    expect(parsed.tracks, hasLength(1));
    expect(parsed.tracks.single.name, 'Trail');
    expect(parsed.tracks.single.points, hasLength(3));
  });

  test('KML round-trip preserves waypoints and tracks', () {
    final encoded = encodeGeoExchange(sample, format: GeoExchangeFormat.kml);
    final parsed = parseGeoExchange(contents: encoded, fileName: 'out.kml');
    expect(parsed.waypoints.single.name, 'Camp');
    expect(parsed.waypoints.single.point.longitude, closeTo(-77.0365, 1e-6));
    expect(parsed.tracks.single.points, hasLength(3));
  });

  test('GeoJSON round-trip preserves waypoints and tracks', () {
    final encoded = encodeGeoExchange(
      sample,
      format: GeoExchangeFormat.geojson,
    );
    final parsed = parseGeoExchange(
      contents: encoded,
      fileName: 'out.geojson',
    );
    expect(parsed.waypoints.single.description, 'Near the mall');
    expect(parsed.tracks.single.description, 'Ridge walk');
    expect(parsed.tracks.single.points.last.latitude, closeTo(38.92, 1e-6));
  });

  test('parses GPX routes as tracks', () {
    const gpx = '''
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="test">
  <rte>
    <name>Loop</name>
    <rtept lat="1" lon="2"/>
    <rtept lat="3" lon="4"/>
  </rte>
</gpx>
''';
    final parsed = parseGeoExchange(contents: gpx, fileName: 'route.gpx');
    expect(parsed.tracks.single.name, 'Loop');
    expect(parsed.tracks.single.points, hasLength(2));
  });
}
