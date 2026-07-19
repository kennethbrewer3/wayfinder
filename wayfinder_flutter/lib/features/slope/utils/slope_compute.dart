import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../lines/utils/bearing_utils.dart';

/// How slope is interpreted as travel difficulty.
enum SlopeMobilityMode {
  /// On foot — tolerates steeper grades than bike/drive.
  walk,

  /// Bicycle — cost rises early; sustained climbs are hard.
  bike,

  /// Vehicle — gentle/highway grades stay cheap; steep terrain costly.
  drive,
}

/// Rough cross-country cost from slope degrees (higher = harder).
///
/// DEM slope only — ignores roads, trails, vegetation, and surface.
/// Curves differ by [mode] so the same hill can be green for driving
/// and yellow/red for walking or cycling.
double crossCountryCostFromSlopeDegrees(
  double slopeDegrees, {
  SlopeMobilityMode mode = SlopeMobilityMode.walk,
}) {
  final s = slopeDegrees.clamp(0.0, 90.0);
  return switch (mode) {
    SlopeMobilityMode.walk => _walkCost(s),
    SlopeMobilityMode.bike => _bikeCost(s),
    SlopeMobilityMode.drive => _driveCost(s),
  };
}

double _lerpCost(double s, double lo, double hi, double c0, double c1) {
  if (s <= lo) {
    return c0;
  }
  if (s >= hi) {
    return c1;
  }
  return c0 + (s - lo) / (hi - lo) * (c1 - c0);
}

/// Walk: fine through trail grades; hard above ~30°.
double _walkCost(double s) {
  if (s <= 5) {
    return _lerpCost(s, 0, 5, 0, 0.12);
  }
  if (s <= 12) {
    return _lerpCost(s, 5, 12, 0.12, 0.35);
  }
  if (s <= 20) {
    return _lerpCost(s, 12, 20, 0.35, 0.60);
  }
  if (s <= 30) {
    return _lerpCost(s, 20, 30, 0.60, 0.85);
  }
  if (s <= 40) {
    return _lerpCost(s, 30, 40, 0.85, 1.0);
  }
  return 1.0;
}

/// Bike: climbs hurt early; ~18°+ treated as near-impassable.
double _bikeCost(double s) {
  if (s <= 2) {
    return _lerpCost(s, 0, 2, 0, 0.10);
  }
  if (s <= 5) {
    return _lerpCost(s, 2, 5, 0.10, 0.40);
  }
  if (s <= 8) {
    return _lerpCost(s, 5, 8, 0.40, 0.65);
  }
  if (s <= 12) {
    return _lerpCost(s, 8, 12, 0.65, 0.85);
  }
  if (s <= 18) {
    return _lerpCost(s, 12, 18, 0.85, 1.0);
  }
  return 1.0;
}

/// Drive: highway grades stay cheap; steep off-road / mountain costly.
double _driveCost(double s) {
  if (s <= 3) {
    return _lerpCost(s, 0, 3, 0, 0.10);
  }
  if (s <= 6) {
    return _lerpCost(s, 3, 6, 0.10, 0.30);
  }
  if (s <= 10) {
    return _lerpCost(s, 6, 10, 0.30, 0.55);
  }
  if (s <= 15) {
    return _lerpCost(s, 10, 15, 0.55, 0.80);
  }
  if (s <= 25) {
    return _lerpCost(s, 15, 25, 0.80, 1.0);
  }
  return 1.0;
}

/// Color for slope degrees: green → yellow → orange → red.
Color slopeColorForDegrees(double slopeDegrees, {double alpha = 0.55}) {
  final t = (slopeDegrees / 35.0).clamp(0.0, 1.0);
  final hue = 120.0 * (1.0 - t); // 120 green → 0 red
  return HSVColor.fromAHSV(alpha, hue, 0.85, 0.95).toColor();
}

Color costColorForValue(double cost, {double alpha = 0.55}) {
  final t = cost.clamp(0.0, 1.0);
  final hue = 120.0 * (1.0 - t);
  return HSVColor.fromAHSV(alpha, hue, 0.85, 0.95).toColor();
}

/// Horn-style slope in degrees from a 3×3 elevation window (meters).
///
/// Layout:
/// ```
/// z1 z2 z3
/// z4 z5 z6
/// z7 z8 z9
/// ```
/// [cellSizeMeters] is the spacing between neighbors (E-W and N-S).
double? slopeDegreesFromNeighborhood({
  required double? z1,
  required double? z2,
  required double? z3,
  required double? z4,
  required double? z5,
  required double? z6,
  required double? z7,
  required double? z8,
  required double? z9,
  required double cellSizeMeters,
}) {
  if (cellSizeMeters <= 0) {
    return null;
  }
  // Require center + the four orthogonal neighbors used by Horn.
  if (z2 == null || z4 == null || z5 == null || z6 == null || z8 == null) {
    return null;
  }
  final zz1 = z1 ?? z2;
  final zz3 = z3 ?? z2;
  final zz7 = z7 ?? z8;
  final zz9 = z9 ?? z8;

  final dzdx =
      ((zz3 + 2 * z6 + zz9) - (zz1 + 2 * z4 + zz7)) / (8 * cellSizeMeters);
  final dzdy =
      ((zz7 + 2 * z8 + zz9) - (zz1 + 2 * z2 + zz3)) / (8 * cellSizeMeters);
  final riseRun = math.sqrt(dzdx * dzdx + dzdy * dzdy);
  return math.atan(riseRun) * 180 / math.pi;
}

/// Minimum / maximum analysis radius (half-width of the square grid).
const minSlopeRangeMeters = 200.0;

/// ~50 miles — enough for regional drive-range overviews.
const maxSlopeRangeMeters = 50 * 1609.344;

/// Grid layout that always spans [rangeMeters] in every direction.
///
/// Cell count stays bounded for DEM sampling cost; step coarsens as range
/// grows so a 50‑mile radius still paints the full circle.
({int size, double stepMeters}) slopeGridLayoutForRange(double rangeMeters) {
  final safeRange = rangeMeters.clamp(minSlopeRangeMeters, maxSlopeRangeMeters);
  final size = switch (safeRange) {
    <= 2000 => 41,
    <= 10000 => 49,
    <= 30000 => 57,
    _ => 64,
  };
  final step = (2 * safeRange) / (size - 1);
  return (size: size, stepMeters: step);
}

/// Grid step for a slope analysis of [rangeMeters] half-width.
double slopeStepMetersForRange(double rangeMeters) {
  return slopeGridLayoutForRange(rangeMeters).stepMeters;
}

int slopeGridSizeForRange(double rangeMeters, [double? stepMeters]) {
  return slopeGridLayoutForRange(rangeMeters).size;
}

/// Build sample points for a square DEM grid centered on [center].
///
/// Returns row-major points (north → south rows, west → east within row).
/// The grid always spans [−rangeMeters, +rangeMeters] on both axes.
List<LatLng> slopeGridSamplePoints({
  required LatLng center,
  required double rangeMeters,
  required double stepMeters,
}) {
  final half = rangeMeters.clamp(minSlopeRangeMeters, maxSlopeRangeMeters);
  final size = slopeGridSizeForRange(half, stepMeters);
  // Re-derive step so the last cell lands exactly on −half even if the
  // caller’s step was slightly inconsistent with size.
  final step = size <= 1 ? stepMeters : (2 * half) / (size - 1);
  final points = <LatLng>[];
  for (var row = 0; row < size; row++) {
    final northOffset = half - row * step;
    final rowAnchor = pointAtTrueBearing(
      anchor: center,
      bearingDegrees: northOffset >= 0 ? 0 : 180,
      distanceMeters: northOffset.abs(),
    );
    for (var col = 0; col < size; col++) {
      final eastOffset = -half + col * step;
      points.add(
        pointAtTrueBearing(
          anchor: rowAnchor,
          bearingDegrees: eastOffset >= 0 ? 90 : 270,
          distanceMeters: eastOffset.abs(),
        ),
      );
    }
  }
  return points;
}

LatLngBounds slopeBoundsForCenter({
  required LatLng center,
  required double rangeMeters,
}) {
  final north = pointAtTrueBearing(
    anchor: center,
    bearingDegrees: 0,
    distanceMeters: rangeMeters,
  );
  final south = pointAtTrueBearing(
    anchor: center,
    bearingDegrees: 180,
    distanceMeters: rangeMeters,
  );
  final east = pointAtTrueBearing(
    anchor: center,
    bearingDegrees: 90,
    distanceMeters: rangeMeters,
  );
  final west = pointAtTrueBearing(
    anchor: center,
    bearingDegrees: 270,
    distanceMeters: rangeMeters,
  );
  return LatLngBounds(
    LatLng(south.latitude, west.longitude),
    LatLng(north.latitude, east.longitude),
  );
}

/// Compute per-cell slope degrees for a square elevation grid (row-major).
List<double?> slopeDegreesGrid({
  required List<double?> elevations,
  required int size,
  required double cellSizeMeters,
}) {
  assert(elevations.length == size * size);
  final slopes = List<double?>.filled(size * size, null);
  for (var row = 0; row < size; row++) {
    for (var col = 0; col < size; col++) {
      double? at(int r, int c) {
        if (r < 0 || c < 0 || r >= size || c >= size) {
          return null;
        }
        return elevations[r * size + c];
      }

      slopes[row * size + col] = slopeDegreesFromNeighborhood(
        z1: at(row - 1, col - 1),
        z2: at(row - 1, col),
        z3: at(row - 1, col + 1),
        z4: at(row, col - 1),
        z5: at(row, col),
        z6: at(row, col + 1),
        z7: at(row + 1, col - 1),
        z8: at(row + 1, col),
        z9: at(row + 1, col + 1),
        cellSizeMeters: cellSizeMeters,
      );
    }
  }
  return slopes;
}

/// Encode a slope/cost grid as an RGBA PNG (row 0 = north).
Future<Uint8List> encodeSlopeHeatmapPng({
  required List<double?> slopesDegrees,
  required int size,
  required bool colorByCost,
  SlopeMobilityMode mobilityMode = SlopeMobilityMode.walk,
  double opacity = 0.55,
}) async {
  assert(slopesDegrees.length == size * size);
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final paint = Paint()..style = PaintingStyle.fill;

  for (var row = 0; row < size; row++) {
    for (var col = 0; col < size; col++) {
      final slope = slopesDegrees[row * size + col];
      if (slope == null) {
        continue;
      }
      final color = colorByCost
          ? costColorForValue(
              crossCountryCostFromSlopeDegrees(slope, mode: mobilityMode),
              alpha: opacity,
            )
          : slopeColorForDegrees(slope, alpha: opacity);
      paint.color = color;
      canvas.drawRect(
        Rect.fromLTWH(col.toDouble(), row.toDouble(), 1, 1),
        paint,
      );
    }
  }

  final picture = recorder.endRecording();
  final image = await picture.toImage(size, size);
  try {
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) {
      return Uint8List(0);
    }
    return bytes.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}
