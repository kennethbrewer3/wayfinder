import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/marker_icon_catalog.dart';
import '../models/marker_icon_registry.dart';
import '../providers/marker_icon_providers.dart';
import 'map_marker_layout.dart';
import 'map_marker_pin_color_mapper.dart';
import 'map_marker_pin_layout.dart';
import 'map_marker_pin_layout_loader.dart';
import 'marker_icon_glyph.dart';
import 'marker_svg_picture.dart';

export 'map_marker_layout.dart';
export 'map_marker_pin_layout.dart';

class MapMarkerIcon extends ConsumerWidget {
  const MapMarkerIcon({
    super.key,
    required this.color,
    this.iconName = defaultMarkerIconKey,
    this.iconBackgroundColor,
    this.badgeIcon,
    this.badgeColor,
    this.width = mapMarkerWidth,
    this.height = mapMarkerHeight,
    this.isSelected = false,
    this.selectionColor,
  });

  final Color color;
  final String iconName;
  final Color? iconBackgroundColor;
  final IconData? badgeIcon;
  final Color? badgeColor;
  final double width;
  final double height;
  final bool isSelected;
  final Color? selectionColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(markerIconRevisionProvider);
    final catalog =
        ref.watch(markerIconCatalogProvider).valueOrNull ??
        MarkerIconCatalog.defaults();
    final layout =
        ref.watch(mapMarkerPinLayoutProvider).valueOrNull ??
        MapMarkerPinLayout.fallback;
    final Color backgroundColor =
        iconBackgroundColor ?? catalog.iconBackgroundColor(iconName);
    final slot = layout.iconSlotRect(width, height);
    final iconSize = layout.iconGlyphSize(width, height);
    final scale = layout.containScale(width, height);
    final highlight = selectionColor ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (isSelected)
            Positioned(
              left: slot.left - 6 * scale,
              top: slot.top - 6 * scale,
              child: Container(
                width: slot.width + 12 * scale,
                height: slot.height + 12 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: highlight.withValues(alpha: 0.22),
                  border: Border.all(color: highlight, width: 3 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: highlight.withValues(alpha: 0.45),
                      blurRadius: 10 * scale,
                      spreadRadius: 1 * scale,
                    ),
                  ],
                ),
              ),
            ),
          markerSvgAssetPicture(
            assetPath: mapMarkerPinAssetPath,
            width: width,
            height: height,
            fit: BoxFit.contain,
            colorMapper: MapMarkerPinColorMapper(
              markerColor: color,
              iconBackgroundColor: backgroundColor,
            ),
          ),
          Positioned(
            left: slot.left,
            top: slot.top,
            child: ClipOval(
              child: SizedBox(
                width: slot.width,
                height: slot.height,
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
