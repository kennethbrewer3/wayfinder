import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:vector_graphics/vector_graphics_compat.dart';

import 'marker_raster_svg.dart';

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

enum _MarkerSvgKind { loading, rasterPng, vectorSvg }

/// Renders marker SVGs with [RenderingStrategy.raster] so complex artwork is
/// rasterized once per size and reused across map markers and pickers.
///
/// SVG wrappers that only embed a PNG (from asset optimization) are rendered
/// directly with [Image.memory] because the vector-graphics raster path does
/// not reliably paint embedded bitmaps.
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
  return _MarkerSvgAssetPicture(
    assetPath: assetPath,
    width: width,
    height: height,
    fit: fit,
    colorFilter: colorFilter,
    colorMapper: colorMapper,
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
  return _MarkerSvgNetworkPicture(
    url: url,
    width: width,
    height: height,
    fit: fit,
    colorFilter: colorFilter,
    placeholderBuilder: placeholderBuilder,
    errorBuilder: errorBuilder,
    excludeFromSemantics: excludeFromSemantics,
  );
}

final _assetRasterPngCache = <String, Uint8List?>{};
final _assetResolveFutures = <String, Future<_MarkerSvgKind>>{};
final _networkRasterPngCache = <String, Uint8List?>{};
final _networkResolveFutures = <String, Future<_MarkerSvgKind>>{};

Future<_MarkerSvgKind> _resolveAssetMarkerSvg(String assetPath) {
  return _assetResolveFutures.putIfAbsent(assetPath, () async {
    if (_assetRasterPngCache.containsKey(assetPath)) {
      final cached = _assetRasterPngCache[assetPath];
      return cached == null
          ? _MarkerSvgKind.vectorSvg
          : _MarkerSvgKind.rasterPng;
    }

    final data = await rootBundle.load(assetPath);
    final svgBytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    final pngBytes = extractPngFromRasterSvg(svgBytes);
    _assetRasterPngCache[assetPath] = pngBytes;
    return pngBytes == null
        ? _MarkerSvgKind.vectorSvg
        : _MarkerSvgKind.rasterPng;
  });
}

Future<_MarkerSvgKind> _resolveNetworkMarkerSvg(String url) {
  return _networkResolveFutures.putIfAbsent(url, () async {
    if (_networkRasterPngCache.containsKey(url)) {
      final cached = _networkRasterPngCache[url];
      return cached == null
          ? _MarkerSvgKind.vectorSvg
          : _MarkerSvgKind.rasterPng;
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw StateError('Failed to load marker SVG from $url');
    }
    final pngBytes = extractPngFromRasterSvg(response.bodyBytes);
    _networkRasterPngCache[url] = pngBytes;
    return pngBytes == null
        ? _MarkerSvgKind.vectorSvg
        : _MarkerSvgKind.rasterPng;
  });
}

Widget _wrapWithColorFilter({
  required Widget child,
  ColorFilter? colorFilter,
}) {
  if (colorFilter == null) {
    return child;
  }
  return ColorFiltered(colorFilter: colorFilter, child: child);
}

class _MarkerSvgAssetPicture extends StatefulWidget {
  const _MarkerSvgAssetPicture({
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.colorFilter,
    this.colorMapper,
    this.placeholderBuilder,
    this.errorBuilder,
    this.excludeFromSemantics = true,
  });

  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final ColorFilter? colorFilter;
  final ColorMapper? colorMapper;
  final WidgetBuilder? placeholderBuilder;
  final SvgErrorWidgetBuilder? errorBuilder;
  final bool excludeFromSemantics;

  @override
  State<_MarkerSvgAssetPicture> createState() =>
      _MarkerSvgAssetPictureState();
}

class _MarkerSvgAssetPictureState extends State<_MarkerSvgAssetPicture> {
  late Future<_MarkerSvgKind> _resolveFuture;

  @override
  void initState() {
    super.initState();
    _resolveFuture = _resolveAssetMarkerSvg(widget.assetPath);
  }

  @override
  void didUpdateWidget(covariant _MarkerSvgAssetPicture oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath) {
      _resolveFuture = _resolveAssetMarkerSvg(widget.assetPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_MarkerSvgKind>(
      future: _resolveFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return widget.errorBuilder?.call(
                context,
                snapshot.error!,
                snapshot.stackTrace ?? StackTrace.empty,
              ) ??
              SizedBox(width: widget.width, height: widget.height);
        }

        final kind = snapshot.data;
        if (kind == null || kind == _MarkerSvgKind.loading) {
          return widget.placeholderBuilder?.call(context) ??
              SizedBox(width: widget.width, height: widget.height);
        }

        if (kind == _MarkerSvgKind.rasterPng) {
          final pngBytes = _assetRasterPngCache[widget.assetPath];
          if (pngBytes == null) {
            return widget.placeholderBuilder?.call(context) ??
                SizedBox(width: widget.width, height: widget.height);
          }
          return _wrapWithColorFilter(
            colorFilter: widget.colorFilter,
            child: Image.memory(
              pngBytes,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              excludeFromSemantics: widget.excludeFromSemantics,
              errorBuilder: (context, error, stackTrace) {
                return widget.errorBuilder?.call(
                      context,
                      error,
                      stackTrace ?? StackTrace.empty,
                    ) ??
                    SizedBox(width: widget.width, height: widget.height);
              },
            ),
          );
        }

        return SvgPicture.asset(
          widget.assetPath,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          colorFilter: widget.colorFilter,
          colorMapper: widget.colorMapper,
          renderingStrategy: RenderingStrategy.raster,
          placeholderBuilder: widget.placeholderBuilder,
          errorBuilder: widget.errorBuilder,
          excludeFromSemantics: widget.excludeFromSemantics,
        );
      },
    );
  }
}

class _MarkerSvgNetworkPicture extends StatefulWidget {
  const _MarkerSvgNetworkPicture({
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.colorFilter,
    this.placeholderBuilder,
    this.errorBuilder,
    this.excludeFromSemantics = true,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final ColorFilter? colorFilter;
  final WidgetBuilder? placeholderBuilder;
  final SvgErrorWidgetBuilder? errorBuilder;
  final bool excludeFromSemantics;

  @override
  State<_MarkerSvgNetworkPicture> createState() =>
      _MarkerSvgNetworkPictureState();
}

class _MarkerSvgNetworkPictureState extends State<_MarkerSvgNetworkPicture> {
  late Future<_MarkerSvgKind> _resolveFuture;

  @override
  void initState() {
    super.initState();
    _resolveFuture = _resolveNetworkMarkerSvg(widget.url);
  }

  @override
  void didUpdateWidget(covariant _MarkerSvgNetworkPicture oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _resolveFuture = _resolveNetworkMarkerSvg(widget.url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_MarkerSvgKind>(
      future: _resolveFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return widget.errorBuilder?.call(
                context,
                snapshot.error!,
                snapshot.stackTrace ?? StackTrace.empty,
              ) ??
              SizedBox(width: widget.width, height: widget.height);
        }

        final kind = snapshot.data;
        if (kind == null || kind == _MarkerSvgKind.loading) {
          return widget.placeholderBuilder?.call(context) ??
              SizedBox(width: widget.width, height: widget.height);
        }

        if (kind == _MarkerSvgKind.rasterPng) {
          final pngBytes = _networkRasterPngCache[widget.url];
          if (pngBytes == null) {
            return widget.placeholderBuilder?.call(context) ??
                SizedBox(width: widget.width, height: widget.height);
          }
          return _wrapWithColorFilter(
            colorFilter: widget.colorFilter,
            child: Image.memory(
              pngBytes,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              excludeFromSemantics: widget.excludeFromSemantics,
              errorBuilder: (context, error, stackTrace) {
                return widget.errorBuilder?.call(
                      context,
                      error,
                      stackTrace ?? StackTrace.empty,
                    ) ??
                    SizedBox(width: widget.width, height: widget.height);
              },
            ),
          );
        }

        return SvgPicture.network(
          widget.url,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          colorFilter: widget.colorFilter,
          renderingStrategy: RenderingStrategy.raster,
          placeholderBuilder: widget.placeholderBuilder,
          errorBuilder: widget.errorBuilder,
          excludeFromSemantics: widget.excludeFromSemantics,
        );
      },
    );
  }
}
