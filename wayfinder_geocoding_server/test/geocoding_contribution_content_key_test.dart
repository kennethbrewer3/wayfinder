import 'package:test/test.dart';
import 'package:wayfinder_geocoding_server/src/geocoding/geocoding_contribution_content_key.dart';

void main() {
  group('GeocodingContributionContentKey', () {
    test('is stable for normalized input', () {
      final first = GeocodingContributionContentKey.compute(
        name: '  Hidden Lake Trailhead  ',
        latitude: 47.123456789,
        longitude: -122.543219876,
      );
      final second = GeocodingContributionContentKey.compute(
        name: 'hidden lake trailhead',
        latitude: 47.12346,
        longitude: -122.54322,
      );

      expect(first, second);
      expect(first.length, 64);
    });

    test('changes when coordinates change', () {
      final base = GeocodingContributionContentKey.compute(
        name: 'Camp Alpha',
        latitude: 40.0,
        longitude: -105.0,
      );
      final moved = GeocodingContributionContentKey.compute(
        name: 'Camp Alpha',
        latitude: 40.00001,
        longitude: -105.0,
      );

      expect(base, isNot(moved));
    });
  });
}
