import 'package:flutter/material.dart';

import 'track_trail_geometry.dart';

class BalloonTrailPath {
  const BalloonTrailPath({
    required this.centerline,
    required this.color,
  });

  final List<Offset> centerline;
  final Color color;
}

class BalloonTrailPainter extends CustomPainter {
  const BalloonTrailPainter({required this.paths});

  final List<BalloonTrailPath> paths;

  @override
  void paint(Canvas canvas, Size size) {
    for (final path in paths) {
      _paintPath(canvas, path);
    }
  }

  void _paintPath(Canvas canvas, BalloonTrailPath path) {
    if (path.centerline.length < 2) {
      return;
    }

    final wavy = trailWavyPath(
      path.centerline,
      amplitude: 3.5,
      wavelength: 18,
    );

    final paint = Paint()
      ..color = path.color.withValues(alpha: 0.65)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    trailDrawDashedPolyline(
      canvas,
      paint,
      wavy,
      dashLength: 2.5,
      gapLength: 4.5,
    );
  }

  @override
  bool shouldRepaint(covariant BalloonTrailPainter oldDelegate) {
    return oldDelegate.paths != paths;
  }
}
