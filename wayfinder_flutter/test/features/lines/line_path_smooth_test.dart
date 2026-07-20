import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_flutter/features/lines/models/line_geometry.dart';
import 'package:wayfinder_flutter/features/lines/utils/line_path.dart';

void main() {
  test('smooth path stays close to chord length for gentle bends', () {
    final geometry = LineGeometry(
      points: const [
        LatLng(0, 0),
        LatLng(0.2, 0.05),
        LatLng(0.4, 0),
      ],
      showArrows: false,
      pathMode: LinePathMode.smooth,
    );
    final chord = LineGeometry(
      points: geometry.points,
      showArrows: false,
      pathMode: LinePathMode.straight,
    );
    final smoothLength = linePathLengthMeters(geometry);
    final chordLength = linePathLengthMeters(chord);

    // Chordal Catmull-Rom should not balloon far beyond the polyline chords.
    expect(smoothLength, greaterThan(chordLength));
    expect(smoothLength / chordLength, lessThan(1.08));
  });

  test('smooth render points pass through control points', () {
    final geometry = LineGeometry(
      points: const [
        LatLng(10, 10),
        LatLng(10.1, 10.2),
        LatLng(10.2, 10),
      ],
      showArrows: false,
      pathMode: LinePathMode.smooth,
    );
    final render = buildLineRenderPoints(geometry);
    expect(render.first.latitude, closeTo(10, 1e-9));
    expect(render.first.longitude, closeTo(10, 1e-9));
    expect(render.last.latitude, closeTo(10.2, 1e-9));
    expect(render.last.longitude, closeTo(10, 1e-9));

    // Middle control point should appear in the sampled polyline.
    final hitMiddle = render.any(
      (point) =>
          (point.latitude - 10.1).abs() < 1e-6 &&
          (point.longitude - 10.2).abs() < 1e-6,
    );
    expect(hitMiddle, isTrue);
  });
}
