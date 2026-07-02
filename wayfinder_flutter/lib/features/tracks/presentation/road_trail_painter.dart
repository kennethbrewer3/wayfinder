import 'package:flutter/material.dart';

import '../models/track_transportation_mode.dart';
import 'track_trail_geometry.dart';

class RoadTrailPath {
  const RoadTrailPath({
    required this.centerline,
    required this.color,
    required this.kind,
  });

  final List<Offset> centerline;
  final Color color;
  final RoadTrailKind kind;
}

class RoadTrailPainter extends CustomPainter {
  const RoadTrailPainter({required this.paths});

  final List<RoadTrailPath> paths;

  @override
  void paint(Canvas canvas, Size size) {
    for (final path in paths) {
      _paintPath(canvas, path);
    }
  }

  void _paintPath(Canvas canvas, RoadTrailPath path) {
    if (path.centerline.length < 2) {
      return;
    }

    final edgeHalfWidth = switch (path.kind) {
      RoadTrailKind.wide => 6.0,
      RoadTrailKind.standard => 4.0,
    };
    final dashLength = switch (path.kind) {
      RoadTrailKind.wide => 10.0,
      RoadTrailKind.standard => 8.0,
    };

    final edgePaint = Paint()
      ..color = path.color.withValues(alpha: 0.35)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final leftEdge = trailOffsetPath(path.centerline, -edgeHalfWidth);
    final rightEdge = trailOffsetPath(path.centerline, edgeHalfWidth);
    trailDrawPolyline(canvas, edgePaint, leftEdge);
    trailDrawPolyline(canvas, edgePaint, rightEdge);

    final centerPaint = Paint()
      ..color = path.color.withValues(alpha: 0.9)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    trailDrawDashedPolyline(
      canvas,
      centerPaint,
      path.centerline,
      dashLength: dashLength,
      gapLength: dashLength * 0.75,
    );
  }

  @override
  bool shouldRepaint(covariant RoadTrailPainter oldDelegate) {
    return oldDelegate.paths != paths;
  }
}
