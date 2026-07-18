import 'dart:math' as math;

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

/// Standard MGRS grid intervals (meters).
const _mgrsIntervalsMeters = <int>[100000, 10000, 1000, 100, 10];

/// MGRS latitude-band edges (degrees), C…X including the taller X band.
const _mgrsBandEdges = <double>[
  -80,
  -72,
  -64,
  -56,
  -48,
  -40,
  -32,
  -24,
  -16,
  -8,
  0,
  8,
  16,
  24,
  32,
  40,
  48,
  56,
  64,
  72,
  84,
];

/// Builds MGRS grid lines/labels for [bounds] at the given map [zoom].
///
/// - Local views: UTM easting/northing grid for the center zone.
/// - Wide / low-zoom views: all intersecting UTM zones, or GZD lines worldwide.
MgrsGridGeometry buildMgrsGrid({
  required MgrsLatLngBounds bounds,
  required double zoom,
}) {
  final clampedSouth = bounds.south.clamp(-80.0, 84.0);
  final clampedNorth = bounds.north.clamp(-80.0, 84.0);
  if (clampedSouth >= clampedNorth) {
    return MgrsGridGeometry.empty;
  }

  final visible = MgrsLatLngBounds(
    south: clampedSouth,
    west: bounds.west,
    north: clampedNorth,
    east: bounds.east,
  );
  final lonSpan = _longitudeSpanDegrees(visible.west, visible.east);
  final spanMeters = geographicSpanMeters(visible);

  // World / continental: draw Grid Zone Designator lines so coverage is global.
  if (zoom <= 5 || lonSpan >= 40) {
    return _buildGzdGrid(visible);
  }

  // Multi-zone regional views (typical around zoom 6–8).
  if (zoom <= 8 || lonSpan >= 8) {
    final interval = chooseMgrsIntervalMeters(spanMeters);
    // Stay at 100 km / 10 km when spanning several zones.
    final regionalInterval = interval < 10000 ? 10000 : interval;
    return _buildMultiZoneGrid(
      visible,
      intervalMeters: regionalInterval,
    );
  }

  return _buildSingleZoneGrid(visible, spanMeters: spanMeters);
}

/// Approximate ground span of [bounds] in meters (max of lat/lon extents).
double geographicSpanMeters(MgrsLatLngBounds bounds) {
  final latSpan = (bounds.north - bounds.south).abs() * 111320;
  final cosLat = _cosDegrees(bounds.centerLatitude).abs().clamp(0.2, 1.0);
  final lonSpan =
      _longitudeSpanDegrees(bounds.west, bounds.east) * 111320 * cosLat;
  return latSpan > lonSpan ? latSpan : lonSpan;
}

/// Picks an MGRS interval so about 6–10 lines span [spanMeters].
int chooseMgrsIntervalMeters(double spanMeters) {
  const targetLines = 8.0;
  const minLines = 4.0;
  const maxLines = 12.0;

  int best = _mgrsIntervalsMeters[1];
  var bestScore = double.infinity;

  for (final interval in _mgrsIntervalsMeters) {
    final count = spanMeters / interval;
    // Prefer counts near [targetLines]; penalize outside [minLines, maxLines].
    var score = (count - targetLines).abs();
    if (count < minLines) {
      score += (minLines - count) * 4;
    } else if (count > maxLines) {
      score += (count - maxLines) * 4;
    }
    if (score < bestScore) {
      bestScore = score;
      best = interval;
    }
  }
  return best;
}

MgrsGridGeometry _buildGzdGrid(MgrsLatLngBounds visible) {
  final lines = <List<LatLng>>[];
  final labels = <MgrsGridLabel>[];
  final west = visible.west;
  final east = visible.east;
  final south = visible.south;
  final north = visible.north;

  // Vertical zone meridians every 6°.
  for (var lon = -180.0; lon <= 180.0 + 0.001; lon += 6) {
    if (!_longitudeInRange(lon, west, east)) {
      continue;
    }
    lines.add([
      LatLng(south, lon),
      LatLng(north, lon),
    ]);
  }

  // Horizontal latitude-band edges.
  for (final lat in _mgrsBandEdges) {
    if (lat < south - 0.01 || lat > north + 0.01) {
      continue;
    }
    lines.add([
      LatLng(lat, west),
      LatLng(lat, east),
    ]);
  }

  // Sparse GZD labels (zone + band letter) in cell centers.
  for (final zone in _zonesIntersecting(west, east)) {
    final zoneWest = _zoneWestLongitude(zone);
    final zoneEast = zoneWest + 6;
    final cellWest = math.max(zoneWest, west);
    final cellEast = math.min(zoneEast, east);
    if (cellEast - cellWest < 0.5) {
      continue;
    }
    for (var i = 0; i < _mgrsBandEdges.length - 1; i++) {
      final bandSouth = _mgrsBandEdges[i];
      final bandNorth = _mgrsBandEdges[i + 1];
      final cellSouth = math.max(bandSouth, south);
      final cellNorth = math.min(bandNorth, north);
      if (cellNorth - cellSouth < 0.5) {
        continue;
      }
      final center = LatLng(
        (cellSouth + cellNorth) / 2,
        (cellWest + cellEast) / 2,
      );
      try {
        final letter = Mgrs.getLetterDesignator(center.latitude);
        if (letter == 'Z') {
          continue;
        }
        labels.add(
          MgrsGridLabel(
            point: center,
            text: '$zone$letter',
          ),
        );
      } catch (_) {
        // Skip invalid centers.
      }
      if (labels.length >= 48) {
        break;
      }
    }
    if (labels.length >= 48) {
      break;
    }
  }

  return MgrsGridGeometry(
    lines: lines,
    labels: labels,
    accuracy: 0,
  );
}

MgrsGridGeometry _buildMultiZoneGrid(
  MgrsLatLngBounds visible, {
  required int intervalMeters,
}) {
  final accuracy = accuracyForIntervalMeters(intervalMeters);
  final lines = <List<LatLng>>[];
  final labels = <MgrsGridLabel>[];
  final zones = _zonesIntersecting(visible.west, visible.east);

  for (final zone in zones) {
    final zoneWest = _zoneWestLongitude(zone);
    final zoneEast = zoneWest + 6;
    final slice = MgrsLatLngBounds(
      south: visible.south,
      west: zoneWest < visible.west ? visible.west : zoneWest,
      north: visible.north,
      east: zoneEast > visible.east ? visible.east : zoneEast,
    );
    if (slice.east - slice.west < 0.05) {
      continue;
    }

    final part = _buildSingleZoneGrid(
      slice,
      spanMeters: geographicSpanMeters(slice),
      intervalOverride: intervalMeters,
      zoneNumberOverride: zone,
    );
    lines.addAll(part.lines);
    // Keep labels sparse across many zones.
    if (labels.length < 24) {
      labels.addAll(part.labels.take(2));
    }
  }

  return MgrsGridGeometry(
    lines: lines,
    labels: labels,
    accuracy: accuracy,
  );
}

MgrsGridGeometry _buildSingleZoneGrid(
  MgrsLatLngBounds visible, {
  required double spanMeters,
  int? intervalOverride,
  int? zoneNumberOverride,
}) {
  final center = LatLng(visible.centerLatitude, visible.centerLongitude);

  UTM centerUtm;
  try {
    centerUtm = Mgrs.LLtoUTM(center.latitude, center.longitude);
  } catch (_) {
    return MgrsGridGeometry.empty;
  }

  final zoneNumber = zoneNumberOverride ?? centerUtm.zoneNumber;
  final zoneLetter = centerUtm.zoneLetter;

  final zoneUtms = <UTM>[];
  for (final point in _viewportSamplePoints(visible)) {
    try {
      final utm = Mgrs.LLtoUTM(point.latitude, point.longitude);
      if (utm.zoneNumber == zoneNumber) {
        zoneUtms.add(utm);
      }
    } catch (_) {
      // Skip invalid samples.
    }
  }
  if (zoneUtms.isEmpty) {
    // Force a center sample even if LLtoUTM picks a neighbor near a boundary.
    try {
      final midLon = (visible.west + visible.east) / 2;
      zoneUtms.add(Mgrs.LLtoUTM(center.latitude, midLon));
    } catch (_) {
      zoneUtms.add(centerUtm);
    }
  }

  var minE = zoneUtms.first.easting;
  var maxE = zoneUtms.first.easting;
  var minN = zoneUtms.first.northing;
  var maxN = zoneUtms.first.northing;
  for (final utm in zoneUtms) {
    minE = utm.easting < minE ? utm.easting : minE;
    maxE = utm.easting > maxE ? utm.easting : maxE;
    minN = utm.northing < minN ? utm.northing : minN;
    maxN = utm.northing > maxN ? utm.northing : maxN;
  }

  final localSpanE = (maxE - minE).abs();
  final localSpanN = (maxN - minN).abs();
  final localSpan = localSpanE > localSpanN ? localSpanE : localSpanN;
  final effectiveSpan = localSpan > 1 ? localSpan : spanMeters;
  if (effectiveSpan < 1) {
    return MgrsGridGeometry.empty;
  }

  final intervalMeters =
      intervalOverride ?? chooseMgrsIntervalMeters(effectiveSpan);
  final accuracy = accuracyForIntervalMeters(intervalMeters);

  final pad = intervalMeters * 2.0;
  minE -= pad;
  maxE += pad;
  minN -= pad;
  maxN += pad;

  final eastings = _gridValues(minE, maxE, intervalMeters);
  final northings = _gridValues(minN, maxN, intervalMeters);
  if (eastings.isEmpty || northings.isEmpty) {
    return MgrsGridGeometry.empty;
  }

  final lines = <List<LatLng>>[];
  final labels = <MgrsGridLabel>[];
  final sampleStep = (intervalMeters / 4).clamp(250.0, 5000.0);

  for (final easting in eastings) {
    final line = _utmLine(
      zoneNumber: zoneNumber,
      zoneLetter: zoneLetter,
      fixedEasting: easting,
      varyingStart: minN,
      varyingEnd: maxN,
      sampleStep: sampleStep,
      varyNorthing: true,
    );
    if (line.length >= 2) {
      lines.add(line);
    }
  }

  for (final northing in northings) {
    final line = _utmLine(
      zoneNumber: zoneNumber,
      zoneLetter: zoneLetter,
      fixedNorthing: northing,
      varyingStart: minE,
      varyingEnd: maxE,
      sampleStep: sampleStep,
      varyNorthing: false,
    );
    if (line.length >= 2) {
      lines.add(line);
    }
  }

  if (accuracy <= 1) {
    labels.addAll(
      _coarseCellLabels(
        eastings: eastings,
        northings: northings,
        zoneNumber: zoneNumber,
        zoneLetter: zoneLetter,
        accuracy: accuracy,
      ),
    );
  } else {
    for (var i = 0; i < eastings.length; i += 2) {
      final point = _utmToLatLng(
        easting: eastings[i],
        northing: (minN + maxN) / 2,
        zoneNumber: zoneNumber,
        zoneLetter: zoneLetter,
      );
      if (point != null && _containsLatLng(visible, point)) {
        labels.add(
          MgrsGridLabel(
            point: point,
            text: _gridLineLabel(eastings[i], accuracy),
          ),
        );
      }
    }
    for (var i = 0; i < northings.length; i += 2) {
      final point = _utmToLatLng(
        easting: (minE + maxE) / 2,
        northing: northings[i],
        zoneNumber: zoneNumber,
        zoneLetter: zoneLetter,
      );
      if (point != null && _containsLatLng(visible, point)) {
        labels.add(
          MgrsGridLabel(
            point: point,
            text: _gridLineLabel(northings[i], accuracy),
          ),
        );
      }
    }
  }

  return MgrsGridGeometry(
    lines: lines,
    labels: labels,
    accuracy: accuracy,
  );
}

double _longitudeSpanDegrees(double west, double east) {
  var span = east - west;
  if (span < 0) {
    span += 360;
  }
  if (span > 360) {
    span = 360;
  }
  return span;
}

int _zoneNumberForLongitude(double longitude) {
  var lon = longitude;
  while (lon < -180) {
    lon += 360;
  }
  while (lon >= 180) {
    lon -= 360;
  }
  if (lon == 180) {
    return 60;
  }
  return ((lon + 180) / 6).floor() + 1;
}

double _zoneWestLongitude(int zoneNumber) {
  final zone = zoneNumber.clamp(1, 60);
  return (zone - 1) * 6.0 - 180.0;
}

List<int> _zonesIntersecting(double west, double east) {
  final start = _zoneNumberForLongitude(west);
  final end = _zoneNumberForLongitude(east);
  final zones = <int>[];
  if (end >= start) {
    for (var z = start; z <= end; z++) {
      zones.add(z);
    }
  } else {
    // Antimeridian wrap.
    for (var z = start; z <= 60; z++) {
      zones.add(z);
    }
    for (var z = 1; z <= end; z++) {
      zones.add(z);
    }
  }
  return zones;
}

bool _longitudeInRange(double lon, double west, double east) {
  if (east >= west) {
    return lon >= west - 0.01 && lon <= east + 0.01;
  }
  // Antimeridian wrap: visible across ±180.
  return lon >= west - 0.01 || lon <= east + 0.01;
}

double _cosDegrees(double degrees) => math.cos(degrees * math.pi / 180);

/// MGRS digit accuracy for a meter interval (0 = 100 km … 4 = 10 m).
int accuracyForIntervalMeters(int intervalMeters) {
  return switch (intervalMeters) {
    >= 100000 => 0,
    >= 10000 => 1,
    >= 1000 => 2,
    >= 100 => 3,
    _ => 4,
  };
}

/// MGRS digit accuracy (0 = 100 km … 5 = 1 m) for a map zoom level.
///
/// Used for search result zoom hints; grid spacing uses [chooseMgrsIntervalMeters].
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

List<LatLng> _viewportSamplePoints(MgrsLatLngBounds bounds) {
  const steps = 20;
  final points = <LatLng>[
    LatLng(bounds.centerLatitude, bounds.centerLongitude),
  ];
  for (var i = 0; i <= steps; i++) {
    final t = i / steps;
    final lon = bounds.west + (bounds.east - bounds.west) * t;
    final lat = bounds.south + (bounds.north - bounds.south) * t;
    points
      ..add(LatLng(bounds.south, lon))
      ..add(LatLng(bounds.north, lon))
      ..add(LatLng(lat, bounds.west))
      ..add(LatLng(lat, bounds.east));
  }
  return points;
}

bool _containsLatLng(
  MgrsLatLngBounds bounds,
  LatLng point, {
  double marginDegrees = 0,
}) {
  return point.latitude >= bounds.south - marginDegrees &&
      point.latitude <= bounds.north + marginDegrees &&
      point.longitude >= bounds.west - marginDegrees &&
      point.longitude <= bounds.east + marginDegrees;
}

List<double> _gridValues(double min, double max, int interval) {
  if (max <= min || interval <= 0) {
    return const [];
  }
  final start = (min / interval).ceil() * interval;
  final values = <double>[];
  for (var value = start.toDouble(); value <= max; value += interval) {
    values.add(value);
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
  final interval = switch (accuracy) {
    0 => 100000,
    1 => 10000,
    2 => 1000,
    3 => 100,
    _ => 10,
  };
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
