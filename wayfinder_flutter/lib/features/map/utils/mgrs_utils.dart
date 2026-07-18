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
/// Mode is chosen from geographic span:
/// - World-scale → GZD (6° × latitude-band) mesh
/// - Multi-zone → clipped UTM grids per zone (no cross-zone bleed)
/// - Local → single-zone UTM grid
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
  final interval = chooseMgrsIntervalMeters(spanMeters);
  final zones = _zonesIntersecting(visible.west, visible.east);

  // True world / hemisphere views: GZD only (balanced vertical + horizontal).
  if (zoom < 4.5 || lonSpan >= 90 || (interval >= 100000 && zones.length > 12)) {
    return _buildGzdGrid(visible);
  }

  // Several UTM zones visible: clipped per-zone grid at 100 km / 10 km.
  if (zones.length > 1 || lonSpan >= 6.5) {
    final regionalInterval = interval <= 10000 ? interval : 10000;
    // Prefer 100 km when many zones so horizontals stay readable.
    final meters = zones.length >= 4 && regionalInterval < 100000
        ? 100000
        : regionalInterval < 10000
        ? 10000
        : regionalInterval;
    return _buildMultiZoneGrid(visible, intervalMeters: meters);
  }

  // Single zone — ignore unused zoom once span drives interval.
  return _buildSingleZoneGrid(
    visible,
    spanMeters: spanMeters,
    intervalOverride: interval,
  );
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
  final west = visible.west;
  final east = visible.east;
  final south = visible.south;
  final north = visible.north;

  // Vertical zone meridians every 6°.
  for (var lon = -180.0; lon <= 180.0 + 0.001; lon += 6) {
    if (!_longitudeInRange(lon, west, east)) {
      continue;
    }
    lines.add([LatLng(south, lon), LatLng(north, lon)]);
  }

  // Horizontal latitude-band edges every 8° (12° for X).
  for (final lat in _mgrsBandEdges) {
    if (lat < south - 0.01 || lat > north + 0.01) {
      continue;
    }
    lines.add([LatLng(lat, west), LatLng(lat, east)]);
  }

  // Evenly spaced GZD labels across the viewport (not one-per-cell flood).
  final labels = _distributedGzdLabels(visible, maxLabels: 18);

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
  final zones = _zonesIntersecting(visible.west, visible.east);

  for (final zone in zones) {
    final zoneWest = _zoneWestLongitude(zone);
    final zoneEast = zoneWest + 6;
    final slice = MgrsLatLngBounds(
      south: visible.south,
      west: math.max(zoneWest, visible.west),
      north: visible.north,
      east: math.min(zoneEast, visible.east),
    );
    if (slice.east - slice.west < 0.05) {
      continue;
    }

    final part = _buildSingleZoneGrid(
      slice,
      spanMeters: geographicSpanMeters(slice),
      intervalOverride: intervalMeters,
      zoneNumberOverride: zone,
      clipToVisible: true,
      includeLabels: false,
    );
    lines.addAll(part.lines);
  }

  return MgrsGridGeometry(
    lines: lines,
    labels: _distributedMgrsLabels(
      visible,
      accuracy: accuracy,
      maxLabels: 16,
    ),
    accuracy: accuracy,
  );
}

MgrsGridGeometry _buildSingleZoneGrid(
  MgrsLatLngBounds visible, {
  required double spanMeters,
  int? intervalOverride,
  int? zoneNumberOverride,
  bool clipToVisible = false,
  bool includeLabels = true,
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
    minE = math.min(minE, utm.easting);
    maxE = math.max(maxE, utm.easting);
    minN = math.min(minN, utm.northing);
    maxN = math.max(maxN, utm.northing);
  }

  final localSpanE = (maxE - minE).abs();
  final localSpanN = (maxN - minN).abs();
  final localSpan = math.max(localSpanE, localSpanN);
  final effectiveSpan = localSpan > 1 ? localSpan : spanMeters;
  if (effectiveSpan < 1) {
    return MgrsGridGeometry.empty;
  }

  final intervalMeters =
      intervalOverride ?? chooseMgrsIntervalMeters(effectiveSpan);
  final accuracy = accuracyForIntervalMeters(intervalMeters);

  final pad = intervalMeters * 1.5;
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
  final sampleStep = (intervalMeters / 4).clamp(250.0, 5000.0);
  final clip = clipToVisible ? visible : null;

  for (final easting in eastings) {
    lines.addAll(
      _utmLineClipped(
        zoneNumber: zoneNumber,
        zoneLetter: zoneLetter,
        fixedEasting: easting,
        varyingStart: minN,
        varyingEnd: maxN,
        sampleStep: sampleStep,
        varyNorthing: true,
        clip: clip,
      ),
    );
  }

  for (final northing in northings) {
    lines.addAll(
      _utmLineClipped(
        zoneNumber: zoneNumber,
        zoneLetter: zoneLetter,
        fixedNorthing: northing,
        varyingStart: minE,
        varyingEnd: maxE,
        sampleStep: sampleStep,
        varyNorthing: false,
        clip: clip,
      ),
    );
  }

  final labels = includeLabels
      ? _distributedMgrsLabels(
          visible,
          accuracy: accuracy,
          maxLabels: accuracy <= 1 ? 14 : 12,
        )
      : const <MgrsGridLabel>[];

  return MgrsGridGeometry(
    lines: lines,
    labels: labels,
    accuracy: accuracy,
  );
}

/// Evenly spaced GZD labels (e.g. `18S`) across the viewport.
List<MgrsGridLabel> _distributedGzdLabels(
  MgrsLatLngBounds visible, {
  required int maxLabels,
}) {
  final lonSpan = _longitudeSpanDegrees(visible.west, visible.east);
  final latSpan = (visible.north - visible.south).abs().clamp(1.0, 180.0);
  final aspect = lonSpan / latSpan;
  final cols = math.sqrt(maxLabels * aspect).round().clamp(2, 6);
  final rows = math.max(2, (maxLabels / cols).round());

  final labels = <MgrsGridLabel>[];
  final seen = <String>{};
  for (var row = 0; row < rows; row++) {
    for (var col = 0; col < cols; col++) {
      final lat =
          visible.south + (visible.north - visible.south) * (row + 0.5) / rows;
      final lon =
          visible.west + (visible.east - visible.west) * (col + 0.5) / cols;
      try {
        final zone = _zoneNumberForLongitude(lon);
        final letter = Mgrs.getLetterDesignator(lat);
        if (letter == 'Z') {
          continue;
        }
        final text = '$zone$letter';
        if (seen.add(text)) {
          labels.add(MgrsGridLabel(point: LatLng(lat, lon), text: text));
        }
      } catch (_) {
        // Skip invalid samples.
      }
    }
  }
  return labels;
}

/// Evenly spaced MGRS labels across the viewport at [accuracy].
List<MgrsGridLabel> _distributedMgrsLabels(
  MgrsLatLngBounds visible, {
  required int accuracy,
  required int maxLabels,
}) {
  final lonSpan = _longitudeSpanDegrees(visible.west, visible.east).clamp(
    0.01,
    360.0,
  );
  final latSpan = (visible.north - visible.south).abs().clamp(0.01, 180.0);
  final aspect = lonSpan / latSpan;
  final cols = math.sqrt(maxLabels * aspect).round().clamp(2, 5);
  final rows = math.max(2, (maxLabels / cols).round());

  final labels = <MgrsGridLabel>[];
  final seen = <String>{};
  for (var row = 0; row < rows; row++) {
    for (var col = 0; col < cols; col++) {
      final lat =
          visible.south + (visible.north - visible.south) * (row + 0.5) / rows;
      final lon =
          visible.west + (visible.east - visible.west) * (col + 0.5) / cols;
      final point = LatLng(lat, lon);
      try {
        final text = formatMgrs(latLngToMgrs(point, accuracy: accuracy));
        if (seen.add(text)) {
          labels.add(MgrsGridLabel(point: point, text: text));
        }
      } catch (_) {
        // Polar / invalid.
      }
    }
  }
  return labels;
}

List<List<LatLng>> _utmLineClipped({
  required int zoneNumber,
  required String zoneLetter,
  double? fixedEasting,
  double? fixedNorthing,
  required double varyingStart,
  required double varyingEnd,
  required double sampleStep,
  required bool varyNorthing,
  MgrsLatLngBounds? clip,
}) {
  final raw = _utmLine(
    zoneNumber: zoneNumber,
    zoneLetter: zoneLetter,
    fixedEasting: fixedEasting,
    fixedNorthing: fixedNorthing,
    varyingStart: varyingStart,
    varyingEnd: varyingEnd,
    sampleStep: sampleStep,
    varyNorthing: varyNorthing,
  );
  if (clip == null) {
    return raw.length >= 2 ? [raw] : const [];
  }
  return _clipPolylineToBounds(raw, clip);
}

/// Splits [points] into contiguous runs that stay inside [bounds].
List<List<LatLng>> _clipPolylineToBounds(
  List<LatLng> points,
  MgrsLatLngBounds bounds,
) {
  final runs = <List<LatLng>>[];
  List<LatLng>? current;
  for (final point in points) {
    if (_containsLatLng(bounds, point, marginDegrees: 0.05)) {
      current ??= <LatLng>[];
      current.add(point);
    } else if (current != null) {
      if (current.length >= 2) {
        runs.add(current);
      }
      current = null;
    }
  }
  if (current != null && current.length >= 2) {
    runs.add(current);
  }
  return runs;
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
