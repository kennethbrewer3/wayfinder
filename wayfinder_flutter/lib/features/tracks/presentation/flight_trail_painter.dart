import 'package:flutter/material.dart';

import '../models/track_transportation_mode.dart';
import 'track_trail_geometry.dart';

class FlightTrailPath {
  const FlightTrailPath({
    required this.centerline,
    required this.markers,
    required this.color,
    required this.kind,
  });

  final List<Offset> centerline;
  final List<TrailPathMarker> markers;
  final Color color;
  final FlightTrailKind kind;
}

class FlightTrailPainter extends CustomPainter {
  const FlightTrailPainter({required this.paths});

  final List<FlightTrailPath> paths;

  @override
  void paint(Canvas canvas, Size size) {
    for (final path in paths) {
      _paintPath(canvas, path);
    }
  }

  void _paintPath(Canvas canvas, FlightTrailPath path) {
    if (path.centerline.length < 2) {
      return;
    }

    switch (path.kind) {
      case FlightTrailKind.glider:
        final paint = Paint()
          ..color = path.color.withValues(alpha: 0.75)
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
        trailDrawPolyline(canvas, paint, path.centerline);
      case FlightTrailKind.aircraft:
        final paint = Paint()
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
        trailDrawTaperedPolyline(canvas, paint, path.centerline, path.color);
        trailDrawDashedPolyline(
          canvas,
          paint..color = path.color.withValues(alpha: 0.55),
          path.centerline,
          dashLength: 6,
          gapLength: 5,
        );
      case FlightTrailKind.helicopter:
        final linePaint = Paint()
          ..strokeWidth = 1.3
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
        trailDrawDashedPolyline(
          canvas,
          linePaint..color = path.color.withValues(alpha: 0.7),
          path.centerline,
          dashLength: 4,
          gapLength: 4,
        );
        final ringPaint = Paint()
          ..color = path.color.withValues(alpha: 0.45)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;
        for (final marker in path.markers) {
          canvas.drawCircle(marker.center, 4.5, ringPaint);
        }
    }
  }

  @override
  bool shouldRepaint(covariant FlightTrailPainter oldDelegate) {
    return oldDelegate.paths != paths;
  }
}
