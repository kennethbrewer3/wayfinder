import 'package:flutter/material.dart';

/// Outlines the map canvas for layout debugging.
class MapViewportDebugOverlay extends StatelessWidget {
  const MapViewportDebugOverlay({
    super.key,
    required this.mapSize,
  });

  final Size mapSize;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: mapSize.width,
        height: mapSize.height,
        child: CustomPaint(
          foregroundPainter: _ViewportBorderPainter(),
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: ColoredBox(
                color: Colors.red.withValues(alpha: 0.92),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    '${mapSize.width.toStringAsFixed(0)} × ${mapSize.height.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ViewportBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
