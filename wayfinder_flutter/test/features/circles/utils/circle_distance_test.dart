import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/circles/utils/circle_distance.dart';
import 'package:wayfinder_flutter/features/lines/models/measurement_units.dart';

void main() {
  group('parseCircleSizeFieldValue', () {
    test('parses metric radius', () {
      expect(
        parseCircleSizeFieldValue('500', MeasurementUnits.metric,
            asDiameter: false),
        500,
      );
    });

    test('parses metric diameter as radius', () {
      expect(
        parseCircleSizeFieldValue('1000', MeasurementUnits.metric,
            asDiameter: true),
        500,
      );
    });

    test('rejects radius below 1 meter', () {
      expect(
        parseCircleSizeFieldValue('0.5', MeasurementUnits.metric,
            asDiameter: false),
        isNull,
      );
    });

    test('round-trips imperial radius', () {
      const radiusMeters = 100.0;
      final formatted = formatCircleSizeFieldValue(
        radiusMeters,
        MeasurementUnits.imperial,
        asDiameter: false,
      );
      expect(
        parseCircleSizeFieldValue(
          formatted,
          MeasurementUnits.imperial,
          asDiameter: false,
        ),
        closeTo(radiusMeters, 0.1),
      );
    });
  });
}
