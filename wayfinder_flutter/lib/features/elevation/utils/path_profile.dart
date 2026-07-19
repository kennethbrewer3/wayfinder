import 'package:latlong2/latlong.dart';

import '../../lines/utils/line_distance.dart';

/// One sample along a path profile.
class PathProfileSample {
  const PathProfileSample({
    required this.distanceMeters,
    required this.elevationMeters,
    required this.point,
  });

  final double distanceMeters;
  final double elevationMeters;
  final LatLng point;
}

/// Summary stats for a DEM-sampled path.
class PathProfileStats {
  const PathProfileStats({
    required this.samples,
    required this.lengthMeters,
    required this.minElevationMeters,
    required this.maxElevationMeters,
    required this.gainMeters,
    required this.lossMeters,
  });

  final List<PathProfileSample> samples;
  final double lengthMeters;
  final double minElevationMeters;
  final double maxElevationMeters;
  final double gainMeters;
  final double lossMeters;

  bool get isEmpty => samples.isEmpty;
}

/// A named polyline leg that can be chained into a combined profile.
class PathProfileLeg {
  const PathProfileLeg({
    required this.id,
    required this.name,
    required this.points,
  });

  final String id;
  final String name;
  final List<LatLng> points;

  bool get isValid => points.length >= 2;
}

/// Chain [legs] into one continuous polyline.
///
/// Legs stay in [legs] order (selection order). Each leg after the first may be
/// reversed so its nearer endpoint connects to the current tip. Short legs
/// (&lt; 25 m) are fully included — every vertex is kept.
List<LatLng> combinePathLegs(List<PathProfileLeg> legs) {
  final usable = [
    for (final leg in legs)
      if (leg.isValid) leg,
  ];
  if (usable.isEmpty) {
    return const [];
  }

  final combined = <LatLng>[...usable.first.points];
  for (var i = 1; i < usable.length; i++) {
    final next = usable[i].points;
    final tip = combined.last;
    final toStart = lineLengthMeters(tip, next.first);
    final toEnd = lineLengthMeters(tip, next.last);
    final oriented = toEnd < toStart ? next.reversed.toList() : next;
    // Skip duplicate join vertex when legs already share an endpoint.
    final startIndex = lineLengthMeters(tip, oriented.first) < 1.0 ? 1 : 0;
    combined.addAll(oriented.skip(startIndex));
  }
  return combined;
}

/// Sample stations along [points] for DEM lookup.
///
/// Always keeps every input vertex (so short legs remain in the profile), and
/// inserts intermediates on spans longer than [minSpacingMeters], capped by
/// [maxSamples].
List<LatLng> samplePointsAlongPath(
  List<LatLng> points, {
  int maxSamples = 80,
  double minSpacingMeters = 25,
}) {
  if (points.isEmpty) {
    return const [];
  }
  if (points.length == 1) {
    return [points.first];
  }

  final densified = <LatLng>[points.first];
  for (var i = 0; i < points.length - 1; i++) {
    final start = points[i];
    final end = points[i + 1];
    final segmentLength = lineLengthMeters(start, end);
    if (segmentLength > minSpacingMeters && minSpacingMeters > 0) {
      final insertCount = (segmentLength / minSpacingMeters).floor();
      for (var step = 1; step <= insertCount; step++) {
        final distance = step * minSpacingMeters;
        if (distance >= segmentLength - 1e-6) {
          break;
        }
        densified.add(_lerp(start, end, distance / segmentLength));
      }
    }
    densified.add(end);
  }

  if (densified.length <= maxSamples) {
    return densified;
  }

  // Thin while always keeping the first and last vertices.
  final result = <LatLng>[densified.first];
  final innerCount = maxSamples - 2;
  for (var i = 1; i <= innerCount; i++) {
    final index = ((i * (densified.length - 1)) / (innerCount + 1)).round();
    final point = densified[index.clamp(1, densified.length - 2)];
    if (result.last != point) {
      result.add(point);
    }
  }
  if (result.last != densified.last) {
    result.add(densified.last);
  }
  return result;
}

/// Build profile stats from distance-ordered elevation samples.
PathProfileStats buildPathProfileStats({
  required List<LatLng> samplePoints,
  required List<double?> elevations,
}) {
  assert(samplePoints.length == elevations.length);
  final samples = <PathProfileSample>[];
  var distance = 0.0;
  double? previousElevation;
  var gain = 0.0;
  var loss = 0.0;
  var minEle = double.infinity;
  var maxEle = -double.infinity;

  for (var i = 0; i < samplePoints.length; i++) {
    if (i > 0) {
      distance += lineLengthMeters(samplePoints[i - 1], samplePoints[i]);
    }
    final elevation = elevations[i];
    if (elevation == null) {
      continue;
    }
    samples.add(
      PathProfileSample(
        distanceMeters: distance,
        elevationMeters: elevation,
        point: samplePoints[i],
      ),
    );
    minEle = elevation < minEle ? elevation : minEle;
    maxEle = elevation > maxEle ? elevation : maxEle;
    if (previousElevation != null) {
      final delta = elevation - previousElevation;
      if (delta > 0) {
        gain += delta;
      } else {
        loss += -delta;
      }
    }
    previousElevation = elevation;
  }

  if (samples.isEmpty) {
    return const PathProfileStats(
      samples: [],
      lengthMeters: 0,
      minElevationMeters: 0,
      maxElevationMeters: 0,
      gainMeters: 0,
      lossMeters: 0,
    );
  }

  return PathProfileStats(
    samples: samples,
    lengthMeters: samples.last.distanceMeters,
    minElevationMeters: minEle,
    maxElevationMeters: maxEle,
    gainMeters: gain,
    lossMeters: loss,
  );
}

LatLng _lerp(LatLng a, LatLng b, double t) {
  return LatLng(
    a.latitude + (b.latitude - a.latitude) * t,
    a.longitude + (b.longitude - a.longitude) * t,
  );
}
