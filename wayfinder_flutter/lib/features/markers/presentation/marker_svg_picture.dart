import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_graphics/vector_graphics_compat.dart';

const _markerSvgCacheMaximumSize = 256;
bool _markerSvgCacheConfigured = false;

/// Tunes flutter_svg caching for the large built-in marker icon set.
void ensureMarkerSvgCacheConfigured() {
  if (_markerSvgCacheConfigured) {
    return;
  }
  _markerSvgCacheConfigured = true;
  svg.cache.maximumSize = _markerSvgCacheMaximumSize;
}

/// Renders marker SVGs with [RenderingStrategy.raster] so complex artwork is
/// rasterized once per size and reused across map markers and pickers.
Widget markerSvgAssetPicture({
  required String assetPath,
  double? width,
  double? height,
  ColorFilter? colorFilter,
  ColorMapper? colorMapper,
  BoxFit fit = BoxFit.contain,
  WidgetBuilder? placeholderBuilder,
  SvgErrorWidgetBuilder? errorBuilder,
  bool excludeFromSemantics = true,
}) {
  ensureMarkerSvgCacheConfigured();
  return SvgPicture.asset(
    assetPath,
    width: width,
    height: height,
    fit: fit,
    colorFilter: colorFilter,
    colorMapper: colorMapper,
    renderingStrategy: RenderingStrategy.raster,
    placeholderBuilder: placeholderBuilder,
    errorBuilder: errorBuilder,
    excludeFromSemantics: excludeFromSemantics,
  );
}

/// Network marker SVGs use the same raster strategy as bundled assets.
Widget markerSvgNetworkPicture({
  required String url,
  double? width,
  double? height,
  ColorFilter? colorFilter,
  BoxFit fit = BoxFit.contain,
  WidgetBuilder? placeholderBuilder,
  SvgErrorWidgetBuilder? errorBuilder,
  bool excludeFromSemantics = true,
}) {
  ensureMarkerSvgCacheConfigured();
  return SvgPicture.network(
    url,
    width: width,
    height: height,
    fit: fit,
    colorFilter: colorFilter,
    renderingStrategy: RenderingStrategy.raster,
    placeholderBuilder: placeholderBuilder,
    errorBuilder: errorBuilder,
    excludeFromSemantics: excludeFromSemantics,
  );
}
