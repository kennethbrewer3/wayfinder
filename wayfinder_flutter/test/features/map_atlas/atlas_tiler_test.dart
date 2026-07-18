import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/features/map_atlas/models/atlas_bounds.dart';
import 'package:wayfinder_flutter/features/map_atlas/utils/atlas_tiler.dart';

void main() {
  const coverage = AtlasBounds(
    south: 38.0,
    west: -78.0,
    north: 40.0,
    east: -76.0,
  );

  test('tiles coverage into columns×rows sheets', () {
    final sheets = tileAtlasBounds(
      coverage: coverage,
      columns: 2,
      rows: 2,
      overlapFraction: 0,
    );

    expect(sheets, hasLength(4));
    expect(sheets.map((s) => s.id).toList(), ['A1', 'B1', 'A2', 'B2']);
    expect(sheets.first.bounds.south, closeTo(38.0, 1e-9));
    expect(sheets.first.bounds.west, closeTo(-78.0, 1e-9));
    expect(sheets.last.bounds.north, closeTo(40.0, 1e-9));
    expect(sheets.last.bounds.east, closeTo(-76.0, 1e-9));
  });

  test('applies overlap so neighboring sheets share edges', () {
    final sheets = tileAtlasBounds(
      coverage: coverage,
      columns: 2,
      rows: 1,
      overlapFraction: 0.1,
    );

    expect(sheets, hasLength(2));
    final left = sheets[0].bounds;
    final right = sheets[1].bounds;
    expect(left.east, greaterThan(right.west));
    expect(left.west, lessThan(coverage.west + 0.01));
    expect(right.east, greaterThan(coverage.east - 0.01));
  });

  test('returns empty for invalid inputs', () {
    expect(
      tileAtlasBounds(
        coverage: const AtlasBounds(
          south: 40,
          west: -78,
          north: 38,
          east: -76,
        ),
        columns: 2,
        rows: 2,
      ),
      isEmpty,
    );
    expect(
      tileAtlasBounds(coverage: coverage, columns: 0, rows: 2),
      isEmpty,
    );
  });

  test('fromMarkers pads a single point into a usable box', () {
    final bounds = AtlasBounds.fromMarkers([
      MapMarker(
        name: 'Camp',
        latitude: 38.9,
        longitude: -77.0,
        color: '#ff0000',
        icon: 'pin',
        visible: true,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
    ]);
    expect(bounds, isNotNull);
    expect(bounds!.isValid, isTrue);
    expect(bounds.latSpan, greaterThan(0.01));
    expect(bounds.lngSpan, greaterThan(0.01));
  });
}
