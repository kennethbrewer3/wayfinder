import 'dart:math' as math;

import 'package:flutter/material.dart';

Offset trailTangentAt(List<Offset> points, int index) {
  if (points.length < 2) {
    return Offset.zero;
  }
  if (index == 0) {
    return points[1] - points[0];
  }
  if (index == points.length - 1) {
    return points[index] - points[index - 1];
  }
  return points[index + 1] - points[index - 1];
}

List<Offset> trailOffsetPath(List<Offset> points, double offset) {
  if (points.length < 2) {
    return const [];
  }

  final result = <Offset>[];
  for (var index = 0; index < points.length; index++) {
    final tangent = trailTangentAt(points, index);
    final length = tangent.distance;
    if (length < 0.001) {
      continue;
    }
    final normal = Offset(-tangent.dy / length, tangent.dx / length);
    result.add(points[index] + normal * offset);
  }
  return result;
}

List<Offset> trailTaperedOffsetPath(
  List<Offset> points,
  double maxOffset, {
  double minProgress = 0.0,
}) {
  if (points.length < 2) {
    return const [];
  }

  final result = <Offset>[];
  for (var index = 0; index < points.length; index++) {
    final tangent = trailTangentAt(points, index);
    final length = tangent.distance;
    if (length < 0.001) {
      continue;
    }
    final progress = index / (points.length - 1);
    final scaled = minProgress + (1 - minProgress) * progress;
    final offset = maxOffset * scaled;
    final normal = Offset(-tangent.dy / length, tangent.dx / length);
    result.add(points[index] + normal * offset);
  }
  return result;
}

void trailDrawPolyline(Canvas canvas, Paint paint, List<Offset> points) {
  if (points.length < 2) {
    return;
  }

  final path = Path()..moveTo(points.first.dx, points.first.dy);
  for (var index = 1; index < points.length; index++) {
    path.lineTo(points[index].dx, points[index].dy);
  }
  canvas.drawPath(path, paint);
}

void trailDrawTaperedPolyline(
  Canvas canvas,
  Paint paint,
  List<Offset> points,
  Color color, {
  double minAlpha = 0.25,
  double maxAlpha = 0.8,
}) {
  if (points.length < 2) {
    return;
  }

  for (var index = 0; index < points.length - 1; index++) {
    final progress = (index + 1) / (points.length - 1);
    paint.color = color.withValues(
      alpha: minAlpha + (maxAlpha - minAlpha) * progress,
    );
    canvas.drawLine(points[index], points[index + 1], paint);
  }
}

void trailDrawDashedPolyline(
  Canvas canvas,
  Paint paint,
  List<Offset> points, {
  required double dashLength,
  required double gapLength,
}) {
  if (points.length < 2) {
    return;
  }

  var drawDash = true;
  var remaining = dashLength;

  for (var index = 0; index < points.length - 1; index++) {
    final start = points[index];
    final end = points[index + 1];
    final segment = end - start;
    final segmentLength = segment.distance;
    if (segmentLength < 0.001) {
      continue;
    }

    final direction = segment / segmentLength;
    var traveled = 0.0;
    var segmentStart = start;

    while (traveled < segmentLength) {
      final segmentRemaining = segmentLength - traveled;
      final step = math.min(remaining, segmentRemaining);
      final segmentEnd = segmentStart + direction * step;

      if (drawDash) {
        canvas.drawLine(segmentStart, segmentEnd, paint);
      }

      traveled += step;
      segmentStart = segmentEnd;
      if (step >= remaining) {
        drawDash = !drawDash;
        remaining = drawDash ? dashLength : gapLength;
      } else {
        remaining -= step;
      }
    }
  }
}

List<Offset> trailWavyPath(
  List<Offset> points, {
  required double amplitude,
  required double wavelength,
}) {
  if (points.length < 2) {
    return const [];
  }

  var distance = 0.0;
  final result = <Offset>[];
  for (var index = 0; index < points.length; index++) {
    final tangent = trailTangentAt(points, index);
    final length = tangent.distance;
    if (length < 0.001) {
      result.add(points[index]);
      continue;
    }
    if (index > 0) {
      distance += (points[index] - points[index - 1]).distance;
    }
    final normal = Offset(-tangent.dy / length, tangent.dx / length);
    final wave = math.sin(distance / wavelength * math.pi * 2) * amplitude;
    result.add(points[index] + normal * wave);
  }
  return result;
}

class TrailPathMarker {
  const TrailPathMarker({
    required this.center,
    required this.travelAngle,
    required this.index,
  });

  final Offset center;
  final double travelAngle;
  final int index;
}
