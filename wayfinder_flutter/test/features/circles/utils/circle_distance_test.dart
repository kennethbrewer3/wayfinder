import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/circles/utils/circle_distance.dart';
import 'package:wayfinder_flutter/features/lines/models/measurement_units.dart';

void main() {
  group('parseCircleSizeFieldValue', () {
    test('parses metric radius in meters', () {
      expect(
        parseCircleSizeFieldValue(
          '500',
          unit: DistanceInputUnit.meters,
          asDiameter: false,
        ),
        500,
      );
    });

    test('parses metric diameter in meters as radius', () {
      expect(
        parseCircleSizeFieldValue(
          '1000',
          unit: DistanceInputUnit.meters,
          asDiameter: true,
        ),
        500,
      );
    });

    test('parses imperial radius in miles', () {
      expect(
        parseCircleSizeFieldValue(
          '1',
          unit: DistanceInputUnit.miles,
          asDiameter: false,
        ),
        closeTo(1609.344, 0.001),
      );
    });

    test('rejects radius below 1 meter', () {
      expect(
        parseCircleSizeFieldValue(
          '0.5',
          unit: DistanceInputUnit.meters,
          asDiameter: false,
        ),
        isNull,
      );
    });

    test('round-trips imperial feet', () {
      const radiusMeters = 100.0;
      final formatted = formatCircleSizeFieldValue(
        radiusMeters,
        unit: DistanceInputUnit.feet,
        asDiameter: false,
      );
      expect(
        parseCircleSizeFieldValue(
          formatted,
          unit: DistanceInputUnit.feet,
          asDiameter: false,
        ),
        closeTo(radiusMeters, 0.1),
      );
    });
  });

  group('defaultDistanceInputUnit', () {
    test('uses miles for large imperial circles', () {
      expect(
        defaultDistanceInputUnit(2000, MeasurementUnits.imperial),
        DistanceInputUnit.miles,
      );
    });

    test('uses feet for small imperial circles', () {
      expect(
        defaultDistanceInputUnit(100, MeasurementUnits.imperial),
        DistanceInputUnit.feet,
      );
    });
  });
}
