import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_flutter/features/circles/models/circle_geometry.dart';
import 'package:wayfinder_flutter/features/circles/models/range_ring.dart';
import 'package:wayfinder_flutter/features/tracks/models/track_transportation_mode.dart';

void main() {
  group('rangeRingRadiusMeters', () {
    test('duration uses speed × hours', () {
      final meters = rangeRingRadiusMeters(
        mode: TrackTransportationMode.onFoot,
        basis: RangeRingBasis.duration,
        assumptions: const RangeRingAssumptions(speedKmh: 5),
        durationHours: 4,
      );
      expect(meters, 20000);
    });

    test('fuel uses liters and L/100km economy', () {
      final meters = rangeRingRadiusMeters(
        mode: TrackTransportationMode.atv,
        basis: RangeRingBasis.fuel,
        assumptions: const RangeRingAssumptions(
          speedKmh: 45,
          economyLPer100km: 12,
          tankLiters: 12,
        ),
        fuelLiters: 12,
      );
      // 12 L / 12 L/100km = 100 km
      expect(meters, 100000);
    });

    test('ATV tank default is smaller than land vehicle', () {
      final atv = defaultRangeRingAssumptions(TrackTransportationMode.atv);
      final car = defaultRangeRingAssumptions(
        TrackTransportationMode.landVehicle,
      );
      expect(atv.tankLiters!, lessThan(car.tankLiters!));
      expect(atv.economyLPer100km!, greaterThan(car.economyLPer100km!));
    });

    test('fuel basis ignored for walking', () {
      expect(
        rangeRingRadiusMeters(
          mode: TrackTransportationMode.onFoot,
          basis: RangeRingBasis.fuel,
          assumptions: defaultRangeRingAssumptions(
            TrackTransportationMode.onFoot,
          ),
          fuelLiters: 10,
        ),
        isNull,
      );
    });
  });

  group('CircleGeometry rangeRing', () {
    test('round-trips range ring metadata', () {
      final geometry = CircleGeometry(
        center: const LatLng(38.9, -77.2),
        radiusMeters: 20000,
        rangeRing: RangeRingSpec(
          mode: TrackTransportationMode.bike,
          basis: RangeRingBasis.duration,
          assumptions: defaultRangeRingAssumptions(
            TrackTransportationMode.bike,
          ),
          anchor: RangeRingAnchor.home,
          durationHours: 2,
        ),
      );

      final restored = CircleGeometry.fromJsonString(geometry.encode());
      expect(restored, isNotNull);
      expect(restored!.rangeRing, isNotNull);
      expect(restored.rangeRing!.mode, TrackTransportationMode.bike);
      expect(restored.rangeRing!.basis, RangeRingBasis.duration);
      expect(restored.rangeRing!.durationHours, 2);
      expect(restored.rangeRing!.anchor, RangeRingAnchor.home);
      expect(restored.radiusMeters, 20000);
    });
  });
}
