import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'map_marker_layout.dart';
import 'map_marker_pin_layout.dart';

final mapMarkerPinLayoutProvider = FutureProvider<MapMarkerPinLayout>((
  ref,
) async {
  try {
    final svg = await rootBundle.loadString(mapMarkerPinAssetPath);
    return parseMapMarkerPinLayout(svg);
  } catch (_) {
    return MapMarkerPinLayout.fallback;
  }
});
