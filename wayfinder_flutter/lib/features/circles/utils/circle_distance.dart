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
