import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/features/map_atlas/models/atlas_bounds.dart';
import 'package:wayfinder_flutter/features/map_atlas/utils/atlas_pdf_builder.dart';

void main() {
  test('buildAtlasPdf produces a non-empty PDF', () async {
    final bytes = await buildAtlasPdf(
      options: const AtlasExportOptions(
        title: 'Test Atlas',
        coverageMode: AtlasCoverageMode.fitMarkers,
        columns: 2,
        rows: 1,
        pageSize: AtlasPageSize.letterLandscape,
      ),
      coverage: const AtlasBounds(
        south: 38.8,
        west: -77.2,
        north: 39.0,
        east: -76.9,
      ),
      markers: [
        MapMarker(
          name: 'HQ',
          latitude: 38.9,
          longitude: -77.05,
          color: '#cc0000',
          icon: 'pin',
          visible: true,
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
      ],
      zones: const [],
    );

    expect(bytes.length, greaterThan(500));
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('buildAtlasPdf with MGRS grid still produces a PDF', () async {
    final bytes = await buildAtlasPdf(
      options: const AtlasExportOptions(
        title: 'MGRS Atlas',
        coverageMode: AtlasCoverageMode.currentMapView,
        columns: 1,
        rows: 1,
        pageSize: AtlasPageSize.letterLandscape,
      ),
      coverage: const AtlasBounds(
        south: 38.85,
        west: -77.15,
        north: 38.95,
        east: -77.0,
      ),
      markers: const [],
      zones: const [],
      includeMgrsGrid: true,
    );

    expect(bytes.length, greaterThan(500));
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });
}
