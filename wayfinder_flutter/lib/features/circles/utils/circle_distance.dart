import '../models/circle_size_display.dart';
import '../../lines/models/distance_input_unit.dart';
import '../../lines/models/measurement_units.dart';

export '../../lines/models/distance_input_unit.dart'
    show
        DistanceInputUnit,
        defaultDistanceInputUnit,
        distanceInputUnitsFor;

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
  double radiusMeters, {
  required DistanceInputUnit unit,
  required bool asDiameter,
}) {
  final meters = asDiameter ? radiusMeters * 2 : radiusMeters;
  return formatDistanceInputFieldValue(meters, unit);
}

double? parseCircleSizeFieldValue(
  String raw, {
  required DistanceInputUnit unit,
  required bool asDiameter,
}) {
  final meters = parseDistanceInputFieldValue(raw, unit);
  if (meters == null) {
    return null;
  }

  final radiusMeters = asDiameter ? meters / 2 : meters;
  if (radiusMeters.isNaN || radiusMeters.isInfinite || radiusMeters < 1) {
    return null;
  }
  return radiusMeters;
}
