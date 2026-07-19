import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_flutter/features/lines/models/line_geometry.dart';
import 'package:wayfinder_flutter/features/lines/utils/merge_line_geometry.dart';

void main() {
  test('mergeLineGeometries keeps interior control points and may reverse', () {
    final a = const LineGeometry(
      points: [
        LatLng(38.9100, -77.2630),
        LatLng(38.9102, -77.2630), // interior
        LatLng(38.9104, -77.2630),
      ],
      showArrows: false,
      pathMode: LinePathMode.smooth,
    );
    // Drawn opposite direction; should reverse to connect to A's end.
    final b = const LineGeometry(
      points: [
        LatLng(38.9108, -77.2630),
        LatLng(38.9106, -77.2630), // interior
        LatLng(38.9104, -77.2630),
      ],
      showArrows: true,
    );

    final merged = mergeLineGeometries([a, b]);
    expect(merged.points.length, 5); // shared join not duplicated
    expect(merged.pathMode, LinePathMode.smooth);
    expect(merged.points.first, a.points.first);
    expect(
      merged.points.any(
        (p) =>
            (p.latitude - 38.9102).abs() < 1e-9 &&
            (p.longitude - -77.2630).abs() < 1e-9,
      ),
      isTrue,
    );
    expect(
      merged.points.any(
        (p) =>
            (p.latitude - 38.9106).abs() < 1e-9 &&
            (p.longitude - -77.2630).abs() < 1e-9,
      ),
      isTrue,
    );
  });
}
