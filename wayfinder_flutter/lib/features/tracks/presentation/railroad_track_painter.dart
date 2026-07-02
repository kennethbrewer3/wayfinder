import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'track_trail_geometry.dart';

const _tieHalfLength = 7.0;
const _tieStrokeWidth = 2.0;
const _railHalfGap = 3.5;
const _railStrokeWidth = 1.4;

class RailroadTrackPath {
  const RailroadTrackPath({
    required this.centerline,
    required this.ties,
    required this.color,
  });

  final List<Offset> centerline;
  final List<TrailPathMarker> ties;
  final Color color;
}

class RailroadTrackPainter extends CustomPainter {
  const RailroadTrackPainter({required this.paths});

  final List<RailroadTrackPath> paths;

  @override
  void paint(Canvas canvas, Size size) {
    for (final path in paths) {
      _paintPath(canvas, path);
    }
  }

  void _paintPath(Canvas canvas, RailroadTrackPath path) {
    if (path.centerline.length < 2) {
      return;
    }

    final railPaint = Paint()
      ..color = path.color
      ..strokeWidth = _railStrokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final tiePaint = Paint()
      ..color = path.color.withValues(alpha: 0.85)
      ..strokeWidth = _tieStrokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final leftRail = trailOffsetPath(path.centerline, -_railHalfGap);
    final rightRail = trailOffsetPath(path.centerline, _railHalfGap);
    trailDrawPolyline(canvas, railPaint, leftRail);
    trailDrawPolyline(canvas, railPaint, rightRail);

    for (final tie in path.ties) {
      final perpendicular = tie.travelAngle + math.pi / 2;
      final dx = math.cos(perpendicular);
      final dy = math.sin(perpendicular);
      canvas.drawLine(
        tie.center + Offset(dx, dy) * _tieHalfLength,
        tie.center - Offset(dx, dy) * _tieHalfLength,
        tiePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RailroadTrackPainter oldDelegate) {
    return oldDelegate.paths != paths;
  }
}
