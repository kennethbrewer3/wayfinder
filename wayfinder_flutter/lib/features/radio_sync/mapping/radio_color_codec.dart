import '../../markers/models/marker_color.dart';

/// Pack `#RRGGBB` / `#AARRGGBB` colors to 24-bit RGB for radio payloads.
int radioColorRgbFromHex(String hex) {
  final color = parseMarkerColor(hex);
  return color.toARGB32() & 0xffffff;
}

String radioColorHexFromRgb(int rgb) {
  final value = rgb & 0xffffff;
  return '#${value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
