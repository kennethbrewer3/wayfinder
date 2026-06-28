import 'package:flutter/material.dart';

import 'marker_icon_glyph.dart';

const mapMarkerWidth = 44.0;
const mapMarkerHeight = 44.0;

/// Geographic [Marker.point] is anchored to the bottom-center of this widget
/// ([Alignment.topCenter] in flutter_map), so the painted tip at
/// `(width / 2, height)` sits on the coordinates.
const mapMarkerAnchorAlignment = Alignment.topCenter;

const mapMarkerHeadCenterY = 16.0;
const mapMarkerHeadRadius = 16.0;
const mapMarkerInnerHeadRadiusRatio = 0.58;
const mapMarkerIconPaddingRatio = 0.11;

const mapMarkerTailAttachYFactor = 0.36;
const mapMarkerTailAttachXFactor = 0.48;
const mapMarkerTailCurveExtra = 4.0;

double mapMarkerInnerDiameter(double scale) =>
    mapMarkerHeadRadius * 2 * mapMarkerInnerHeadRadiusRatio * scale;

double mapMarkerIconSizeForScale(double scale) =>
    mapMarkerInnerDiameter(scale) * (1 - 2 * mapMarkerIconPaddingRatio);

class MapMarkerIcon extends StatelessWidget {
  const MapMarkerIcon({
    super.key,
    required this.color,
    this.iconName = 'place',
    this.badgeIcon,
    this.badgeColor,
    this.width = mapMarkerWidth,
    this.height = mapMarkerHeight,
  });

  final Color color;
  final String iconName;
  final IconData? badgeIcon;
  final Color? badgeColor;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scale = width / mapMarkerWidth;
    final headCenterY = mapMarkerHeadCenterY * scale;
    final innerDiameter = mapMarkerInnerDiameter(scale);
    final iconSize = mapMarkerIconSizeForScale(scale);

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          CustomPaint(
            size: Size(width, height),
            painter: _MarkerPinPainter(
              color: color,
              scale: scale,
            ),
          ),
          Positioned(
            top: headCenterY - innerDiameter / 2,
            child: ClipOval(
              child: SizedBox(
                width: innerDiameter,
                height: innerDiameter,
                child: Center(
                  child: MarkerIconGlyph(
                    iconName: iconName,
                    size: iconSize,
                    color: color,
                  ),
                ),
              ),
            ),
          ),
          if (badgeIcon != null)
            Positioned(
              right: -2 * scale,
              bottom: 4 * scale,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: badgeColor ?? Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 1.5 * scale),
                ),
                child: Padding(
                  padding: EdgeInsets.all(2 * scale),
                  child: Icon(
                    badgeIcon,
                    size: 10 * scale,
                    color: color,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MarkerPinPainter extends CustomPainter {
  const _MarkerPinPainter({
    required this.color,
    required this.scale,
  });

  final Color color;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final headCenterY = mapMarkerHeadCenterY * scale;
    final headRadius = mapMarkerHeadRadius * scale;
    final innerRadius = headRadius * mapMarkerInnerHeadRadiusRatio;
    final tip = Offset(centerX, size.height);

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final headCenter = Offset(centerX, headCenterY);
    canvas.drawCircle(headCenter, headRadius, fillPaint);

    final attachY = headCenterY + headRadius * mapMarkerTailAttachYFactor;
    final attachHalfWidth = headRadius * mapMarkerTailAttachXFactor;
    final curveY = headCenterY + headRadius + mapMarkerTailCurveExtra * scale;

    final tailPath = Path()
      ..moveTo(centerX - attachHalfWidth, attachY)
      ..quadraticBezierTo(
        centerX - attachHalfWidth * 0.55,
        curveY,
        tip.dx,
        tip.dy,
      )
      ..quadraticBezierTo(
        centerX + attachHalfWidth * 0.55,
        curveY,
        centerX + attachHalfWidth,
        attachY,
      )
      ..close();
    canvas.drawPath(tailPath, fillPaint);

    canvas.drawCircle(
      headCenter,
      innerRadius,
      Paint()..color = Colors.white,
    );

    final outlinePaint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75 * scale;
    canvas.drawCircle(headCenter, headRadius, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant _MarkerPinPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.scale != scale;
  }
}
