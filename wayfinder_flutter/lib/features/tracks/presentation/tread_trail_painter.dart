import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/track_transportation_mode.dart';
import 'track_trail_geometry.dart';

class TreadTrailPath {
  const TreadTrailPath({
    required this.markers,
    required this.color,
    required this.kind,
  });

  final List<TrailPathMarker> markers;
  final Color color;
  final TreadTrailKind kind;
}

class TreadTrailPainter extends CustomPainter {
  const TreadTrailPainter({required this.paths});

  final List<TreadTrailPath> paths;

  @override
  void paint(Canvas canvas, Size size) {
    for (final path in paths) {
      _paintPath(canvas, path);
    }
  }

  void _paintPath(Canvas canvas, TreadTrailPath path) {
    final paint = Paint()
      ..color = path.color
      ..strokeWidth = switch (path.kind) {
        TreadTrailKind.tractor => 2.2,
        TreadTrailKind.atv => 1.8,
        _ => 1.4,
      }
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final marker in path.markers) {
      final perpendicular = marker.travelAngle + math.pi / 2;
      final forward = marker.travelAngle;
      final trackCount = switch (path.kind) {
        TreadTrailKind.single => 1,
        TreadTrailKind.bicycle => 2,
        TreadTrailKind.atv => 3,
        TreadTrailKind.tractor => 4,
      };
      final spacing = switch (path.kind) {
        TreadTrailKind.bicycle => 3.0,
        TreadTrailKind.single => 0.0,
        TreadTrailKind.atv => 2.5,
        TreadTrailKind.tractor => 2.0,
      };
      final halfWidth = (trackCount - 1) * spacing / 2;

      for (var track = 0; track < trackCount; track++) {
        final lateralOffset = -halfWidth + track * spacing;
        final base = marker.center +
            Offset(
              math.cos(perpendicular) * lateralOffset,
              math.sin(perpendicular) * lateralOffset,
            );
        final treadLength = switch (path.kind) {
          TreadTrailKind.tractor => 11.0,
          TreadTrailKind.atv => 9.0,
          _ => 7.0,
        };
        final start = base -
            Offset(
              math.cos(forward) * treadLength / 2,
              math.sin(forward) * treadLength / 2,
            );
        final end = base +
            Offset(
              math.cos(forward) * treadLength / 2,
              math.sin(forward) * treadLength / 2,
            );
        canvas.drawLine(start, end, paint);

        if (path.kind == TreadTrailKind.tractor || path.kind == TreadTrailKind.atv) {
          for (var notch = -1; notch <= 1; notch++) {
            final notchCenter = base +
                Offset(
                  math.cos(forward) * notch * 2.5,
                  math.sin(forward) * notch * 2.5,
                );
            canvas.drawLine(
              notchCenter +
                  Offset(
                    math.cos(perpendicular) * 1.5,
                    math.sin(perpendicular) * 1.5,
                  ),
              notchCenter -
                  Offset(
                    math.cos(perpendicular) * 1.5,
                    math.sin(perpendicular) * 1.5,
                  ),
              paint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant TreadTrailPainter oldDelegate) {
    return oldDelegate.paths != paths;
  }
}
