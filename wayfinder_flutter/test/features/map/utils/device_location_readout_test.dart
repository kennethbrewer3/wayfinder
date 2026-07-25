import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_flutter/features/lines/models/bearing_reference.dart';
import 'package:wayfinder_flutter/features/lines/models/measurement_units.dart';
import 'package:wayfinder_flutter/features/map/utils/device_location_readout.dart';

void main() {
  group('formatDeviceLocationPosition', () {
    test('uses lat/lng when MGRS is off', () {
      final text = formatDeviceLocationPosition(
        location: const LatLng(38.8895, -77.0353),
        showMgrs: false,
        zoom: 12,
      );
      expect(text, contains('38.889500'));
      expect(text, contains('-77.035300'));
    });

    test('uses MGRS when grid is on', () {
      final text = formatDeviceLocationPosition(
        location: const LatLng(38.8895, -77.0353),
        showMgrs: true,
        zoom: 12,
      );
      expect(text.toUpperCase(), contains('18S'));
      expect(text.contains(','), isFalse);
    });
  });

  group('formatDeviceLocationRange', () {
    test('includes distance and true bearing by default', () {
      final text = formatDeviceLocationRange(
        from: const LatLng(38.0, -77.0),
        to: const LatLng(38.1, -77.0),
        units: MeasurementUnits.metric,
        bearingReference: BearingReference.trueNorth,
        declinationDegrees: 10,
      );
      expect(text, contains('km'));
      expect(text, contains('°T'));
    });

    test('can format magnetic bearing', () {
      final text = formatDeviceLocationRange(
        from: const LatLng(38.0, -77.0),
        to: const LatLng(38.1, -77.0),
        units: MeasurementUnits.metric,
        bearingReference: BearingReference.magnetic,
        declinationDegrees: 10,
      );
      expect(text, contains('°M'));
    });
  });
}
