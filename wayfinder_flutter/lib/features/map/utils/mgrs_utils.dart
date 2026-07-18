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

/// Label placed near the center of an MGRS cell / along a grid line.
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

  double get centerLatitude => (south + north) / 2;
  double get centerLongitude => (west + east) / 2;
}

/// Builds MGRS grid lines/labels for [bounds] at the given map [zoom].
///
/// Lines are continuous UTM easting/northing meridians so the overlay reads as
/// a real grid rather than disconnected cell edges.
MgrsGridGeometry buildMgrsGrid({
  required MgrsLatLngBounds bounds,
  required double zoom,
  int maxLines = 48,
}) {
  final clampedSouth = bounds.south.clamp(-80.0, 84.0);
  final clampedNorth = bounds.north.clamp(-80.0, 84.0);
  if (clampedSouth >= clampedNorth) {
    return MgrsGridGeometry.empty;
  }

  final accuracy = mgrsAccuracyForZoom(zoom);
  final intervalMeters = _intervalMeters(accuracy);
  final center = LatLng(bounds.centerLatitude, bounds.centerLongitude);

  UTM centerUtm;
  try {
    centerUtm = Mgrs.LLtoUTM(center.latitude, center.longitude);
  } catch (_) {
    return MgrsGridGeometry.empty;
  }

  final cornerUtms = <UTM>[];
  for (final point in [
    LatLng(clampedSouth, bounds.west),
    LatLng(clampedSouth, bounds.east),
    LatLng(clampedNorth, bounds.west),
    LatLng(clampedNorth, bounds.east),
  ]) {
    try {
      final utm = Mgrs.LLtoUTM(point.latitude, point.longitude);
      // Only use corners that fall in the same UTM zone as the center so easting
      // values stay comparable. Cross-zone viewports still get a usable grid for
      // the dominant zone.
      if (utm.zoneNumber == centerUtm.zoneNumber) {
        cornerUtms.add(utm);
      }
    } catch (_) {
      // Skip invalid corners.
    }
  }

  if (cornerUtms.isEmpty) {
    cornerUtms.add(centerUtm);
  }

  var minE = cornerUtms.first.easting;
  var maxE = cornerUtms.first.easting;
  var minN = cornerUtms.first.northing;
  var maxN = cornerUtms.first.northing;
  for (final utm in cornerUtms) {
    minE = utm.easting < minE ? utm.easting : minE;
    maxE = utm.easting > maxE ? utm.easting : maxE;
    minN = utm.northing < minN ? utm.northing : minN;
    maxN = utm.northing > maxN ? utm.northing : maxN;
  }

  // Pad so lines reach past the viewport edge.
  minE -= intervalMeters;
  maxE += intervalMeters;
  minN -= intervalMeters;
  maxN += intervalMeters;

  final eastings = _gridValues(minE, maxE, intervalMeters, maxLines);
  final northings = _gridValues(minN, maxN, intervalMeters, maxLines);
  if (eastings.isEmpty || northings.isEmpty) {
    return MgrsGridGeometry.empty;
  }

  final lines = <List<LatLng>>[];
  final labels = <MgrsGridLabel>[];
  final sampleStep = intervalMeters / 8;

  for (final easting in eastings) {
    final line = _utmLine(
      zoneNumber: centerUtm.zoneNumber,
      zoneLetter: centerUtm.zoneLetter,
      fixedEasting: easting,
      varyingStart: minN,
      varyingEnd: maxN,
      sampleStep: sampleStep,
      varyNorthing: true,
    );
    if (line.length >= 2) {
      lines.add(line);
      final labelPoint = _utmToLatLng(
        easting: easting,
        northing: (minN + maxN) / 2,
        zoneNumber: centerUtm.zoneNumber,
        zoneLetter: centerUtm.zoneLetter,
      );
      if (labelPoint != null) {
        labels.add(
          MgrsGridLabel(
            point: labelPoint,
            text: _gridLineLabel(easting, accuracy),
          ),
        );
      }
    }
  }

  for (final northing in northings) {
    final line = _utmLine(
      zoneNumber: centerUtm.zoneNumber,
      zoneLetter: centerUtm.zoneLetter,
      fixedNorthing: northing,
      varyingStart: minE,
      varyingEnd: maxE,
      sampleStep: sampleStep,
      varyNorthing: false,
    );
    if (line.length >= 2) {
      lines.add(line);
      final labelPoint = _utmToLatLng(
        easting: (minE + maxE) / 2,
        northing: northing,
        zoneNumber: centerUtm.zoneNumber,
        zoneLetter: centerUtm.zoneLetter,
      );
      if (labelPoint != null) {
        labels.add(
          MgrsGridLabel(
            point: labelPoint,
            text: _gridLineLabel(northing, accuracy),
          ),
        );
      }
    }
  }

  // Prefer a few cell-center MGRS labels when the grid is coarse.
  if (accuracy <= 1) {
    labels
      ..clear()
      ..addAll(
        _coarseCellLabels(
          eastings: eastings,
          northings: northings,
          zoneNumber: centerUtm.zoneNumber,
          zoneLetter: centerUtm.zoneLetter,
          accuracy: accuracy,
        ),
      );
  } else if (labels.length > 24) {
    // Keep the display readable at fine grids: label every other line.
    final thinned = <MgrsGridLabel>[];
    for (var i = 0; i < labels.length; i += 2) {
      thinned.add(labels[i]);
    }
    labels
      ..clear()
      ..addAll(thinned);
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

int _intervalMeters(int accuracy) {
  return switch (accuracy) {
    0 => 100000,
    1 => 10000,
    2 => 1000,
    3 => 100,
    _ => 10,
  };
}

List<double> _gridValues(
  double min,
  double max,
  int interval,
  int maxCount,
) {
  if (max <= min || interval <= 0) {
    return const [];
  }
  final start = (min / interval).ceil() * interval;
  final values = <double>[];
  for (var value = start.toDouble(); value <= max; value += interval) {
    values.add(value);
    if (values.length >= maxCount) {
      break;
    }
  }
  return values;
}

List<LatLng> _utmLine({
  required int zoneNumber,
  required String zoneLetter,
  double? fixedEasting,
  double? fixedNorthing,
  required double varyingStart,
  required double varyingEnd,
  required double sampleStep,
  required bool varyNorthing,
}) {
  final points = <LatLng>[];
  final step = sampleStep <= 0 ? 1000.0 : sampleStep;
  for (var value = varyingStart; value <= varyingEnd + step / 2; value += step) {
    final clamped = value > varyingEnd ? varyingEnd : value;
    final point = varyNorthing
        ? _utmToLatLng(
            easting: fixedEasting!,
            northing: clamped,
            zoneNumber: zoneNumber,
            zoneLetter: zoneLetter,
          )
        : _utmToLatLng(
            easting: clamped,
            northing: fixedNorthing!,
            zoneNumber: zoneNumber,
            zoneLetter: zoneLetter,
          );
    if (point != null) {
      points.add(point);
    }
  }
  return points;
}

LatLng? _utmToLatLng({
  required double easting,
  required double northing,
  required int zoneNumber,
  required String zoneLetter,
}) {
  try {
    final result = Mgrs.UTMtoLL(
      UTM(
        easting: easting,
        northing: northing,
        zoneNumber: zoneNumber,
        zoneLetter: zoneLetter,
      ),
    );
    if (result is LonLat) {
      return LatLng(result.lat, result.lon);
    }
  } catch (_) {
    return null;
  }
  return null;
}

String _gridLineLabel(double meters, int accuracy) {
  // Show the MGRS grid digits for this line (not the full zone designator).
  final interval = _intervalMeters(accuracy);
  final digits = switch (accuracy) {
    0 => 1,
    1 => 2,
    2 => 3,
    3 => 4,
    _ => 5,
  };
  final scaled = (meters / interval).round() * interval;
  final within100k = scaled % 100000;
  final labelValue = within100k ~/ interval;
  return labelValue.toString().padLeft(digits, '0');
}

List<MgrsGridLabel> _coarseCellLabels({
  required List<double> eastings,
  required List<double> northings,
  required int zoneNumber,
  required String zoneLetter,
  required int accuracy,
}) {
  final labels = <MgrsGridLabel>[];
  for (var i = 0; i < eastings.length - 1; i++) {
    for (var j = 0; j < northings.length - 1; j++) {
      final easting = (eastings[i] + eastings[i + 1]) / 2;
      final northing = (northings[j] + northings[j + 1]) / 2;
      final point = _utmToLatLng(
        easting: easting,
        northing: northing,
        zoneNumber: zoneNumber,
        zoneLetter: zoneLetter,
      );
      if (point == null) {
        continue;
      }
      try {
        labels.add(
          MgrsGridLabel(
            point: point,
            text: formatMgrs(latLngToMgrs(point, accuracy: accuracy)),
          ),
        );
      } catch (_) {
        // Skip labels that fail conversion.
      }
      if (labels.length >= 16) {
        return labels;
      }
    }
  }
  return labels;
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
