import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/marker_icon_registry.dart';

class MarkerIconGlyph extends StatelessWidget {
  const MarkerIconGlyph({
    super.key,
    required this.iconName,
    required this.color,
    required this.size,
  });

  final String iconName;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final glyphSize = size * markerIconGlyphScale(iconName);
    final emoji = markerIconEmoji(iconName);
    if (emoji != null) {
      return Text(
        emoji,
        style: TextStyle(fontSize: glyphSize, height: 1),
      );
    }

    final assetPath = markerIconAsset(iconName);
    if (assetPath != null) {
      final preserveColors = markerIconColoredAsset(iconName);
      return SvgPicture.asset(
        assetPath,
        width: glyphSize,
        height: glyphSize,
        colorFilter: preserveColors
            ? null
            : ColorFilter.mode(color, BlendMode.srcIn),
      );
    }

    return Icon(
      markerIconData(iconName),
      size: glyphSize,
      color: color,
    );
  }
}
