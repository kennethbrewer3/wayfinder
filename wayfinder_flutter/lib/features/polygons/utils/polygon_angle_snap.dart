import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Soft-snap radius (screen px). Drag farther than this to escape the snap.
const polygonAngleSnapRadiusPx = 16.0;

/// Soft-snaps [proposed] while dragging polygon vertex [vertexIndex].
///
/// When [snapRightAngles] is on, candidates include:
/// - points that make the angle at the dragged vertex 90° (Thales circle)
/// - points that make either adjacent corner 90° (perpendicular through neighbor)
///
/// When [snapFortyFiveAngles] is on, also targets 45° / 135° at the dragged
/// vertex (inscribed-angle loci).
///
/// Returns [proposed] unchanged when no candidate is within
/// [snapRadiusPx], so continued dragging breaks free of the snap.
LatLng snapPolygonVertexAngle({
  required List<LatLng> points,
  required int vertexIndex,
  required LatLng proposed,
  required MapCamera camera,
  bool snapRightAngles = false,
  bool snapFortyFiveAngles = false,
  double snapRadiusPx = polygonAngleSnapRadiusPx,
}) {
  if ((!snapRightAngles && !snapFortyFiveAngles) ||
      points.length < 3 ||
      vertexIndex < 0 ||
      vertexIndex >= points.length) {
    return proposed;
  }

  final n = points.length;
  final prev = points[(vertexIndex - 1 + n) % n];
  final next = points[(vertexIndex + 1) % n];
  final prevPrev = points[(vertexIndex - 2 + n) % n];
  final nextNext = points[(vertexIndex + 2) % n];

  final proposedScreen = camera.latLngToScreenOffset(proposed);
  final candidates = <Offset>[];

  final targetDegrees = <double>{
    if (snapRightAngles) 90,
    if (snapFortyFiveAngles) ...const [45, 90, 135],
  };

  for (final degrees in targetDegrees) {
    candidates.addAll(
      inscribedAngleSnapCandidates(
        a: camera.latLngToScreenOffset(prev),
        b: camera.latLngToScreenOffset(next),
        proposed: proposedScreen,
        angleDegrees: degrees,
      ),
    );
  }

  if (snapRightAngles) {
    // Square the corner behind / ahead of the dragged vertex (rectangle aid).
    candidates.add(
      projectOntoPerpendicularThroughPivot(
        pivot: camera.latLngToScreenOffset(prev),
        from: camera.latLngToScreenOffset(prevPrev),
        proposed: proposedScreen,
      ),
    );
    candidates.add(
      projectOntoPerpendicularThroughPivot(
        pivot: camera.latLngToScreenOffset(next),
        from: camera.latLngToScreenOffset(nextNext),
        proposed: proposedScreen,
      ),
    );
  }

  Offset? best;
  var bestDistance = snapRadiusPx;
  for (final candidate in candidates) {
    final distance = (candidate - proposedScreen).distance;
    if (distance <= bestDistance) {
      bestDistance = distance;
      best = candidate;
    }
  }

  if (best == null) {
    return proposed;
  }
  return camera.screenOffsetToLatLng(best);
}

/// Points P such that ∠APB ≈ [angleDegrees], near [proposed] on the locus.
List<Offset> inscribedAngleSnapCandidates({
  required Offset a,
  required Offset b,
  required Offset proposed,
  required double angleDegrees,
}) {
  final chord = b - a;
  final chordLength = chord.distance;
  if (chordLength < 8) {
    return const [];
  }

  final angleRad = angleDegrees * math.pi / 180;
  final sinAngle = math.sin(angleRad);
  if (sinAngle.abs() < 1e-6) {
    return const [];
  }

  // Inscribed angle θ ⇒ circle radius r = chord / (2 sin θ).
  final radius = chordLength / (2 * sinAngle);
  final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
  final unitAlong = chord / chordLength;
  final unitPerp = Offset(-unitAlong.dy, unitAlong.dx);
  final centerOffset = math.sqrt(
    math.max(0, radius * radius - (chordLength / 2) * (chordLength / 2)),
  );

  final centers = <Offset>[
    mid + unitPerp * centerOffset,
    mid - unitPerp * centerOffset,
  ];

  final results = <Offset>[];
  for (final center in centers) {
    final fromCenter = proposed - center;
    final distance = fromCenter.distance;
    if (distance < 1e-6) {
      continue;
    }
    final onCircle = center + fromCenter * (radius / distance);
    // Reject near A/B (degenerate thin spikes).
    if ((onCircle - a).distance < 10 || (onCircle - b).distance < 10) {
      continue;
    }
    results.add(onCircle);
  }
  return results;
}

/// Project [proposed] onto the line through [pivot] perpendicular to [from]→[pivot].
Offset projectOntoPerpendicularThroughPivot({
  required Offset pivot,
  required Offset from,
  required Offset proposed,
}) {
  final incoming = pivot - from;
  final length = incoming.distance;
  if (length < 1e-6) {
    return proposed;
  }
  final perp = Offset(-incoming.dy, incoming.dx) / length;
  final relative = proposed - pivot;
  final along = relative.dx * perp.dx + relative.dy * perp.dy;
  return pivot + perp * along;
}
