import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../lines/utils/bearing_utils.dart';

/// Rough cross-country cost from slope degrees (higher = harder).
///
/// Tuned as a simple walk/drive heuristic, not a mobility model:
/// gentle grades stay cheap; steep slopes rise quickly toward impassable.
double crossCountryCostFromSlopeDegrees(double slopeDegrees) {
  final s = slopeDegrees.clamp(0.0, 90.0);
  if (s <= 3) {
    return s / 3 * 0.15;
  }
  if (s <= 8) {
    return 0.15 + (s - 3) / 5 * 0.25;
  }
  if (s <= 15) {
    return 0.40 + (s - 8) / 7 * 0.25;
  }
  if (s <= 25) {
    return 0.65 + (s - 15) / 10 * 0.20;
  }
  if (s <= 35) {
    return 0.85 + (s - 25) / 10 * 0.15;
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

/// Grid step for a slope analysis of [rangeMeters] half-width.
double slopeStepMetersForRange(double rangeMeters, {int targetCells = 40}) {
  final safeRange = rangeMeters.clamp(200.0, 15000.0);
  return (safeRange * 2 / targetCells).clamp(25.0, 250.0);
}

int slopeGridSizeForRange(double rangeMeters, double stepMeters) {
  if (stepMeters <= 0) {
    return 2;
  }
  final cells = ((rangeMeters * 2) / stepMeters).ceil() + 1;
  return cells.clamp(8, 64);
}

/// Build sample points for a square DEM grid centered on [center].
///
/// Returns row-major points (north → south rows, west → east within row).
List<LatLng> slopeGridSamplePoints({
  required LatLng center,
  required double rangeMeters,
  required double stepMeters,
}) {
  final half = rangeMeters;
  final size = slopeGridSizeForRange(rangeMeters, stepMeters);
  final points = <LatLng>[];
  for (var row = 0; row < size; row++) {
    final northOffset = half - row * stepMeters;
    final rowAnchor = pointAtTrueBearing(
      anchor: center,
      bearingDegrees: northOffset >= 0 ? 0 : 180,
      distanceMeters: northOffset.abs(),
    );
    for (var col = 0; col < size; col++) {
      final eastOffset = -half + col * stepMeters;
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
              crossCountryCostFromSlopeDegrees(slope),
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
