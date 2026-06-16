import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../utils/bearing_utils.dart';

const _roseSize = 152.0;
const _roseRadius = 62.0;

class BearingPlotOverlay extends StatelessWidget {
  const BearingPlotOverlay({
    super.key,
    required this.anchor,
    required this.referenceBearing,
    required this.plotBearing,
    required this.mapController,
  });

  final LatLng anchor;
  final double referenceBearing;
  final double? plotBearing;
  final MapController mapController;

  @override
  Widget build(BuildContext context) {
    final camera = mapController.camera;
    final mapSize = camera.size;
    final anchorScreen = camera.latLngToScreenOffset(anchor);
    const half = _roseSize / 2;

    final left = anchorScreen.dx - half;
    final top = anchorScreen.dy - half;
    if (left > mapSize.width ||
        top > mapSize.height ||
        left + _roseSize < 0 ||
        top + _roseSize < 0) {
      return const SizedBox.shrink();
    }

    final northAngle = northScreenAngle(anchor: anchor, camera: camera);

    return Positioned(
      left: left,
      top: top,
      width: _roseSize,
      height: _roseSize,
      child: IgnorePointer(
        child: CustomPaint(
          painter: CompassRosePainter(
            northAngle: northAngle,
            referenceBearing: referenceBearing,
            plotBearing: plotBearing,
          ),
        ),
      ),
    );
  }
}

class CompassRosePainter extends CustomPainter {
  CompassRosePainter({
    required this.northAngle,
    required this.referenceBearing,
    this.plotBearing,
  });

  final double northAngle;
  final double referenceBearing;
  final double? plotBearing;

  Offset _directionFromTrueBearing(double bearing, double length) {
    final angle = northAngle + (bearing * math.pi / 180) - (math.pi / 2);
    return Offset.fromDirection(angle, length);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final fillPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.88)
      ..style = PaintingStyle.fill;
    final ringPaint = Paint()
      ..color = const Color(0xFF1B4965)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final tickPaint = Paint()
      ..color = const Color(0xFF415A77)
      ..strokeWidth = 1;

    canvas.drawCircle(center, _roseRadius + 8, fillPaint);
    canvas.drawCircle(center, _roseRadius + 8, ringPaint);
    canvas.drawCircle(center, _roseRadius, ringPaint);

    for (var bearing = 0; bearing < 360; bearing += 30) {
      final outer = center + _directionFromTrueBearing(bearing.toDouble(), _roseRadius + 6);
      final inner = center + _directionFromTrueBearing(bearing.toDouble(), _roseRadius - 8);
      canvas.drawLine(inner, outer, tickPaint);
    }

    _drawCardinal(canvas, center, 'N', 0, const Color(0xFF9B2226));
    _drawCardinal(canvas, center, 'E', 90, const Color(0xFF1B4965));
    _drawCardinal(canvas, center, 'S', 180, const Color(0xFF1B4965));
    _drawCardinal(canvas, center, 'W', 270, const Color(0xFF1B4965));

    _drawBearingRay(
      canvas,
      center,
      referenceBearing,
      const Color(0xFF1B4965),
      _roseRadius - 4,
      3,
    );

    final plot = plotBearing;
    if (plot != null) {
      _drawBearingRay(
        canvas,
        center,
        plot,
        const Color(0xFFE07A24),
        _roseRadius - 4,
        3,
      );
      _drawRelativeArc(canvas, center, referenceBearing, plot);
    }
  }

  void _drawCardinal(
    Canvas canvas,
    Offset center,
    String label,
    double bearing,
    Color color,
  ) {
    final labelPoint = center + _directionFromTrueBearing(bearing, _roseRadius + 18);
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      labelPoint - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void _drawBearingRay(
    Canvas canvas,
    Offset center,
    double bearing,
    Color color,
    double length,
    double strokeWidth,
  ) {
    final end = center + _directionFromTrueBearing(bearing, length);
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, end, paint);
  }

  void _drawRelativeArc(
    Canvas canvas,
    Offset center,
    double referenceBearing,
    double plotBearing,
  ) {
    final relative = signedRelativeBearing(
      referenceBearing: referenceBearing,
      targetBearing: plotBearing,
    );
    if (relative.abs() < 1) {
      return;
    }

    final startAngle =
        northAngle + (referenceBearing * math.pi / 180) - (math.pi / 2);
    final sweepRadians = relative * math.pi / 180;
    final rect = Rect.fromCircle(center: center, radius: 24);

    final paint = Paint()
      ..color = const Color(0xFFE07A24).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    canvas.drawArc(rect, startAngle, sweepRadians, false, paint);
  }

  @override
  bool shouldRepaint(covariant CompassRosePainter oldDelegate) {
    return oldDelegate.northAngle != northAngle ||
        oldDelegate.referenceBearing != referenceBearing ||
        oldDelegate.plotBearing != plotBearing;
  }
}
