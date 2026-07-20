import 'tide_harmonic_predict.dart';

/// A local high or low tide extremum.
class TideExtremePoint {
  const TideExtremePoint({
    required this.time,
    required this.heightMeters,
    required this.type,
  });

  final DateTime time;
  final double heightMeters;

  /// `high` or `low`.
  final String type;
}

/// Sample every 6 minutes over [dayStartUtc] (24h) and find local max/min.
List<TideExtremePoint> findTideExtremesForDay({
  required DateTime dayStartUtc,
  required double meanLevelMeters,
  required List<TideConstituent> constituents,
}) {
  const step = Duration(minutes: 6);
  const samplesPerDay = 24 * 60 ~/ 6; // 240
  final series = predictTideSeries(
    start: dayStartUtc.toUtc(),
    count: samplesPerDay + 1,
    step: step,
    meanLevelMeters: meanLevelMeters,
    constituents: constituents,
  );
  return findTideExtremesInSeries(series);
}

/// Detect local maxima/minima in a densely sampled series.
List<TideExtremePoint> findTideExtremesInSeries(
  List<({DateTime time, double heightMeters})> series,
) {
  if (series.length < 3) {
    return const [];
  }

  final extremes = <TideExtremePoint>[];
  for (var i = 1; i < series.length - 1; i++) {
    final prev = series[i - 1].heightMeters;
    final curr = series[i].heightMeters;
    final next = series[i + 1].heightMeters;

    if (curr > prev && curr >= next) {
      extremes.add(
        TideExtremePoint(
          time: series[i].time,
          heightMeters: curr,
          type: 'high',
        ),
      );
    } else if (curr < prev && curr <= next) {
      extremes.add(
        TideExtremePoint(
          time: series[i].time,
          heightMeters: curr,
          type: 'low',
        ),
      );
    }
  }
  return extremes;
}
