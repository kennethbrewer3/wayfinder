import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/core/constants.dart';
import 'package:wayfinder_flutter/features/map/models/map_zoom_limits.dart';

void main() {
  test('defaults use 2 and 18', () {
    expect(MapZoomRange.defaults.min, 2);
    expect(MapZoomRange.defaults.max, 18);
  });

  test('validateMapZoomRange enforces ordering and limits', () {
    final range = validateMapZoomRange(
      const MapZoomRange(min: 1.5, max: 25),
    );
    expect(range.min, 1.5);
    expect(range.max, 25);
  });

  test('validateMapZoomRange bumps max when it is below min', () {
    final range = validateMapZoomRange(
      const MapZoomRange(min: 20, max: 10),
    );
    expect(range.min, 20);
    expect(range.max, 21);
  });

  test('normalizeMapZoomRange clamps to absolute limits', () {
    final range = normalizeMapZoomRange(min: 0, max: 40);
    expect(range.min, AppConstants.absoluteMapMinZoom);
    expect(range.max, AppConstants.absoluteMapMaxZoom);
  });
}
