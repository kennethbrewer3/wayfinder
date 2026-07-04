import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Maps marker SVG palette ids to runtime marker and icon background colors.
class MapMarkerPinColorMapper extends ColorMapper {
  const MapMarkerPinColorMapper({
    required this.markerColor,
    required this.iconBackgroundColor,
  });

  final Color markerColor;
  final Color iconBackgroundColor;

  static const _placeholderPrefix = 'icon-placeholder';

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    if (id != null && id.startsWith(_placeholderPrefix)) {
      return Colors.transparent;
    }

    switch (id) {
      case 'icon-background':
        return iconBackgroundColor;
      case 'marker-outline':
        return markerColor.withValues(alpha: 0.35);
      case 'marker-body':
      case 'marker-head':
      case 'marker-tail':
        return markerColor;
    }

    return color;
  }
}
