import 'package:latlong2/latlong.dart';
import 'package:mgrs_dart/mgrs_dart.dart';

/// Parsed MGRS location suitable for search / map navigation.
class MgrsLocation {
  const MgrsLocation({
    required this.point,
    required this.formatted,
    required this.accuracy,
    required this.zoom,
  });

  final LatLng point;
  final String formatted;
  final int accuracy;
  final double zoom;
}

/// Label placed near the center of an MGRS cell.
class MgrsGridLabel {
  const MgrsGridLabel({
    required this.point,
    required this.text,
  });

  final LatLng point;
  final String text;
}

/// Grid geometry for the visible map viewport.
class MgrsGridGeometry {
  const MgrsGridGeometry({
    required this.lines,
    required this.labels,
    required this.accuracy,
  });

  final List<List<LatLng>> lines;
  final List<MgrsGridLabel> labels;
  final int accuracy;

  static const empty = MgrsGridGeometry(
    lines: [],
    labels: [],
    accuracy: 0,
  );
}

final _mgrsPattern = RegExp(
  r'^(\d{1,2})\s*([C-HJ-NP-X])\s*([A-HJ-NP-Z]{2})\s*((?:\d{2}){0,5})$',
  caseSensitive: false,
);

/// Returns true when [input] looks like an MGRS coordinate (with optional spaces).
bool looksLikeMgrs(String input) {
  final compact = _compactMgrs(input);
  if (compact == null) {
    return false;
  }
  return _mgrsPattern.hasMatch(compact);
}

/// Parses an MGRS string to a map location, or null if invalid.
MgrsLocation? parseMgrsLocation(String input) {
  final compact = _compactMgrs(input);
  if (compact == null || !_mgrsPattern.hasMatch(compact)) {
    return null;
  }

  try {
    final point = Mgrs.toPoint(compact);
    final lon = point[0];
    final lat = point[1];
    if (lat < -80 || lat > 84 || lon < -180 || lon > 180) {
      return null;
    }

    final match = _mgrsPattern.firstMatch(compact)!;
    final digitCount = match.group(4)?.length ?? 0;
    final accuracy = digitCount ~/ 2;
    return MgrsLocation(
      point: LatLng(lat, lon),
      formatted: formatMgrs(compact),
      accuracy: accuracy,
      zoom: _zoomForAccuracy(accuracy),
    );
  } catch (_) {
    return null;
  }
}

/// Formats a compact MGRS string with conventional spacing.
String formatMgrs(String mgrs) {
  final compact = _compactMgrs(mgrs);
  if (compact == null) {
    return mgrs.trim();
  }
  final match = _mgrsPattern.firstMatch(compact);
  if (match == null) {
    return compact;
  }
  final zone = '${match.group(1)}${match.group(2)!.toUpperCase()}';
  final square = match.group(3)!.toUpperCase();
  final digits = match.group(4) ?? '';
  if (digits.isEmpty) {
    return '$zone $square';
  }
  final half = digits.length ~/ 2;
  return '$zone $square ${digits.substring(0, half)} ${digits.substring(half)}';
}

/// Converts WGS84 lon/lat to an MGRS string at [accuracy] (0–5).
String latLngToMgrs(LatLng point, {int accuracy = 5}) {
  return Mgrs.forward(
    [point.longitude, point.latitude],
    accuracy.clamp(0, 5),
  );
}

/// Geographic bounds used when sampling MGRS cells for the overlay.
class MgrsLatLngBounds {
  const MgrsLatLngBounds({
    required this.south,
    required this.west,
    required this.north,
    required this.east,
  });

  final double south;
  final double west;
  final double north;
  final double east;
}

/// Builds MGRS grid lines/labels for [bounds] at the given map [zoom].
MgrsGridGeometry buildMgrsGrid({
  required MgrsLatLngBounds bounds,
  required double zoom,
  int maxCells = 250,
}) {
  final accuracy = mgrsAccuracyForZoom(zoom);
  final stepDegrees = _sampleStepDegrees(accuracy);
  final south = (bounds.south - stepDegrees).clamp(-80.0, 84.0);
  final north = (bounds.north + stepDegrees).clamp(-80.0, 84.0);
  final west = bounds.west - stepDegrees;
  final east = bounds.east + stepDegrees;

  final cells = <String>{};
  for (var lat = south; lat <= north; lat += stepDegrees) {
    for (var lon = west; lon <= east; lon += stepDegrees) {
      final normalizedLon = _normalizeLongitude(lon);
      try {
        final mgrs = Mgrs.forward([normalizedLon, lat], accuracy);
        cells.add(mgrs);
        if (cells.length >= maxCells) {
          break;
        }
      } catch (_) {
        // Polar / invalid samples are skipped.
      }
    }
    if (cells.length >= maxCells) {
      break;
    }
  }

  if (cells.isEmpty) {
    return MgrsGridGeometry.empty;
  }

  final edgeKeys = <String>{};
  final lines = <List<LatLng>>[];
  final labels = <MgrsGridLabel>[];
  final showLabels = accuracy <= 2;

  for (final mgrs in cells) {
    try {
      final box = Mgrs.inverse(mgrs);
      final left = box[0];
      final bottom = box[1];
      final right = box[2];
      final top = box[3];
      final sw = LatLng(bottom, left);
      final se = LatLng(bottom, right);
      final ne = LatLng(top, right);
      final nw = LatLng(top, left);

      void addEdge(LatLng a, LatLng b) {
        final key = _edgeKey(a, b);
        if (edgeKeys.add(key)) {
          lines.add([a, b]);
        }
      }

      addEdge(sw, se);
      addEdge(se, ne);
      addEdge(ne, nw);
      addEdge(nw, sw);

      if (showLabels) {
        labels.add(
          MgrsGridLabel(
            point: LatLng((bottom + top) / 2, (left + right) / 2),
            text: formatMgrs(mgrs),
          ),
        );
      }
    } catch (_) {
      // Skip cells that fail to invert.
    }
  }

  return MgrsGridGeometry(
    lines: lines,
    labels: labels,
    accuracy: accuracy,
  );
}

/// MGRS digit accuracy (0 = 100 km … 5 = 1 m) for a map zoom level.
int mgrsAccuracyForZoom(double zoom) {
  if (zoom < 6) return 0;
  if (zoom < 9) return 1;
  if (zoom < 12) return 2;
  if (zoom < 15) return 3;
  return 4;
}

double _zoomForAccuracy(int accuracy) {
  return switch (accuracy) {
    0 => 8,
    1 => 10,
    2 => 12,
    3 => 14,
    4 => 16,
    _ => 17,
  };
}

double _sampleStepDegrees(int accuracy) {
  return switch (accuracy) {
    0 => 0.8,
    1 => 0.08,
    2 => 0.008,
    3 => 0.0008,
    _ => 0.00015,
  };
}

String? _compactMgrs(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  final compact = trimmed.replaceAll(RegExp(r'\s+'), '').toUpperCase();
  if (compact.length < 3 || compact.length > 15) {
    return null;
  }
  return compact;
}

double _normalizeLongitude(double lon) {
  var value = lon;
  while (value < -180) {
    value += 360;
  }
  while (value > 180) {
    value -= 360;
  }
  return value;
}

String _edgeKey(LatLng a, LatLng b) {
  String fmt(LatLng p) =>
      '${p.latitude.toStringAsFixed(6)},${p.longitude.toStringAsFixed(6)}';
  final left = fmt(a);
  final right = fmt(b);
  return left.compareTo(right) <= 0 ? '$left|$right' : '$right|$left';
}
