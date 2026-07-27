import 'package:test/test.dart';
import 'package:wayfinder_routing_server/routing_server.dart';

void main() {
  group('presetRoutingRegions', () {
    test('is non-empty and includes monaco and custom', () {
      expect(presetRoutingRegions, isNotEmpty);
      expect(regionById('monaco'), isNotNull);
      expect(regionById('custom'), isNotNull);
    });

    test('resolveSourceUrl prefers explicit sourceUrl', () {
      expect(
        resolveSourceUrl(
          regionId: 'monaco',
          sourceUrl: 'https://example.com/custom.pbf',
        ),
        'https://example.com/custom.pbf',
      );
    });

    test('resolveSourceUrl uses region preset', () {
      final url = resolveSourceUrl(regionId: 'monaco');
      expect(url, contains('monaco'));
      expect(url, contains('.osm.pbf'));
    });

    test('resolveSourceUrl returns null for custom without url', () {
      expect(resolveSourceUrl(regionId: 'custom'), isNull);
    });
  });

  group('decodePolyline', () {
    test('decodes a known polyline', () {
      // Encodes roughly (38.5, -120.2) → (40.7, -120.95) → (43.252, -126.453)
      const encoded = '_p~iF~ps|U_ulLnnqC_mqNvxq`@';
      final decoded = decodePolyline(encoded);

      expect(decoded.length, 3);
      expect(decoded[0][0], closeTo(38.5, 0.001));
      expect(decoded[0][1], closeTo(-120.2, 0.001));
      expect(decoded[1][0], closeTo(40.7, 0.001));
      expect(decoded[1][1], closeTo(-120.95, 0.001));
    });
  });

  group('translateGraphHopperRoute', () {
    test('maps GraphHopper JSON to Wayfinder route shape', () {
      final route = translateGraphHopperRoute({
        'paths': [
          {
            'distance': 1234.5,
            'time': 600000,
            'points_encoded': false,
            'points': [
              [7.424, 43.738],
              [7.420, 43.735],
            ],
            'instructions': [
              {
                'text': 'Turn right onto Main St',
                'street_name': 'Main St',
                'distance': 100,
                'time': 80000,
                'sign': 2,
                'interval': [0, 1],
              },
            ],
          },
        ],
      });

      expect(route['distanceMeters'], 1234.5);
      expect(route['timeMs'], 600000);
      expect(route['points'], [
        {'lat': 43.738, 'lon': 7.424},
        {'lat': 43.735, 'lon': 7.420},
      ]);
      final instructions = route['instructions'] as List<dynamic>;
      expect(instructions.first['streetName'], 'Main St');
      expect(instructions.first['sign'], 2);
    });
  });

  group('normalizeRoutingProfile', () {
    test('accepts foot, bike, car', () {
      expect(normalizeRoutingProfile('foot'), 'foot');
      expect(normalizeRoutingProfile('BIKE'), 'bike');
      expect(normalizeRoutingProfile(null), 'foot');
    });

    test('rejects unknown profiles', () {
      expect(() => normalizeRoutingProfile('plane'), throwsArgumentError);
    });
  });
}
