import 'package:flutter/widgets.dart';

/// Same invert + hue-rotate matrix used by flutter_map's darkModeTileBuilder.
///
/// Raster and vector basemaps are authored for light viewing, so this only
/// *simulates* a dark style via a color filter — it is not separate dark cartography.
///
/// Screen-only: printable atlas PDF rendering must not use this filter.
const ColorFilter darkMapTilesColorFilter = ColorFilter.matrix(<double>[
  0.5740000009536743,
  -1.4299999475479126,
  -0.14399999380111694,
  0,
  255,
  -0.4259999990463257,
  -0.429999977350235,
  -0.14399999380111694,
  0,
  255,
  -0.4259999990463257,
  -1.4299999475479126,
  0.8559999465942383,
  0,
  255,
  0,
  0,
  0,
  1,
  0,
]);

/// Wraps basemap layers with the dark-tile simulation filter when enabled.
Widget maybeDarkenMapLayer({
  required bool enabled,
  required Widget child,
}) {
  if (!enabled) {
    return child;
  }
  return ColorFiltered(
    colorFilter: darkMapTilesColorFilter,
    child: child,
  );
}
