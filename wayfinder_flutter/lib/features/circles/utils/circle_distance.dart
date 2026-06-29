import '../../lines/models/measurement_units.dart';
import '../models/circle_size_display.dart';

String formatCircleSize(
  double radiusMeters,
  MeasurementUnits units,
  CircleSizeDisplay display,
) {
  if (display == CircleSizeDisplay.none) {
    return '—';
  }

  final meters = display == CircleSizeDisplay.diameter
      ? radiusMeters * 2
      : radiusMeters;
  return formatLineDistance(meters, units);
}

String? formatCircleSizeForMapLabel(
  double radiusMeters,
  MeasurementUnits units,
  CircleSizeDisplay display,
) {
  if (display == CircleSizeDisplay.none) {
    return null;
  }
  return formatCircleSize(radiusMeters, units, display);
}

String circleSizeLabel(CircleSizeDisplay display) {
  return display.label;
}

String formatCircleSizeFieldValue(
  double radiusMeters,
  MeasurementUnits units, {
  required bool asDiameter,
}) {
  final meters = asDiameter ? radiusMeters * 2 : radiusMeters;
  if (meters.isNaN || meters.isInfinite || meters < 0) {
    return '';
  }

  return switch (units) {
    MeasurementUnits.metric => _formatMetricFieldValue(meters),
    MeasurementUnits.imperial => _formatImperialFieldValue(meters),
    MeasurementUnits.nautical => _formatNauticalFieldValue(meters),
  };
}

double? parseCircleSizeFieldValue(
  String raw,
  MeasurementUnits units, {
  required bool asDiameter,
}) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  final value = double.tryParse(trimmed);
  if (value == null || value <= 0) {
    return null;
  }

  final meters = switch (units) {
    MeasurementUnits.metric => value,
    MeasurementUnits.imperial => value * 0.3048,
    MeasurementUnits.nautical => value * 1852.0,
  };
  final radiusMeters = asDiameter ? meters / 2 : meters;
  if (radiusMeters.isNaN || radiusMeters.isInfinite || radiusMeters < 1) {
    return null;
  }
  return radiusMeters;
}

String _formatMetricFieldValue(double meters) {
  final precision = meters < 100 ? 1 : 0;
  return meters.toStringAsFixed(precision);
}

String _formatImperialFieldValue(double meters) {
  const metersPerFoot = 0.3048;
  final feet = meters / metersPerFoot;
  final precision = feet < 100 ? 1 : 0;
  return feet.toStringAsFixed(precision);
}

String _formatNauticalFieldValue(double meters) {
  const metersPerNauticalMile = 1852.0;
  final nauticalMiles = meters / metersPerNauticalMile;
  return nauticalMiles.toStringAsFixed(3);
}
