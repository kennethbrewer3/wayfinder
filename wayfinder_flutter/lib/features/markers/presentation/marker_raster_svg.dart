import 'dart:convert';
import 'dart:typed_data';

/// Matches SVG wrappers produced by [optimize_marker_svgs.mjs].
final _embeddedPngPattern = RegExp(
  r'''(?:xlink:)?href=["']data:image/png;base64,([A-Za-z0-9+/=\s]+)["']''',
);

/// Returns embedded PNG bytes when [svgBytes] is a raster wrapper SVG.
Uint8List? extractPngFromRasterSvg(Uint8List svgBytes) {
  final svgText = utf8.decode(svgBytes, allowMalformed: true);
  if (!svgText.contains('data:image/png;base64,')) {
    return null;
  }

  final match = _embeddedPngPattern.firstMatch(svgText);
  if (match == null) {
    return null;
  }

  try {
    final normalized = match.group(1)!.replaceAll(RegExp(r'\s'), '');
    return base64.decode(normalized);
  } on FormatException {
    return null;
  }
}
