import 'measurement_units.dart';

enum DistanceInputUnit {
  meters,
  kilometers,
  feet,
  miles,
  yards,
  nauticalMiles,
}

extension DistanceInputUnitLabels on DistanceInputUnit {
  String get shortLabel => switch (this) {
        DistanceInputUnit.meters => 'm',
        DistanceInputUnit.kilometers => 'km',
        DistanceInputUnit.feet => 'ft',
        DistanceInputUnit.miles => 'mi',
        DistanceInputUnit.yards => 'yd',
        DistanceInputUnit.nauticalMiles => 'nm',
      };
}

List<DistanceInputUnit> distanceInputUnitsFor(MeasurementUnits units) {
  return switch (units) {
    MeasurementUnits.metric => [
        DistanceInputUnit.meters,
        DistanceInputUnit.kilometers,
      ],
    MeasurementUnits.imperial => [
        DistanceInputUnit.feet,
        DistanceInputUnit.miles,
      ],
    MeasurementUnits.nautical => [
        DistanceInputUnit.yards,
        DistanceInputUnit.nauticalMiles,
      ],
  };
}

DistanceInputUnit defaultDistanceInputUnit(
  double meters,
  MeasurementUnits units,
) {
  return switch (units) {
    MeasurementUnits.metric =>
      meters >= 1000 ? DistanceInputUnit.kilometers : DistanceInputUnit.meters,
    MeasurementUnits.imperial => () {
        const metersPerFoot = 0.3048;
        const feetPerMile = 5280.0;
        final feet = meters / metersPerFoot;
        return feet >= feetPerMile
            ? DistanceInputUnit.miles
            : DistanceInputUnit.feet;
      }(),
    MeasurementUnits.nautical => () {
        const metersPerNauticalMile = 1852.0;
        if (meters >= metersPerNauticalMile * 0.1) {
          return DistanceInputUnit.nauticalMiles;
        }
        return DistanceInputUnit.yards;
      }(),
  };
}

double distanceInputValueToMeters(double value, DistanceInputUnit unit) {
  return switch (unit) {
    DistanceInputUnit.meters => value,
    DistanceInputUnit.kilometers => value * 1000,
    DistanceInputUnit.feet => value * 0.3048,
    DistanceInputUnit.miles => value * 1609.344,
    DistanceInputUnit.yards => value * 0.9144,
    DistanceInputUnit.nauticalMiles => value * 1852.0,
  };
}

double metersToDistanceInputValue(double meters, DistanceInputUnit unit) {
  return switch (unit) {
    DistanceInputUnit.meters => meters,
    DistanceInputUnit.kilometers => meters / 1000,
    DistanceInputUnit.feet => meters / 0.3048,
    DistanceInputUnit.miles => meters / 1609.344,
    DistanceInputUnit.yards => meters / 0.9144,
    DistanceInputUnit.nauticalMiles => meters / 1852.0,
  };
}

String formatDistanceInputFieldValue(double meters, DistanceInputUnit unit) {
  if (meters.isNaN || meters.isInfinite || meters < 0) {
    return '';
  }

  final value = metersToDistanceInputValue(meters, unit);
  return switch (unit) {
    DistanceInputUnit.meters => _formatDecimal(value, threshold: 100),
    DistanceInputUnit.kilometers => value.toStringAsFixed(3),
    DistanceInputUnit.feet => _formatDecimal(value, threshold: 100),
    DistanceInputUnit.miles => value.toStringAsFixed(3),
    DistanceInputUnit.yards => value.toStringAsFixed(0),
    DistanceInputUnit.nauticalMiles => value.toStringAsFixed(3),
  };
}

double? parseDistanceInputFieldValue(String raw, DistanceInputUnit unit) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  final value = double.tryParse(trimmed);
  if (value == null || value <= 0) {
    return null;
  }
  return distanceInputValueToMeters(value, unit);
}

String _formatDecimal(double value, {required double threshold}) {
  final precision = value < threshold ? 1 : 0;
  return value.toStringAsFixed(precision);
}
