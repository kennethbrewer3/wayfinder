import 'package:latlong2/latlong.dart';
import 'package:test/test.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/features/map/models/map_viewport.dart';
import 'package:wayfinder_flutter/features/markers/utils/marker_share_url.dart';

void main() {
  test('buildMarkerShareUrl includes marker id and map position', () {
    final marker = MapMarker(
      id: UuidValue.fromString('11111111-1111-4111-8111-111111111111'),
      name: 'Home',
      latitude: 38.903937,
      longitude: -77.263575,
      elevation: 0,
      color: '#ff0000',
      icon: 'home',
      visible: true,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

    final url = buildMarkerShareUrl(marker: marker);
    final uri = Uri.parse(url.startsWith('/') ? 'https://example.com$url' : url);

    expect(uri.queryParameters['marker'], marker.id.toString());
    expect(uri.queryParameters['lat'], '38.903937');
    expect(uri.queryParameters['lng'], '-77.263575');
    expect(uri.queryParameters['zoom'], markerShareDefaultZoom.toStringAsFixed(2));
  });

  test('parseMarkerIdFromUri round trips through buildMapShareUri', () {
    final markerId = UuidValue.fromString('22222222-2222-4222-8222-222222222222');
    final uri = buildMapShareUri(
      viewport: MapViewport(
        center: LatLng(1, 2),
        zoom: 12,
      ),
      markerId: markerId,
    );

    expect(parseMarkerIdFromUri(uri), markerId);
  });

  test('parseMarkerIdFromUri reads marker from full share URL', () {
    final uri = Uri.parse(
      'http://atlas.brewerhomestead.com:9080/maps'
      '?lat=38.915912&lng=-77.511064&zoom=16.00'
      '&marker=c98fee7e-f549-4964-be20-1cc0fc4127d9#',
    );

    expect(
      parseMarkerIdFromUri(uri),
      UuidValue.fromString('c98fee7e-f549-4964-be20-1cc0fc4127d9'),
    );
  });
}
