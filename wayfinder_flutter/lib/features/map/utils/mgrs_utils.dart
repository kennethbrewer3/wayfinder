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
///
/// Prefer passing [longitudeCenter] / [longitudeWidth] from flutter_map's
/// [LatLngBounds]: at low zoom, clamped [west]/[east] (±180) understate the
/// true viewport when it wraps the antimeridian or spans more than one world.
class MgrsLatLngBounds {
  const MgrsLatLngBounds({
    required this.south,
    required this.west,
    required this.north,
    required this.east,
    this.longitudeCenter,
    this.longitudeWidth,
  });

  final double south;
  final double west;
  final double north;
  final double east;

  /// Camera longitude center in [-180, 180], when known from the map camera.
  final double? longitudeCenter;

  /// Visible longitude span in degrees (may exceed 360), when known.
  final double? longitudeWidth;

  double get centerLatitude => (south + north) / 2;

  double get centerLongitude =>
      longitudeCenter ?? _longitudeSpanCenter(west, east);

  /// True west edge in continuous longitude (may be below -180).
  double get unwrappedWest => centerLongitude - effectiveLongitudeWidth / 2;

  /// True east edge in continuous longitude (may be above 180).
  double get unwrappedEast => centerLongitude + effectiveLongitudeWidth / 2;

  double get effectiveLongitudeWidth {
    if (longitudeWidth != null) {
      return longitudeWidth!.clamp(0.0, 720.0);
    }
    return _longitudeSpanDegrees(west, east);
  }
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

/// Builds **correct** MGRS grid lines/labels for [bounds] at [zoom].
///
/// MGRS is UTM-based. This overlay intentionally draws real UTM/MGRS geometry
/// on a Web Mercator map, so:
/// - **GZD** (low zoom / very wide views): meridians every 6° and latitude
///   bands — straight on Web Mercator.
/// - **UTM squares** (regional / local): constant easting/northing polylines,
///   clipped per zone. Adjacent zones do not share axes, so the mesh
///   **discontinues at zone boundaries** (correct MGRS).
/// - UTM lines that are straight in UTM space can appear **slightly curved**
///   when projected to Web Mercator; that is expected, not a drawing error.
///
/// Labels are placed at cell centers (GZD or UTM squares).
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
    longitudeCenter: bounds.longitudeCenter,
    longitudeWidth: bounds.longitudeWidth,
  );
  final lonSpan = visible.effectiveLongitudeWidth;
  final spanMeters = geographicSpanMeters(visible);
  final interval = chooseMgrsIntervalMeters(spanMeters);
  final zones = _zonesIntersecting(visible.unwrappedWest, visible.unwrappedEast);

  // Zoom-primary modes so panning near zone counts does not flip the mesh.
  // Continental / world: GZD only. Regional+: clipped UTM squares.
  if (zoom < 6.0 || lonSpan >= 40) {
    return _buildGzdGrid(visible);
  }

  if (zones.length > 1 || lonSpan >= 6.5) {
    // Keep 100 km until the viewport is tight enough for 10 km.
    final meters = interval <= 10000 ? interval : 100000;
    return _buildMultiZoneGrid(visible, intervalMeters: meters);
  }

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
  final lonSpan = bounds.effectiveLongitudeWidth * 111320 * cosLat;
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
  // Use unwrapped longitude so antimeridian / multi-world viewports still get
  // a continuous mesh (clamped west/east alone cuts the grid short).
  final west = visible.unwrappedWest;
  final east = visible.unwrappedEast;
  final south = visible.south;
  final north = visible.north;

  // Vertical zone meridians every 6°, including world copies when needed.
  final firstMeridian = (west / 6).ceil() * 6.0;
  for (var lon = firstMeridian; lon <= east + 0.001; lon += 6) {
    lines.add([LatLng(south, lon), LatLng(north, lon)]);
  }

  // Horizontal latitude-band edges spanning the unwrapped viewport.
  for (final lat in _mgrsBandEdges) {
    if (lat < south - 0.01 || lat > north + 0.01) {
      continue;
    }
    lines.add([LatLng(lat, west), LatLng(lat, east)]);
  }

  return MgrsGridGeometry(
    lines: lines,
    labels: _gzdCellCenterLabels(visible),
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
  final zones = _zonesIntersecting(visible.unwrappedWest, visible.unwrappedEast);
  final south = visible.south;
  final north = visible.north;

  for (final zone in zones) {
    final zoneWest = _zoneWestLongitude(zone);
    final zoneEast = zoneWest + 6;
    // Clip strictly to the zone interior so neighboring zones never overlap.
    final sliceWest = math.max(zoneWest, visible.west);
    final sliceEast = math.min(zoneEast, visible.east);
    final slice = MgrsLatLngBounds(
      south: south,
      west: sliceWest,
      north: north,
      east: sliceEast,
    );
    if (slice.east - slice.west < 0.05) {
      continue;
    }

    // Zone seams as meridians — makes UTM discontinuities read as boundaries.
    if (zoneWest >= visible.west - 0.01 && zoneWest <= visible.east + 0.01) {
      lines.add([LatLng(south, zoneWest), LatLng(north, zoneWest)]);
    }
    if (zoneEast >= visible.west - 0.01 && zoneEast <= visible.east + 0.01) {
      lines.add([LatLng(south, zoneEast), LatLng(north, zoneEast)]);
    }

    final part = _buildSingleZoneGrid(
      slice,
      spanMeters: geographicSpanMeters(slice),
      intervalOverride: intervalMeters,
      zoneNumberOverride: zone,
      clipToVisible: true,
      includeLabels: true,
    );
    lines.addAll(part.lines);
    labels.addAll(part.labels);
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
      ? _mgrsCellCenterLabels(
          eastings: eastings,
          northings: northings,
          zoneNumber: zoneNumber,
          zoneLetter: zoneLetter,
          accuracy: accuracy,
          visible: visible,
        )
      : const <MgrsGridLabel>[];

  return MgrsGridGeometry(
    lines: lines,
    labels: labels,
    accuracy: accuracy,
  );
}

/// One GZD label at the geographic center of each visible grid-zone cell.
List<MgrsGridLabel> _gzdCellCenterLabels(MgrsLatLngBounds visible) {
  final west = visible.unwrappedWest;
  final east = visible.unwrappedEast;
  final labels = <MgrsGridLabel>[];
  final zones = _zonesIntersecting(west, east);

  // Stable stride from zone/band indices (not list order) so labels don't jump.
  final bandCount = _mgrsBandEdges.length - 1;
  final estimate = zones.length * bandCount;
  final stride = estimate <= 80 ? 1 : math.max(1, (estimate / 80).ceil());

  for (var zi = 0; zi < zones.length; zi++) {
    if (zi % stride != 0) {
      continue;
    }
    final zone = zones[zi];
    final zoneWest = _zoneWestLongitude(zone);
    final zoneEast = zoneWest + 6;
    for (var i = 0; i < bandCount; i += stride) {
      final bandSouth = _mgrsBandEdges[i];
      final bandNorth = _mgrsBandEdges[i + 1];
      if (bandNorth < visible.south || bandSouth > visible.north) {
        continue;
      }

      final centerLat = (bandSouth + bandNorth) / 2;
      for (var world = (west / 360).floor() - 1;
          world <= (east / 360).ceil() + 1;
          world++) {
        final cellWest = zoneWest + 360.0 * world;
        final cellEast = zoneEast + 360.0 * world;
        if (cellEast < west || cellWest > east) {
          continue;
        }
        final centerLon = (cellWest + cellEast) / 2;
        if (centerLon < west ||
            centerLon > east ||
            centerLat < visible.south ||
            centerLat > visible.north) {
          continue;
        }
        try {
          final letter = Mgrs.getLetterDesignator(centerLat);
          if (letter == 'Z') {
            continue;
          }
          labels.add(
            MgrsGridLabel(
              point: LatLng(centerLat, centerLon),
              text: '$zone$letter',
            ),
          );
        } catch (_) {
          // Skip invalid centers.
        }
      }
    }
  }
  return labels;
}

/// One MGRS label at the UTM center of each visible grid square.
List<MgrsGridLabel> _mgrsCellCenterLabels({
  required List<double> eastings,
  required List<double> northings,
  required int zoneNumber,
  required String zoneLetter,
  required int accuracy,
  required MgrsLatLngBounds visible,
}) {
  final labels = <MgrsGridLabel>[];
  final seen = <String>{};
  final eCells = eastings.length - 1;
  final nCells = northings.length - 1;
  if (eCells <= 0 || nCells <= 0) {
    return const [];
  }
  final estimate = eCells * nCells;
  final stride = estimate <= 64
      ? 1
      : math.max(1, math.sqrt(estimate / 64).ceil());

  for (var i = 0; i < eCells; i += stride) {
    for (var j = 0; j < nCells; j += stride) {
      final easting = (eastings[i] + eastings[i + 1]) / 2;
      final northing = (northings[j] + northings[j + 1]) / 2;
      final point = _utmToLatLng(
        easting: easting,
        northing: northing,
        zoneNumber: zoneNumber,
        zoneLetter: zoneLetter,
      );
      if (point == null ||
          !_containsLatLng(visible, point, marginDegrees: 0.0)) {
        continue;
      }
      try {
        final text = formatMgrs(latLngToMgrs(point, accuracy: accuracy));
        if (seen.add(text)) {
          labels.add(MgrsGridLabel(point: point, text: text));
        }
      } catch (_) {
        // Skip labels that fail conversion.
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
  final segments = _utmLineSegments(
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
    return [
      for (final segment in segments)
        if (segment.length >= 2) segment,
    ];
  }
  final clipped = <List<LatLng>>[];
  for (final segment in segments) {
    clipped.addAll(_clipPolylineToBounds(segment, clip));
  }
  return clipped;
}

/// Splits [points] into contiguous runs that stay inside [bounds].
List<List<LatLng>> _clipPolylineToBounds(
  List<LatLng> points,
  MgrsLatLngBounds bounds,
) {
  final runs = <List<LatLng>>[];
  List<LatLng>? current;
  for (final point in points) {
    // No positive margin: overlap at zone seams was drawing double lines.
    if (_containsLatLng(bounds, point, marginDegrees: 0.0)) {
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

double _longitudeSpanCenter(double west, double east) {
  if (east >= west) {
    return (west + east) / 2;
  }
  // Antimeridian wrap: midpoint of the wrapped arc.
  final mid = west + _longitudeSpanDegrees(west, east) / 2;
  return _normalizeLongitude(mid);
}

double _normalizeLongitude(double longitude) {
  var lon = longitude;
  while (lon < -180) {
    lon += 360;
  }
  while (lon >= 180) {
    lon -= 360;
  }
  return lon;
}

int _zoneNumberForLongitude(double longitude) {
  final lon = _normalizeLongitude(longitude);
  if (lon == 180 || lon == -180) {
    return 60;
  }
  return ((lon + 180) / 6).floor() + 1;
}

double _zoneWestLongitude(int zoneNumber) {
  final zone = zoneNumber.clamp(1, 60);
  return (zone - 1) * 6.0 - 180.0;
}

List<int> _zonesIntersecting(double west, double east) {
  // Support unwrapped continuous longitudes (e.g. -200 … 20).
  if (east - west >= 360 - 0.01) {
    return [for (var z = 1; z <= 60; z++) z];
  }
  if (east >= west && east <= 180 && west >= -180) {
    final start = _zoneNumberForLongitude(west);
    final end = _zoneNumberForLongitude(east);
    if (end >= start) {
      return [for (var z = start; z <= end; z++) z];
    }
  }

  final zones = <int>{};
  final step = math.max(0.5, (east - west).abs() / 120);
  for (var lon = west; lon <= east + 0.001; lon += step) {
    zones.add(_zoneNumberForLongitude(lon));
  }
  zones.add(_zoneNumberForLongitude(east));
  final sorted = zones.toList()..sort();
  return sorted;
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

/// Samples a constant-easting or constant-northing UTM line into segments.
///
/// Breaks the polyline when conversion fails or a sample jumps — otherwise
/// flutter_map would draw a bent chord across the gap.
List<List<LatLng>> _utmLineSegments({
  required int zoneNumber,
  required String zoneLetter,
  double? fixedEasting,
  double? fixedNorthing,
  required double varyingStart,
  required double varyingEnd,
  required double sampleStep,
  required bool varyNorthing,
}) {
  final segments = <List<LatLng>>[];
  var current = <LatLng>[];
  LatLng? previous;
  final step = sampleStep <= 0 ? 1000.0 : sampleStep;

  void endSegment() {
    if (current.length >= 2) {
      segments.add(current);
    }
    current = <LatLng>[];
    previous = null;
  }

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
    if (point == null) {
      endSegment();
      continue;
    }
    final prev = previous;
    if (prev != null) {
      final jumpLat = (point.latitude - prev.latitude).abs();
      final jumpLon = (point.longitude - prev.longitude).abs();
      if (jumpLat > 2.0 || jumpLon > 2.0) {
        endSegment();
      }
    }
    current.add(point);
    previous = point;
  }
  endSegment();
  return segments;
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
