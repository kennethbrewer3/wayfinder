import '../presentation/map_marker_layout.dart';

/// User preference scale for on-map marker pin size (1.0 = default 44 px).
const mapMarkerSizeScaleDefault = 1.0;
const mapMarkerSizeScaleMin = 0.75;
const mapMarkerSizeScaleMax = 1.75;

double clampMapMarkerSizeScale(double scale) =>
    scale.clamp(mapMarkerSizeScaleMin, mapMarkerSizeScaleMax);

double mapMarkerRenderWidth(double scale) =>
    mapMarkerWidth * clampMapMarkerSizeScale(scale);

double mapMarkerRenderHeight(double scale) =>
    mapMarkerHeight * clampMapMarkerSizeScale(scale);

int mapMarkerSizeScalePercent(double scale) =>
    (clampMapMarkerSizeScale(scale) * 100).round();
