import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/features/tracks/models/track_geometry.dart';
import 'package:wayfinder_flutter/features/tracks/models/track_transportation_mode.dart';

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
        transportationMode: TrackTransportationMode.bike,
      );

      final decoded = TrackGeometry.fromJsonString(geometry.encode());
      expect(decoded, isNotNull);
      expect(decoded!.markerId, markerId);
      expect(decoded.points.length, 2);
      expect(decoded.hasRenderablePath, isTrue);
      expect(decoded.pathPoints.last.latitude, 38.1);
      expect(decoded.transportationMode, TrackTransportationMode.bike);
    });

    test('defaults transportation mode to on foot', () {
      final markerId = UuidValue.fromString('00000000-0000-4000-8000-000000000001');
      final geometry = TrackGeometry.fromJson({
        'markerId': markerId.toString(),
        'points': [
          {
            'lat': 38.0,
            'lng': -77.0,
            'recordedAt': '2026-06-29T12:00:00.000Z',
          },
        ],
      });

      expect(geometry, isNotNull);
      expect(geometry!.transportationMode, TrackTransportationMode.onFoot);
    });
  });

  group('TrackTransportationMode', () {
    test('round-trips through JSON values', () {
      for (final mode in TrackTransportationMode.values) {
        expect(
          TrackTransportationMode.fromJson(mode.toJson()),
          mode,
        );
      }
    });

    test('assigns expected trail styles', () {
      expect(TrackTransportationMode.onFoot.trailStyle, TrackTrailStyle.footprints);
      expect(TrackTransportationMode.horse.trailStyle, TrackTrailStyle.footprints);
      expect(TrackTransportationMode.bike.trailStyle, TrackTrailStyle.tread);
      expect(TrackTransportationMode.landVehicle.trailStyle, TrackTrailStyle.road);
      expect(TrackTransportationMode.train.trailStyle, TrackTrailStyle.railroad);
      expect(TrackTransportationMode.watercraft.trailStyle, TrackTrailStyle.wake);
      expect(TrackTransportationMode.aircraft.trailStyle, TrackTrailStyle.flight);
      expect(TrackTransportationMode.balloon.trailStyle, TrackTrailStyle.balloon);
    });

    test('assigns expected trail variants', () {
      expect(TrackTransportationMode.horse.footprintKind, FootprintTrailKind.hoof);
      expect(TrackTransportationMode.farmVehicle.treadKind, TreadTrailKind.tractor);
      expect(TrackTransportationMode.truck.roadKind, RoadTrailKind.wide);
      expect(TrackTransportationMode.sailboat.wakeIntensity, WakeTrailIntensity.light);
      expect(TrackTransportationMode.watercraft.wakeIntensity, WakeTrailIntensity.wide);
      expect(TrackTransportationMode.glider.flightKind, FlightTrailKind.glider);
    });
  });
}
