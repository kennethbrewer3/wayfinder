import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/markers/models/map_marker_size.dart';

void main() {
  test('clampMapMarkerSizeScale enforces min and max', () {
    expect(clampMapMarkerSizeScale(0.5), mapMarkerSizeScaleMin);
    expect(clampMapMarkerSizeScale(2.0), mapMarkerSizeScaleMax);
    expect(clampMapMarkerSizeScale(1.0), 1.0);
  });

  test('mapMarkerRenderWidth scales base marker width', () {
    expect(mapMarkerRenderWidth(1.0), 44);
    expect(mapMarkerRenderWidth(1.5), 66);
  });
}
