import 'package:test/test.dart';
import 'package:wayfinder_geocoding_server/src/generated/protocol.dart';
import 'package:wayfinder_geocoding_server/src/geocoding/geocoding_constants.dart';
import 'package:wayfinder_geocoding_server/src/geocoding/geocoding_search_ranking.dart';

void main() {
  test('sortAddressResultsByProximity prefers the nearest duplicate address', () {
    final results = [
      GeocodeSearchResult(
        id: 1,
        name: '332 Sherwood Dr',
        displayName: 'Roanoke, Virginia, United States',
        latitude: 37.27,
        longitude: -79.94,
        importance: 0.85,
        resultType: GeocodingConstants.resultTypeAddress,
      ),
      GeocodeSearchResult(
        id: 2,
        name: '332 Sherwood Dr',
        displayName: 'Fairfax, Virginia, United States',
        latitude: 38.90,
        longitude: -77.26,
        importance: 0.85,
        resultType: GeocodingConstants.resultTypeAddress,
      ),
      GeocodeSearchResult(
        id: 3,
        name: 'Fairfax',
        displayName: 'Fairfax, Virginia, United States',
        latitude: 38.85,
        longitude: -77.30,
        importance: 0.7,
        resultType: GeocodingConstants.resultTypePlace,
      ),
    ];

    sortAddressResultsByProximity(
      results,
      latitude: 38.903,
      longitude: -77.264,
    );

    expect(results[0].id, 2);
    expect(results[1].id, 1);
    expect(results[2].id, 3);
  });
}
