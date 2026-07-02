import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../markers/models/marker_color.dart';
import '../models/track_geometry.dart';
import '../models/track_transportation_mode.dart';
import 'balloon_trail_painter.dart';
import 'flight_trail_painter.dart';
import 'footprint_trail_painter.dart';
import 'railroad_track_painter.dart';
import 'road_trail_painter.dart';
import 'track_trail_projection.dart';
import 'tread_trail_painter.dart';
import 'wake_trail_painter.dart';

/// Renders styled transportation trails in screen space along tracking paths.
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
    final batch = _TrailRenderBatch();

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

      batch.add(
        mode: geometry.transportationMode,
        color: parseMarkerColor(zone.color),
        projection: projectStyledTrail(
          camera: camera,
          mapSize: mapSize,
          renderPoints: geometry.pathPoints,
          density: geometry.footstepDensity,
          includeMarkers: _usesMarkers(geometry.transportationMode.trailStyle),
        ),
      );
    }

    if (!batch.hasContent) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _StyledTrailPainter(batch: batch),
        ),
      ),
    );
  }

  bool _usesMarkers(TrackTrailStyle style) {
    return switch (style) {
      TrackTrailStyle.road || TrackTrailStyle.balloon => false,
      _ => true,
    };
  }
}

class _TrailRenderBatch {
  final footprintPaths = <FootprintTrailPath>[];
  final treadPaths = <TreadTrailPath>[];
  final roadPaths = <RoadTrailPath>[];
  final railroadPaths = <RailroadTrackPath>[];
  final wakePaths = <WakeTrailPath>[];
  final flightPaths = <FlightTrailPath>[];
  final balloonPaths = <BalloonTrailPath>[];

  bool get hasContent =>
      footprintPaths.isNotEmpty ||
      treadPaths.isNotEmpty ||
      roadPaths.isNotEmpty ||
      railroadPaths.isNotEmpty ||
      wakePaths.isNotEmpty ||
      flightPaths.isNotEmpty ||
      balloonPaths.isNotEmpty;

  void add({
    required TrackTransportationMode mode,
    required Color color,
    required StyledTrailProjection? projection,
  }) {
    if (projection == null) {
      return;
    }

    switch (mode.trailStyle) {
      case TrackTrailStyle.footprints:
        footprintPaths.add(
          FootprintTrailPath(
            markers: projection.markers,
            color: color,
            kind: mode.footprintKind,
          ),
        );
      case TrackTrailStyle.tread:
        treadPaths.add(
          TreadTrailPath(
            markers: projection.markers,
            color: color,
            kind: mode.treadKind,
          ),
        );
      case TrackTrailStyle.road:
        roadPaths.add(
          RoadTrailPath(
            centerline: projection.projected,
            color: color,
            kind: mode.roadKind,
          ),
        );
      case TrackTrailStyle.railroad:
        railroadPaths.add(
          RailroadTrackPath(
            centerline: projection.projected,
            ties: projection.markers,
            color: color,
          ),
        );
      case TrackTrailStyle.wake:
        wakePaths.add(
          WakeTrailPath(
            centerline: projection.projected,
            chevrons: projection.markers,
            color: color,
            intensity: mode.wakeIntensity,
          ),
        );
      case TrackTrailStyle.flight:
        flightPaths.add(
          FlightTrailPath(
            centerline: projection.projected,
            markers: projection.markers,
            color: color,
            kind: mode.flightKind,
          ),
        );
      case TrackTrailStyle.balloon:
        balloonPaths.add(
          BalloonTrailPath(
            centerline: projection.projected,
            color: color,
          ),
        );
    }
  }
}

class _StyledTrailPainter extends CustomPainter {
  const _StyledTrailPainter({required this.batch});

  final _TrailRenderBatch batch;

  @override
  void paint(Canvas canvas, Size size) {
    FootprintTrailPainter(paths: batch.footprintPaths).paint(canvas, size);
    TreadTrailPainter(paths: batch.treadPaths).paint(canvas, size);
    RoadTrailPainter(paths: batch.roadPaths).paint(canvas, size);
    RailroadTrackPainter(paths: batch.railroadPaths).paint(canvas, size);
    WakeTrailPainter(paths: batch.wakePaths).paint(canvas, size);
    FlightTrailPainter(paths: batch.flightPaths).paint(canvas, size);
    BalloonTrailPainter(paths: batch.balloonPaths).paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant _StyledTrailPainter oldDelegate) {
    return oldDelegate.batch != batch;
  }
}
