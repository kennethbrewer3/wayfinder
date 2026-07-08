import 'package:flutter/material.dart';

import 'marker_svg_picture.dart';

class MarkerIconSvgGlyph extends StatelessWidget {
  const MarkerIconSvgGlyph({
    super.key,
    required this.svgUrl,
    this.assetPath,
    required this.fallbackIcon,
    required this.size,
    required this.color,
    required this.preserveColors,
  });

  final String svgUrl;
  final String? assetPath;
  final IconData fallbackIcon;
  final double size;
  final Color color;
  final bool preserveColors;

  @override
  Widget build(BuildContext context) {
    return markerSvgNetworkPicture(
      url: svgUrl,
      width: size,
      height: size,
      colorFilter: preserveColors
          ? null
          : ColorFilter.mode(color, BlendMode.srcIn),
      placeholderBuilder: (_) => _loadingPlaceholder(),
      errorBuilder: (_, _, _) {
        if (assetPath != null) {
          return markerSvgAssetPicture(
            assetPath: assetPath!,
            width: size,
            height: size,
            colorFilter: preserveColors
                ? null
                : ColorFilter.mode(color, BlendMode.srcIn),
            errorBuilder: (_, _, _) => _iconFallback(),
          );
        }
        return _iconFallback();
      },
    );
  }

  Widget _loadingPlaceholder() {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: SizedBox(
          width: size * 0.45,
          height: size * 0.45,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: color.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }

  Widget _iconFallback() {
    return Icon(
      fallbackIcon,
      size: size,
      color: color,
    );
  }
}
