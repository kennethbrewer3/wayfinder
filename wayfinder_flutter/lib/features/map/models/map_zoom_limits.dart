import '../../../core/constants.dart';

class MapZoomRange {
  const MapZoomRange({
    required this.min,
    required this.max,
  });

  final double min;
  final double max;

  static const defaults = MapZoomRange(
    min: AppConstants.defaultMapMinZoom,
    max: AppConstants.defaultMapMaxZoom,
  );

  MapZoomRange copyWith({
    double? min,
    double? max,
  }) {
    return MapZoomRange(
      min: min ?? this.min,
      max: max ?? this.max,
    );
  }
}

MapZoomRange normalizeMapZoomRange({
  double? min,
  double? max,
}) {
  final resolvedMin = clampMapMinZoom(
    min ?? AppConstants.defaultMapMinZoom,
  );
  final resolvedMax = clampMapMaxZoom(
    max ?? AppConstants.defaultMapMaxZoom,
  );
  return validateMapZoomRange(
    MapZoomRange(min: resolvedMin, max: resolvedMax),
  );
}

double clampMapMinZoom(double value) => value.clamp(
  AppConstants.absoluteMapMinZoom,
  AppConstants.absoluteMapMaxZoom - 1,
);

double clampMapMaxZoom(double value) => value.clamp(
  AppConstants.absoluteMapMinZoom + 1,
  AppConstants.absoluteMapMaxZoom,
);

MapZoomRange validateMapZoomRange(MapZoomRange range) {
  final min = clampMapMinZoom(range.min);
  var max = clampMapMaxZoom(range.max);
  if (min >= max) {
    max = (min + 1).clamp(
      AppConstants.absoluteMapMinZoom + 1,
      AppConstants.absoluteMapMaxZoom,
    );
  }
  if (min >= max) {
    throw FormatException(
      'Minimum zoom must be less than maximum zoom '
      '(${AppConstants.absoluteMapMinZoom}–${AppConstants.absoluteMapMaxZoom}).',
    );
  }
  return MapZoomRange(min: min, max: max);
}
