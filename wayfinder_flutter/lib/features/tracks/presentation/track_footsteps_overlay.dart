import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../lines/models/line_arrow_density.dart';
import '../../lines/utils/line_distance.dart';
import '../../markers/models/marker_color.dart';
import '../models/track_geometry.dart';
import '../models/track_transportation_mode.dart';

const _footstepBoxSize = 24.0;
const _footstepIconSize = 18.0;

class _FootstepDraw {
  const _FootstepDraw({
    required this.screenPoint,
    required this.angle,
    required this.color,
    required this.icon,
  });

  final Offset screenPoint;
  final double angle;
  final Color color;
  final IconData icon;
}

/// Renders footstep icons in screen space along tracking marker paths.
class TrackFootstepsOverlay extends StatefulWidget {
  const TrackFootstepsOverlay({
    super.key,
    required this.zones,
    required this.mapController,
  });

  final List<MapZone> zones;
  final MapController mapController;

  @override
  State<TrackFootstepsOverlay> createState() => _TrackFootstepsOverlayState();
}

class _TrackFootstepsOverlayState extends State<TrackFootstepsOverlay> {
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
  void didUpdateWidget(covariant TrackFootstepsOverlay oldWidget) {
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
    final footsteps = <_FootstepDraw>[];

    for (final zone in widget.zones) {
      if (!zone.visible || zone.type != trackZoneType) {
        continue;
      }
      final geometry = TrackGeometry.fromZone(zone);
      if (geometry == null ||
          !geometry.hasRenderablePath ||
          !geometry.showFootsteps) {
        continue;
      }
      footsteps.addAll(
        _footstepsForPath(
          camera: camera,
          mapSize: mapSize,
          renderPoints: geometry.pathPoints,
          color: parseMarkerColor(zone.color),
          density: geometry.footstepDensity,
          icon: trackTransportationIcon(geometry.transportationMode),
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final footstep in footsteps)
          Positioned(
            left: footstep.screenPoint.dx - _footstepBoxSize / 2,
            top: footstep.screenPoint.dy - _footstepBoxSize / 2,
            width: _footstepBoxSize,
            height: _footstepBoxSize,
            child: Transform.rotate(
              angle: footstep.angle,
              child: Icon(
                footstep.icon,
                size: _footstepIconSize,
                color: footstep.color,
              ),
            ),
          ),
      ],
    );
  }
}

List<_FootstepDraw> _footstepsForPath({
  required MapCamera camera,
  required Size mapSize,
  required List<LatLng> renderPoints,
  required Color color,
  required LineArrowDensity density,
  required IconData icon,
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

  final footstepCount = density.arrowCountForPath(
    totalMeters: totalMeters,
    totalPixels: totalPixels,
  );
  final footsteps = <_FootstepDraw>[];

  for (var index = 1; index <= footstepCount; index++) {
    final targetPixels = totalPixels * index / (footstepCount + 1);
    final placement = _pointOnProjectedPath(projected, targetPixels);
    if (placement == null) {
      continue;
    }

    if (!_isOnMap(placement.point, mapSize)) {
      continue;
    }

    footsteps.add(
      _FootstepDraw(
        screenPoint: placement.point,
        angle: math.atan2(
          placement.segmentEnd.dy - placement.segmentStart.dy,
          placement.segmentEnd.dx - placement.segmentStart.dx,
        ),
        color: color,
        icon: icon,
      ),
    );
  }

  return footsteps;
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
