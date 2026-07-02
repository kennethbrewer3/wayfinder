import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/track_transportation_mode.dart';
import 'track_trail_geometry.dart';

const _wakeEdgeStrokeWidth = 1.2;
const _chevronStrokeWidth = 1.4;
const _chevronSpreadRadians = 0.55;

class WakeTrailPath {
  const WakeTrailPath({
    required this.centerline,
    required this.chevrons,
    required this.color,
    required this.intensity,
  });

  final List<Offset> centerline;
  final List<TrailPathMarker> chevrons;
  final Color color;
  final WakeTrailIntensity intensity;
}

class WakeTrailPainter extends CustomPainter {
  const WakeTrailPainter({required this.paths});

  final List<WakeTrailPath> paths;

  @override
  void paint(Canvas canvas, Size size) {
    for (final path in paths) {
      _paintPath(canvas, path);
    }
  }

  void _paintPath(Canvas canvas, WakeTrailPath path) {
    if (path.centerline.length < 2) {
      return;
    }

    final maxHalfWidth = switch (path.intensity) {
      WakeTrailIntensity.light => 5.0,
      WakeTrailIntensity.normal => 8.0,
      WakeTrailIntensity.wide => 11.0,
    };
    final chevronLength = switch (path.intensity) {
      WakeTrailIntensity.light => 8.0,
      WakeTrailIntensity.normal => 10.0,
      WakeTrailIntensity.wide => 12.0,
    };

    final edgePaint = Paint()
      ..strokeWidth = _wakeEdgeStrokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final leftEdge = trailTaperedOffsetPath(path.centerline, -maxHalfWidth);
    final rightEdge = trailTaperedOffsetPath(path.centerline, maxHalfWidth);
    trailDrawTaperedPolyline(canvas, edgePaint, leftEdge, path.color);
    trailDrawTaperedPolyline(canvas, edgePaint, rightEdge, path.color);

    final chevronPaint = Paint()
      ..color = path.color.withValues(alpha: 0.9)
      ..strokeWidth = _chevronStrokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final chevron in path.chevrons) {
      final backward = chevron.travelAngle + math.pi;
      final leftLeg = backward - _chevronSpreadRadians;
      final rightLeg = backward + _chevronSpreadRadians;
      final leftEnd = chevron.center +
          Offset(
            math.cos(leftLeg) * chevronLength,
            math.sin(leftLeg) * chevronLength,
          );
      final rightEnd = chevron.center +
          Offset(
            math.cos(rightLeg) * chevronLength,
            math.sin(rightLeg) * chevronLength,
          );
      canvas.drawLine(chevron.center, leftEnd, chevronPaint);
      canvas.drawLine(chevron.center, rightEnd, chevronPaint);
    }
  }

  @override
  bool shouldRepaint(covariant WakeTrailPainter oldDelegate) {
    return oldDelegate.paths != paths;
  }
}
