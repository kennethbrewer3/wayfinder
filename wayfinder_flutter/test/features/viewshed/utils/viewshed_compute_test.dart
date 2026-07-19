import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_flutter/features/viewshed/utils/viewshed_compute.dart';

void main() {
  const observer = LatLng(45.0, -75.0);

  group('castViewshedRay', () {
    test('sees flat ground out to range', () {
      final result = castViewshedRay(
        observer: observer,
        observerEyeMeters: 102,
        bearingDegrees: 0,
        rangeMeters: 1000,
        stepMeters: 100,
        heightAt: (_) => 100,
      );

      expect(result.visibleSampleCount, greaterThan(0));
      expect(
        const Distance().as(LengthUnit.Meter, observer, result.farthestVisible),
        closeTo(1000, 5),
      );
    });

    test('stops at a blocking ridge then can see a taller far peak', () {
      final result = castViewshedRay(
        observer: observer,
        observerEyeMeters: 100,
        bearingDegrees: 90,
        rangeMeters: 1000,
        stepMeters: 100,
        heightAt: (point) {
          final distance = const Distance().as(
            LengthUnit.Meter,
            observer,
            point,
          );
          if (distance < 350) {
            return 90;
          }
          if (distance < 550) {
            return 140;
          }
          if (distance < 850) {
            return 80;
          }
          return 200;
        },
      );

      expect(result.visibleSampleCount, greaterThan(1));
      final farthestDistance = const Distance().as(
        LengthUnit.Meter,
        observer,
        result.farthestVisible,
      );
      expect(farthestDistance, greaterThan(850));
    });

    test('does not see into a valley behind a ridge', () {
      final result = castViewshedRay(
        observer: observer,
        observerEyeMeters: 100,
        bearingDegrees: 180,
        rangeMeters: 800,
        stepMeters: 100,
        heightAt: (point) {
          final distance = const Distance().as(
            LengthUnit.Meter,
            observer,
            point,
          );
          if (distance < 350) {
            return 95;
          }
          if (distance < 450) {
            return 160;
          }
          return 70;
        },
      );

      final farthestDistance = const Distance().as(
        LengthUnit.Meter,
        observer,
        result.farthestVisible,
      );
      expect(farthestDistance, lessThan(500));
      expect(result.visibleSampleCount, lessThan(8));
    });
  });

  group('viewshedPolygonFromRays', () {
    test('closes the ring', () {
      final rays = [
        ViewshedRayResult(
          bearingDegrees: 0,
          farthestVisible: const LatLng(45.01, -75.0),
          visibleSampleCount: 1,
        ),
        ViewshedRayResult(
          bearingDegrees: 120,
          farthestVisible: const LatLng(45.0, -74.99),
          visibleSampleCount: 1,
        ),
        ViewshedRayResult(
          bearingDegrees: 240,
          farthestVisible: const LatLng(44.99, -75.0),
          visibleSampleCount: 1,
        ),
      ];
      final polygon = viewshedPolygonFromRays(rays);
      expect(polygon.length, 4);
      expect(polygon.first, polygon.last);
    });
  });

  group('defaultAntennaHeightForMarkerIcon', () {
    test('uses RF-oriented defaults', () {
      expect(defaultAntennaHeightForMarkerIcon('lookout'), 2);
      expect(defaultAntennaHeightForMarkerIcon('mesh_network_node'), 8);
      expect(defaultAntennaHeightForMarkerIcon('radio_repeater'), 15);
      expect(defaultAntennaHeightForMarkerIcon(null), 2);
    });
  });
}
