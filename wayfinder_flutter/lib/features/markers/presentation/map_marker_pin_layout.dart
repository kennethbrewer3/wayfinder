import 'dart:math' as math;
import 'dart:ui';

/// Layout read from `assets/markers/marker_pin.svg` for icon placement on the map.
class MapMarkerPinLayout {
  const MapMarkerPinLayout({
    required this.viewBoxWidth,
    required this.viewBoxHeight,
    required this.iconCenterX,
    required this.iconCenterY,
    required this.iconSlotRadius,
    required this.iconGlyphRadius,
  });

  final double viewBoxWidth;
  final double viewBoxHeight;
  final double iconCenterX;
  final double iconCenterY;
  final double iconSlotRadius;
  final double iconGlyphRadius;

  /// Matches the bundled `marker_pin.svg` defaults.
  static const fallback = MapMarkerPinLayout(
    viewBoxWidth: 44,
    viewBoxHeight: 44,
    iconCenterX: 22,
    iconCenterY: 16,
    iconSlotRadius: 11.84,
    iconGlyphRadius: 10.656,
  );

  double containScale(double renderWidth, double renderHeight) => math.min(
    renderWidth / viewBoxWidth,
    renderHeight / viewBoxHeight,
  );

  /// Icon clip slot in widget coordinates (matches [BoxFit.contain] SVG scaling).
  Rect iconSlotRect(double renderWidth, double renderHeight) {
    final scale = containScale(renderWidth, renderHeight);
    final renderedWidth = viewBoxWidth * scale;
    final renderedHeight = viewBoxHeight * scale;
    final offsetX = (renderWidth - renderedWidth) / 2;
    final offsetY = (renderHeight - renderedHeight) / 2;
    final diameter = iconSlotRadius * 2 * scale;
    return Rect.fromCenter(
      center: Offset(
        offsetX + iconCenterX * scale,
        offsetY + iconCenterY * scale,
      ),
      width: diameter,
      height: diameter,
    );
  }

  double iconGlyphSize(double renderWidth, double renderHeight) =>
      iconGlyphRadius * 2 * containScale(renderWidth, renderHeight);
}

/// Default padding around the glyph when `icon-placeholder-glyph` is absent.
const mapMarkerIconPaddingRatio = 0.05;

MapMarkerPinLayout parseMapMarkerPinLayout(String svgContent) {
  final viewBox = _parseViewBox(svgContent);
  final iconBackground = _parseCircleById(svgContent, 'icon-background');
  if (iconBackground == null) {
    throw FormatException('marker_pin.svg is missing circle#icon-background');
  }

  final glyphPlaceholder = _parseCircleById(
    svgContent,
    'icon-placeholder-glyph',
  );
  final glyphRadius =
      glyphPlaceholder?.radius ??
      iconBackground.radius * (1 - 2 * mapMarkerIconPaddingRatio);

  return MapMarkerPinLayout(
    viewBoxWidth: viewBox.width,
    viewBoxHeight: viewBox.height,
    iconCenterX: iconBackground.cx,
    iconCenterY: iconBackground.cy,
    iconSlotRadius: iconBackground.radius,
    iconGlyphRadius: glyphRadius,
  );
}

class _ViewBox {
  const _ViewBox({required this.width, required this.height});

  final double width;
  final double height;
}

class _CircleSpec {
  const _CircleSpec({
    required this.cx,
    required this.cy,
    required this.radius,
  });

  final double cx;
  final double cy;
  final double radius;
}

_ViewBox _parseViewBox(String svgContent) {
  final match = RegExp(
    r'viewBox="\s*[\d.]+\s+[\d.]+\s+([\d.]+)\s+([\d.]+)\s*"',
  ).firstMatch(svgContent);
  if (match == null) {
    throw FormatException('marker_pin.svg is missing a viewBox');
  }
  return _ViewBox(
    width: double.parse(match.group(1)!),
    height: double.parse(match.group(2)!),
  );
}

_CircleSpec? _parseCircleById(String svgContent, String id) {
  for (final match in RegExp(r'<circle\b([^>]*?)/?>').allMatches(svgContent)) {
    final attributes = match.group(1)!;
    if (_readId(attributes) != id) {
      continue;
    }
    final cx = _readNumericAttribute(attributes, 'cx');
    final cy = _readNumericAttribute(attributes, 'cy');
    final radius = _readNumericAttribute(attributes, 'r');
    if (cx == null || cy == null || radius == null) {
      throw FormatException('circle#$id is missing cx, cy, or r');
    }
    return _CircleSpec(cx: cx, cy: cy, radius: radius);
  }
  return null;
}

String? _readId(String attributes) {
  final match = RegExp(
    '''\\bid\\s*=\\s*(["'])([^"']+)\\1''',
  ).firstMatch(attributes);
  return match?.group(2);
}

double? _readNumericAttribute(String attributes, String name) {
  final match = RegExp(
    '''\\b${RegExp.escape(name)}\\s*=\\s*(["'])([\\d.]+)\\1''',
  ).firstMatch(attributes);
  return match != null ? double.parse(match.group(2)!) : null;
}
