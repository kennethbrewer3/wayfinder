import 'package:flutter/material.dart';

import '../models/marker_icon_registry.dart';

const mapMarkerWidth = 36.0;
const mapMarkerHeight = 44.0;

/// Anchors the geographic [Marker.point] to the pin tip at the bottom of the
/// widget (flutter_map uses [Alignment.topCenter] to place the marker above the
/// point, so its bottom edge sits on the coordinates).
const mapMarkerAnchorAlignment = Alignment.topCenter;

const mapMarkerHeadCenterY = 12.0;
const mapMarkerHeadRadius = 10.0;
const mapMarkerIconSize = 14.0;

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
    final iconSize = mapMarkerIconSize * scale;

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
            top: headCenterY - iconSize / 2,
            child: Icon(
              markerIconData(iconName),
              size: iconSize,
              color: color,
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
    final tipY = size.height;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final headRect = Rect.fromCircle(
      center: Offset(centerX, headCenterY),
      radius: headRadius,
    );
    canvas.drawCircle(headRect.center, headRadius, fillPaint);

    final tailPath = Path()
      ..moveTo(centerX - headRadius * 0.62, headCenterY + headRadius * 0.45)
      ..quadraticBezierTo(
        centerX - headRadius * 0.35,
        headCenterY + headRadius + 10 * scale,
        centerX,
        tipY,
      )
      ..quadraticBezierTo(
        centerX + headRadius * 0.35,
        headCenterY + headRadius + 10 * scale,
        centerX + headRadius * 0.62,
        headCenterY + headRadius * 0.45,
      )
      ..close();
    canvas.drawPath(tailPath, fillPaint);

    canvas.drawCircle(
      Offset(centerX, headCenterY),
      headRadius * 0.62,
      Paint()..color = Colors.white,
    );

    final outlinePaint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75 * scale;
    canvas.drawCircle(headRect.center, headRadius, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant _MarkerPinPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.scale != scale;
  }
}
