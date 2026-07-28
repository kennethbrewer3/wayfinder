import 'dart:io';

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

    test('extractDisplayName uses preset name or custom region', () {
      expect(extractDisplayName(regionId: 'monaco'), 'Monaco');
      expect(extractDisplayName(regionId: 'us-virginia'), 'Virginia (US)');
      expect(
        extractDisplayName(
          sourceUrl:
              'https://download.geofabrik.de/europe/monaco-latest.osm.pbf',
        ),
        'Monaco',
      );
      expect(
        extractDisplayName(sourceUrl: 'https://example.com/custom.osm.pbf'),
        'custom region',
      );
    });

    test('includes US state extracts and de-emphasizes full US', () {
      expect(regionById('us-virginia'), isNotNull);
      expect(regionById('us-california'), isNotNull);
      expect(regionById('us-wyoming'), isNotNull);
      expect(regionById('us')?.name, contains('entire'));
      final stateCount = presetRoutingRegions
          .where((r) => r.id.startsWith('us-'))
          .length;
      expect(stateCount, greaterThanOrEqualTo(50));
      expect(
        resolveSourceUrl(regionId: 'us-virginia'),
        contains('/us/virginia-latest.osm.pbf'),
      );
    });

    test('merge helpers order ids and label multi-state sets', () {
      expect(isUsStateRegionId('us-virginia'), isTrue);
      expect(isUsStateRegionId('us'), isFalse);
      expect(
        mergeSourceUrl(['us-west-virginia', 'us-virginia']),
        'merge://us-virginia+us-west-virginia',
      );
      expect(
        combinedRegionId(['us-west-virginia', 'us-virginia']),
        'us-virginia+us-west-virginia',
      );
      expect(
        combinedDisplayName(['us-virginia', 'us-west-virginia']),
        'Virginia (US) + West Virginia (US)',
      );
      expect(
        parseCombinedRegionId('us-virginia+us-west-virginia'),
        ['us-virginia', 'us-west-virginia'],
      );
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

    test('maps GeoJSON LineString points from GraphHopper', () {
      final route = translateGraphHopperRoute({
        'paths': [
          {
            'distance': 50,
            'time': 1000,
            'points_encoded': false,
            'points': {
              'type': 'LineString',
              'coordinates': [
                [7.424, 43.738],
                [7.420, 43.735],
              ],
            },
            'instructions': const <Map<String, dynamic>>[],
          },
        ],
      });

      expect(route['points'], [
        {'lat': 43.738, 'lon': 7.424},
        {'lat': 43.735, 'lon': 7.420},
      ]);
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

  group('ImportService PBF reuse', () {
    late Directory tempDir;
    late RoutingConfig config;
    late StatusStore statusStore;
    late ImportService importService;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'wayfinder-routing-test-',
      );
      config = RoutingConfig(
        port: 18382,
        dataDir: tempDir.path,
        graphHopperUrl: 'http://127.0.0.1:8989',
        graphHopperJar: '/tmp/missing.jar',
        javaBin: 'java',
        javaXmx: '2g',
        configYmlPath: '/tmp/config.yml',
      );
      statusStore = StatusStore(config);
      importService = ImportService(
        config: config,
        statusStore: statusStore,
        graphHopperProcess: GraphHopperProcess(config),
      );
    });

    tearDown(() async {
      importService.dispose();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('hasReusablePbf is false when PBF is missing', () async {
      expect(
        await importService.hasReusablePbf('https://example.com/a.pbf'),
        isFalse,
      );
    });

    test('hasReusablePbf is true when sidecar URL matches', () async {
      await File(config.osmPbfPath).writeAsBytes(const [1, 2, 3]);
      await importService.writeCachedSourceUrl('https://example.com/a.pbf');
      expect(
        await importService.hasReusablePbf('https://example.com/a.pbf'),
        isTrue,
      );
      expect(
        await importService.hasReusablePbf('https://example.com/other.pbf'),
        isFalse,
      );
    });

    test('hasReusablePbf is true for local:// when PBF exists', () async {
      await File(config.osmPbfPath).writeAsBytes(const [1, 2, 3]);
      expect(
        await importService.hasReusablePbf('local://osm.pbf'),
        isTrue,
      );
    });

    test('hasReusablePbf falls back to status sourceUrl', () async {
      await File(config.osmPbfPath).writeAsBytes(const [1, 2, 3]);
      await statusStore.update(
        RoutingStatusSnapshot(
          status: RoutingStatus.failed,
          message: 'fail',
          sourceUrl: 'https://example.com/a.pbf',
          ready: false,
        ),
      );
      expect(
        await importService.hasReusablePbf('https://example.com/a.pbf'),
        isTrue,
      );
    });
  });
}
