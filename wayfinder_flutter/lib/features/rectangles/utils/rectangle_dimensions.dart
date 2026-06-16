import 'package:latlong2/latlong.dart';

import '../../lines/models/measurement_units.dart';
import '../../lines/utils/line_distance.dart';
import '../models/rectangle_size_display.dart';
import 'rectangle_bounds.dart';

(double widthMeters, double heightMeters) rectangleDimensionsMeters(
  RectangleBounds bounds,
) {
  final nw = LatLng(bounds.north, bounds.west);
  final ne = LatLng(bounds.north, bounds.east);
  final sw = LatLng(bounds.south, bounds.west);
  return (
    lineLengthMeters(nw, ne),
    lineLengthMeters(nw, sw),
  );
}

double rectangleAreaMeters(RectangleBounds bounds) {
  final (width, height) = rectangleDimensionsMeters(bounds);
  return width * height;
}

String formatRectangleDimensions(
  RectangleBounds bounds,
  MeasurementUnits units,
) {
  final (width, height) = rectangleDimensionsMeters(bounds);
  return '${formatLineDistance(width, units)} × ${formatLineDistance(height, units)}';
}

String formatRectangleArea(
  RectangleBounds bounds,
  MeasurementUnits units,
) {
  return formatArea(rectangleAreaMeters(bounds), units);
}

String? formatRectangleSizeForMapLabel(
  RectangleBounds bounds,
  MeasurementUnits units,
  RectangleSizeDisplay display,
) {
  return switch (display) {
    RectangleSizeDisplay.none => null,
    RectangleSizeDisplay.dimensions =>
      formatRectangleDimensions(bounds, units),
    RectangleSizeDisplay.area => formatRectangleArea(bounds, units),
  };
}
