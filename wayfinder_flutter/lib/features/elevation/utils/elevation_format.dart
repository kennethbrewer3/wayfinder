import '../../lines/models/measurement_units.dart';

/// Formats a height in meters using the user's measurement preference.
String formatElevationMeters(double meters, MeasurementUnits units) {
  if (meters.isNaN || meters.isInfinite) {
    return '—';
  }
  return switch (units) {
    MeasurementUnits.metric => '${meters.round()} m',
    MeasurementUnits.imperial ||
    MeasurementUnits.nautical => '${(meters / 0.3048).round()} ft',
  };
}

/// Signed climb/loss relative to a reference point.
String formatElevationDeltaMeters(double deltaMeters, MeasurementUnits units) {
  if (deltaMeters.isNaN || deltaMeters.isInfinite) {
    return '—';
  }
  final abs = formatElevationMeters(deltaMeters.abs(), units);
  if (deltaMeters > 0.5) {
    return '+$abs';
  }
  if (deltaMeters < -0.5) {
    return '-${formatElevationMeters(-deltaMeters, units)}';
  }
  return formatElevationMeters(0, units);
}
