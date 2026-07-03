import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../markers/models/marker_icon_catalog.dart';
import '../../markers/presentation/marker_icon_glyph.dart';
import '../../markers/providers/marker_icon_providers.dart';
import '../models/track_transportation_mode.dart';

class TrackTransportationIcon extends ConsumerWidget {
  const TrackTransportationIcon(
    this.mode, {
    super.key,
    required this.size,
    this.color,
  });

  final TrackTransportationMode mode;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconKey = mode.markerIconKey;
    final iconColor = color ??
        IconTheme.of(context).color ??
        Theme.of(context).iconTheme.color ??
        Colors.black;
    if (iconKey != null) {
      final catalog = ref.watch(markerIconCatalogProvider).valueOrNull ??
          MarkerIconCatalog.defaults();
      if (catalog.svgUrl(iconKey) != null ||
          catalog.asset(iconKey) != null ||
          catalog.emoji(iconKey) != null) {
        return MarkerIconGlyph(
          iconName: iconKey,
          color: iconColor,
          size: size,
        );
      }
    }

    return Icon(mode.icon, size: size, color: color);
  }
}
