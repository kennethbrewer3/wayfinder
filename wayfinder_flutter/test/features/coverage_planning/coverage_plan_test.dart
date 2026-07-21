import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_flutter/features/coverage_planning/models/coverage_plan.dart';
import 'package:wayfinder_flutter/features/lines/utils/line_distance.dart';

void main() {
  group('buildCoveragePlanSites', () {
    final seed = LatLng(35.0, -85.0);

    test('single layout returns only the seed', () {
      final sites = buildCoveragePlanSites(
        seed: seed,
        layout: CoverageLayoutKind.single,
        spacingMeters: 3000,
      );
      expect(sites, hasLength(1));
      expect(sites.single.isSeed, isTrue);
      expect(sites.single.center, seed);
    });

    test('hex ring places six neighbors at spacing', () {
      const spacing = 5000.0;
      final sites = buildCoveragePlanSites(
        seed: seed,
        layout: CoverageLayoutKind.hexRing,
        spacingMeters: spacing,
      );
      expect(sites, hasLength(7));
      expect(sites.where((s) => s.isSeed), hasLength(1));

      for (final site in sites.skip(1)) {
        final distance = lineLengthMeters(seed, site.center);
        expect(distance, closeTo(spacing, 25));
      }
    });
  });

  group('CoverageTemplateKind defaults', () {
    test('mesh uses mesh icon and shorter radius than repeater', () {
      expect(CoverageTemplateKind.mesh.markerIcon, 'mesh_network_node');
      expect(
        CoverageTemplateKind.mesh.defaultCoverageRadiusMeters,
        lessThan(
          CoverageTemplateKind.repeater.defaultCoverageRadiusMeters,
        ),
      );
    });
  });
}
