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

/// Evenly distribute sample stations along [points] by distance.
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

  final total = lineLengthMetersForPoints(points);
  if (total <= 0) {
    return [points.first];
  }

  final spacing = (total / (maxSamples - 1)).clamp(minSpacingMeters, total);
  final count = (total / spacing).ceil().clamp(2, maxSamples);
  final step = total / (count - 1);
  final result = <LatLng>[points.first];
  var walked = 0.0;
  var target = step;
  var segmentIndex = 0;
  var segmentStart = points.first;
  var segmentEnd = points[1];
  var segmentLength = lineLengthMeters(segmentStart, segmentEnd);
  var alongSegment = 0.0;

  while (result.length < count && segmentIndex < points.length - 1) {
    final remaining = segmentLength - alongSegment;
    final need = target - walked;
    if (remaining >= need - 1e-6) {
      final t = segmentLength <= 0
          ? 0.0
          : (alongSegment + need) / segmentLength;
      result.add(_lerp(segmentStart, segmentEnd, t.clamp(0.0, 1.0)));
      alongSegment += need;
      walked = target;
      target += step;
      continue;
    }

    walked += remaining;
    segmentIndex += 1;
    if (segmentIndex >= points.length - 1) {
      break;
    }
    alongSegment = 0;
    segmentStart = points[segmentIndex];
    segmentEnd = points[segmentIndex + 1];
    segmentLength = lineLengthMeters(segmentStart, segmentEnd);
  }

  if (result.last != points.last) {
    result.add(points.last);
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
