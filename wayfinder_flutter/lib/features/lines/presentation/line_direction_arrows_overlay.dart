import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../markers/models/marker_color.dart';
import '../models/line_geometry.dart';
import '../utils/line_distance.dart';
import '../utils/line_path.dart';

const _arrowBoxSize = 24.0;
const _arrowIconSize = 18.0;
const _arrowSpacingMeters = 75.0;
const _minArrowSpacingPixels = 48.0;
const _maxArrowsPerLine = 16;

class _ArrowDraw {
  const _ArrowDraw({
    required this.screenPoint,
    required this.angle,
    required this.color,
  });

  final Offset screenPoint;
  final double angle;
  final Color color;
}

/// Renders direction arrows in screen space so they stay aligned with polylines.
class LineDirectionArrowsOverlay extends StatefulWidget {
  const LineDirectionArrowsOverlay({
    super.key,
    required this.zones,
    required this.mapController,
    this.geometryOverrides,
    this.previewStart,
    this.previewEnd,
    this.previewColor,
    this.bearingPreviewStart,
    this.bearingPreviewEnd,
    this.bearingPreviewColor,
  });

  final List<MapZone> zones;
  final MapController mapController;
  final Map<UuidValue, LineGeometry>? geometryOverrides;
  final LatLng? previewStart;
  final LatLng? previewEnd;
  final Color? previewColor;
  final LatLng? bearingPreviewStart;
  final LatLng? bearingPreviewEnd;
  final Color? bearingPreviewColor;

  @override
  State<LineDirectionArrowsOverlay> createState() =>
      _LineDirectionArrowsOverlayState();
}

class _LineDirectionArrowsOverlayState extends State<LineDirectionArrowsOverlay> {
  StreamSubscription<MapEvent>? _mapEvents;

  @override
  void initState() {
    super.initState();
    _mapEvents = widget.mapController.mapEventStream.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(covariant LineDirectionArrowsOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mapController != widget.mapController) {
      _mapEvents?.cancel();
      _mapEvents = widget.mapController.mapEventStream.listen((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _mapEvents?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final camera = widget.mapController.camera;
    final mapSize = camera.size;
    final arrows = <_ArrowDraw>[];

    for (final zone in widget.zones) {
      if (!zone.visible || zone.type != lineZoneType) {
        continue;
      }
      final geometry =
          widget.geometryOverrides?[zone.id] ?? LineGeometry.fromZone(zone);
      if (geometry == null || !geometry.isValid || !geometry.showArrows) {
        continue;
      }
      arrows.addAll(
        _arrowsForPath(
          camera: camera,
          mapSize: mapSize,
          renderPoints: geometry.renderPoints,
          color: parseMarkerColor(zone.color),
        ),
      );
    }

    if (widget.previewStart case final start?) {
      if (widget.previewEnd case final end?) {
        if (widget.previewColor case final color?) {
          arrows.addAll(
            _arrowsForPath(
              camera: camera,
              mapSize: mapSize,
              renderPoints: [start, end],
              color: color,
            ),
          );
        }
      }
    }

    if (widget.bearingPreviewStart case final start?) {
      if (widget.bearingPreviewEnd case final end?) {
        if (widget.bearingPreviewColor case final color?) {
          arrows.addAll(
            _arrowsForPath(
              camera: camera,
              mapSize: mapSize,
              renderPoints: [start, end],
              color: color,
            ),
          );
        }
      }
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final arrow in arrows)
          Positioned(
            left: arrow.screenPoint.dx - _arrowBoxSize / 2,
            top: arrow.screenPoint.dy - _arrowBoxSize / 2,
            width: _arrowBoxSize,
            height: _arrowBoxSize,
            child: Transform.rotate(
              angle: arrow.angle,
              child: Icon(
                Icons.arrow_forward,
                size: _arrowIconSize,
                color: arrow.color,
              ),
            ),
          ),
      ],
    );
  }
}

List<_ArrowDraw> _arrowsForPath({
  required MapCamera camera,
  required Size mapSize,
  required List<LatLng> renderPoints,
  required Color color,
}) {
  if (renderPoints.length < 2) {
    return const [];
  }

  final totalMeters = lineLengthMetersForPoints(renderPoints);
  if (totalMeters < 1) {
    return const [];
  }

  final projected = [
    for (final point in renderPoints) camera.latLngToScreenOffset(point),
  ];

  var totalPixels = 0.0;
  for (var index = 0; index < projected.length - 1; index++) {
    totalPixels += (projected[index + 1] - projected[index]).distance;
  }
  if (totalPixels < 1) {
    return const [];
  }

  final arrowCount = _arrowCountForPath(
    totalMeters: totalMeters,
    totalPixels: totalPixels,
  );
  final arrows = <_ArrowDraw>[];

  for (var index = 1; index <= arrowCount; index++) {
    final targetPixels = totalPixels * index / (arrowCount + 1);
    final placement = _pointOnProjectedPath(projected, targetPixels);
    if (placement == null) {
      continue;
    }

    if (!_isOnMap(placement.point, mapSize)) {
      continue;
    }

    arrows.add(
      _ArrowDraw(
        screenPoint: placement.point,
        angle: math.atan2(
          placement.segmentEnd.dy - placement.segmentStart.dy,
          placement.segmentEnd.dx - placement.segmentStart.dx,
        ),
        color: color,
      ),
    );
  }

  return arrows;
}

int _arrowCountForPath({
  required double totalMeters,
  required double totalPixels,
}) {
  var count = math.max(1, (totalMeters / _arrowSpacingMeters).round());
  final maxByPixels = math.max(1, (totalPixels / _minArrowSpacingPixels).floor());
  count = math.min(count, maxByPixels);
  return math.min(count, _maxArrowsPerLine);
}

class _ProjectedPlacement {
  const _ProjectedPlacement({
    required this.point,
    required this.segmentStart,
    required this.segmentEnd,
  });

  final Offset point;
  final Offset segmentStart;
  final Offset segmentEnd;
}

_ProjectedPlacement? _pointOnProjectedPath(
  List<Offset> projected,
  double targetPixels,
) {
  var accumulated = 0.0;

  for (var index = 0; index < projected.length - 1; index++) {
    final start = projected[index];
    final end = projected[index + 1];
    final segmentLength = (end - start).distance;
    if (accumulated + segmentLength >= targetPixels) {
      if (segmentLength < 0.5) {
        return _ProjectedPlacement(
          point: start,
          segmentStart: start,
          segmentEnd: end,
        );
      }

      final t = ((targetPixels - accumulated) / segmentLength).clamp(0.0, 1.0);
      return _ProjectedPlacement(
        point: Offset.lerp(start, end, t)!,
        segmentStart: start,
        segmentEnd: end,
      );
    }
    accumulated += segmentLength;
  }

  return null;
}

bool _isOnMap(Offset point, Size mapSize) {
  return point.dx >= 0 &&
      point.dy >= 0 &&
      point.dx <= mapSize.width &&
      point.dy <= mapSize.height;
}
