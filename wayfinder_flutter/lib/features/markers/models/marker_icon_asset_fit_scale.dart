import 'marker_icon_asset_fit_scales.g.dart';

/// Fit scale for bundled marker SVG artwork in the circular map glyph slot.
double bundledMarkerIconAssetFitScale(String iconName) {
  return markerIconAssetFitScales[iconName] ?? markerIconDefaultAssetFitScale;
}

/// Combined display scale for a marker icon glyph.
double markerIconDisplayScale({
  required String iconName,
  required double glyphScale,
}) {
  return glyphScale * bundledMarkerIconAssetFitScale(iconName);
}
