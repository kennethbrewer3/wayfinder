import 'dart:math' as math;

/// Harmonic constituent used for simplified NOAA-style tide prediction.
class TideConstituent {
  const TideConstituent({
    required this.name,
    required this.amplitudeMeters,
    required this.phaseGmtDeg,
    required this.speedDegPerHour,
  });

  final String name;
  final double amplitudeMeters;
  final double phaseGmtDeg;
  final double speedDegPerHour;
}

/// Reference epoch for hours-since calculations (UTC).
final DateTime tidePredictionEpoch = DateTime.utc(1983, 1, 1);

/// Simplified harmonic prediction:
/// `h(t) = Z0 + Σ A_i * cos(speed_i * hours_since_ref + phase_offset)`
/// where [phase_offset] is `-phaseGmtDeg` (degrees) and the cosine argument
/// is converted to radians.
double predictTideHeightMeters({
  required DateTime time,
  required double meanLevelMeters,
  required List<TideConstituent> constituents,
}) {
  final utc = time.toUtc();
  final hours =
      utc.difference(tidePredictionEpoch).inMicroseconds /
      Duration.microsecondsPerHour;
  var height = meanLevelMeters;
  for (final c in constituents) {
    // Phase offset is -phaseGmtDeg so NOAA GMT phase lags align with
    // the cos(speed*t + φ) form used here.
    final phaseOffsetDeg = -c.phaseGmtDeg;
    final argDeg = c.speedDegPerHour * hours + phaseOffsetDeg;
    height += c.amplitudeMeters * math.cos(argDeg * math.pi / 180.0);
  }
  return height;
}

/// Predict heights at a fixed interval from [start] (inclusive) for [count] steps.
List<({DateTime time, double heightMeters})> predictTideSeries({
  required DateTime start,
  required int count,
  required Duration step,
  required double meanLevelMeters,
  required List<TideConstituent> constituents,
}) {
  final startUtc = start.toUtc();
  final results = <({DateTime time, double heightMeters})>[];
  for (var i = 0; i < count; i++) {
    final time = startUtc.add(step * i);
    results.add((
      time: time,
      heightMeters: predictTideHeightMeters(
        time: time,
        meanLevelMeters: meanLevelMeters,
        constituents: constituents,
      ),
    ));
  }
  return results;
}
