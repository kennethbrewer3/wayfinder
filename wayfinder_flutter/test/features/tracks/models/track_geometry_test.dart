import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/features/tracks/models/track_geometry.dart';

void main() {
  group('TrackGeometry', () {
    test('round-trips through JSON', () {
      final markerId = UuidValue.fromString('00000000-0000-4000-8000-000000000001');
      final geometry = TrackGeometry(
        markerId: markerId,
        points: [
          TrackPoint(
            point: const LatLng(38.0, -77.0),
            recordedAt: DateTime.utc(2026, 6, 29, 12),
          ),
          TrackPoint(
            point: const LatLng(38.1, -77.1),
            recordedAt: DateTime.utc(2026, 6, 29, 13),
          ),
        ],
      );

      final decoded = TrackGeometry.fromJsonString(geometry.encode());
      expect(decoded, isNotNull);
      expect(decoded!.markerId, markerId);
      expect(decoded.points.length, 2);
      expect(decoded.hasRenderablePath, isTrue);
      expect(decoded.pathPoints.last.latitude, 38.1);
    });
  });
}
