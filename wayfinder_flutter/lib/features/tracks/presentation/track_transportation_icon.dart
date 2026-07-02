import 'package:flutter/material.dart';

import '../../markers/models/marker_icon_registry.dart';
import '../../markers/presentation/marker_icon_glyph.dart';
import '../models/track_transportation_mode.dart';

class TrackTransportationIcon extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final iconKey = mode.markerIconKey;
    final iconColor = color ??
        IconTheme.of(context).color ??
        Theme.of(context).iconTheme.color ??
        Colors.black;
    if (iconKey != null && markerIconAsset(iconKey) != null) {
      return MarkerIconGlyph(
        iconName: iconKey,
        color: iconColor,
        size: size,
      );
    }

    return Icon(mode.icon, size: size, color: color);
  }
}
