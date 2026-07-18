import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/map_atlas/models/atlas_bounds.dart';
import 'package:wayfinder_flutter/features/map_atlas/utils/atlas_web_mercator.dart';

void main() {
  test('mercator helpers place equator and poles consistently', () {
    expect(lngToMercatorX(0), closeTo(0.5, 1e-9));
    expect(lngToMercatorX(-180), closeTo(0.0, 1e-9));
    expect(lngToMercatorX(180), closeTo(1.0, 1e-9));
    expect(latToMercatorY(0), closeTo(0.5, 1e-6));
    expect(latToMercatorY(atlasMercatorMaxLat), lessThan(0.01));
    expect(latToMercatorY(-atlasMercatorMaxLat), greaterThan(0.99));
  });

  test('pickAtlasTileZoom stays within tile budget', () {
    const bounds = AtlasBounds(
      south: 38.8,
      west: -77.2,
      north: 39.0,
      east: -76.9,
    );
    final zoom = pickAtlasTileZoom(bounds, maxTiles: 48);
    final range = tileRangeForBounds(bounds: bounds, zoom: zoom);
    final count =
        (range.maxX - range.minX + 1) * (range.maxY - range.minY + 1);
    expect(zoom, inInclusiveRange(1, 15));
    expect(count, lessThanOrEqualTo(48));
  });
}
