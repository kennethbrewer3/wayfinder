import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/marker_icon_catalog.dart';
import '../providers/marker_icon_providers.dart';
import 'marker_icon_svg_glyph.dart';

class MarkerIconGlyph extends ConsumerWidget {
  const MarkerIconGlyph({
    super.key,
    required this.iconName,
    required this.color,
    required this.size,
    this.forceTint = false,
  });

  final String iconName;
  final Color color;
  final double size;
  /// When true, applies [color] even for full-color SVG assets.
  final bool forceTint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog =
        ref.watch(markerIconCatalogProvider).valueOrNull ??
        MarkerIconCatalog.defaults();
    final glyphSize = size * catalog.glyphScale(iconName);
    final emoji = catalog.emoji(iconName);
    if (emoji != null) {
      return Text(
        emoji,
        style: TextStyle(fontSize: glyphSize, height: 1),
      );
    }

    final svgUrl = catalog.svgUrl(iconName);
    if (svgUrl != null) {
      final preserveColors = !forceTint && catalog.coloredAsset(iconName);
      return MarkerIconSvgGlyph(
        svgUrl: svgUrl,
        assetPath: catalog.asset(iconName),
        fallbackIcon: catalog.data(iconName),
        size: glyphSize,
        color: color,
        preserveColors: preserveColors,
      );
    }

    final assetPath = catalog.asset(iconName);
    if (assetPath != null) {
      final preserveColors = !forceTint && catalog.coloredAsset(iconName);
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
      catalog.data(iconName),
      size: glyphSize,
      color: color,
    );
  }
}
