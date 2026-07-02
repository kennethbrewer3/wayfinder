import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/track_transportation_mode.dart';
import 'track_trail_geometry.dart';

class FootprintTrailPath {
  const FootprintTrailPath({
    required this.markers,
    required this.color,
    required this.kind,
  });

  final List<TrailPathMarker> markers;
  final Color color;
  final FootprintTrailKind kind;
}

class FootprintTrailPainter extends CustomPainter {
  const FootprintTrailPainter({required this.paths});

  final List<FootprintTrailPath> paths;

  @override
  void paint(Canvas canvas, Size size) {
    for (final path in paths) {
      _paintPath(canvas, path);
    }
  }

  void _paintPath(Canvas canvas, FootprintTrailPath path) {
    final paint = Paint()
      ..color = path.color
      ..style = PaintingStyle.fill;

    for (final marker in path.markers) {
      final side = marker.index.isEven ? -1.0 : 1.0;
      final lateral = marker.travelAngle + math.pi / 2;
      final offset = Offset(
        math.cos(lateral) * 4.5 * side,
        math.sin(lateral) * 4.5 * side,
      );
      final center = marker.center + offset;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(marker.travelAngle + math.pi / 2);
      if (path.kind == FootprintTrailKind.hoof) {
        _drawHoof(canvas, paint);
      } else {
        _drawFootprint(canvas, paint);
      }
      canvas.restore();
    }
  }

  void _drawFootprint(Canvas canvas, Paint paint) {
    canvas.drawOval(const Rect.fromLTWH(-3.5, -5, 7, 9), paint);
    for (var toe = -2; toe <= 2; toe++) {
      canvas.drawCircle(Offset(toe * 1.4, -5.5), 0.9, paint);
    }
  }

  void _drawHoof(Canvas canvas, Paint paint) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-3.5, -4.5, 7, 8),
        const Radius.circular(3),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-2.5, 2, 5, 2),
        const Radius.circular(1),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant FootprintTrailPainter oldDelegate) {
    return oldDelegate.paths != paths;
  }
}
