import 'package:latlong2/latlong.dart';
import 'package:test/test.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/features/map/models/map_viewport.dart';
import 'package:wayfinder_flutter/features/markers/utils/marker_share_url.dart';

void main() {
  test('buildMarkerShareUrl uses marker id only', () {
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

    expect(uri.path, '/maps');
    expect(uri.queryParameters, {
      'marker': marker.id.toString(),
    });
  });

  test('buildMapShareUri uses marker id only when marker is selected', () {
    final markerId = UuidValue.fromString('22222222-2222-4222-8222-222222222222');
    final uri = buildMapShareUri(
      viewport: MapViewport(
        center: LatLng(1, 2),
        zoom: 12,
      ),
      markerId: markerId,
    );

    expect(uri.queryParameters, {'marker': markerId.toString()});
    expect(parseMarkerIdFromUri(uri), markerId);
  });

  test('buildMapShareUri keeps viewport params when no marker is selected', () {
    final uri = buildMapShareUri(
      viewport: MapViewport(
        center: LatLng(38.915912, -77.511064),
        zoom: 16,
      ),
    );

    expect(uri.queryParameters['lat'], '38.915912');
    expect(uri.queryParameters['lng'], '-77.511064');
    expect(uri.queryParameters['zoom'], '16.00');
    expect(uri.queryParameters.containsKey('marker'), isFalse);
  });

  test('parseMarkerIdFromUri reads marker from marker-only URL', () {
    final uri = Uri.parse(
      'http://atlas.brewerhomestead.com:9080/maps'
      '?marker=c98fee7e-f549-4964-be20-1cc0fc4127d9',
    );

    expect(
      parseMarkerIdFromUri(uri),
      UuidValue.fromString('c98fee7e-f549-4964-be20-1cc0fc4127d9'),
    );
  });

  test('parseMarkerIdFromUri still reads marker from legacy full URLs', () {
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
