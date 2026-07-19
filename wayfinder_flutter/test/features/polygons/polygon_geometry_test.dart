import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_flutter/features/polygons/models/polygon_geometry.dart';
import 'package:wayfinder_flutter/features/polygons/utils/polygon_hit_test.dart';

void main() {
  test('polygon requires at least three vertices', () {
    final two = PolygonGeometry(
      points: const [LatLng(0, 0), LatLng(0, 1)],
    );
    expect(two.isValid, isFalse);

    final three = PolygonGeometry(
      points: const [LatLng(0, 0), LatLng(0, 1), LatLng(1, 0)],
    );
    expect(three.isValid, isTrue);
  });

  test('round-trips through JSON', () {
    final geometry = PolygonGeometry(
      points: const [
        LatLng(38.1, -78.5),
        LatLng(38.2, -78.4),
        LatLng(38.0, -78.3),
      ],
      notes: 'no-go',
      showNameLabel: true,
    );
    final decoded = PolygonGeometry.fromJsonString(geometry.encode());
    expect(decoded, isNotNull);
    expect(decoded!.points.length, 3);
    expect(decoded.points.first.latitude, 38.1);
    expect(decoded.notes, 'no-go');
    expect(decoded.showNameLabel, isTrue);
  });

  test('label point is vertex average', () {
    final geometry = PolygonGeometry(
      points: const [
        LatLng(0, 0),
        LatLng(0, 2),
        LatLng(2, 2),
        LatLng(2, 0),
      ],
    );
    expect(geometry.labelPoint.latitude, closeTo(1, 1e-9));
    expect(geometry.labelPoint.longitude, closeTo(1, 1e-9));
  });

  test('point-in-polygon screen hit test', () {
    final square = const [
      Offset(0, 0),
      Offset(10, 0),
      Offset(10, 10),
      Offset(0, 10),
    ];
    expect(pointInPolygonScreen(const Offset(5, 5), square), isTrue);
    expect(pointInPolygonScreen(const Offset(15, 5), square), isFalse);
  });
}
