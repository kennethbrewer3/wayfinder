import 'package:test/test.dart';

import 'package:wayfinder_server/src/tides/tide_extremes.dart';
import 'package:wayfinder_server/src/tides/tide_harmonic_predict.dart';

void main() {
  // Small fixture loosely based on Providence (8454000) major constituents,
  // already converted to meters.
  const constituents = <TideConstituent>[
    TideConstituent(
      name: 'M2',
      amplitudeMeters: 0.594,
      phaseGmtDeg: 8.6,
      speedDegPerHour: 28.984104,
    ),
    TideConstituent(
      name: 'S2',
      amplitudeMeters: 0.128,
      phaseGmtDeg: 32.6,
      speedDegPerHour: 30.0,
    ),
    TideConstituent(
      name: 'N2',
      amplitudeMeters: 0.143,
      phaseGmtDeg: 352.6,
      speedDegPerHour: 28.43973,
    ),
    TideConstituent(
      name: 'K1',
      amplitudeMeters: 0.067,
      phaseGmtDeg: 169.9,
      speedDegPerHour: 15.041069,
    ),
    TideConstituent(
      name: 'O1',
      amplitudeMeters: 0.049,
      phaseGmtDeg: 199.8,
      speedDegPerHour: 13.943035,
    ),
  ];

  group('predictTideHeightMeters', () {
    test('returns finite heights around mean level', () {
      final t = DateTime.utc(2026, 7, 19, 12);
      final h = predictTideHeightMeters(
        time: t,
        meanLevelMeters: 0.0,
        constituents: constituents,
      );
      expect(h.isFinite, isTrue);
      expect(h.abs(), lessThan(3.0));
    });

    test('series samples are finite', () {
      final series = predictTideSeries(
        start: DateTime.utc(2026, 7, 19),
        count: 40,
        step: const Duration(minutes: 6),
        meanLevelMeters: 0.1,
        constituents: constituents,
      );
      expect(series, hasLength(40));
      for (final sample in series) {
        expect(sample.heightMeters.isFinite, isTrue);
      }
    });
  });

  group('findTideExtremesForDay', () {
    test('finds highs and lows for a day', () {
      final extremes = findTideExtremesForDay(
        dayStartUtc: DateTime.utc(2026, 7, 19),
        meanLevelMeters: 0.0,
        constituents: constituents,
      );
      expect(extremes, isNotEmpty);

      final highs = extremes.where((e) => e.type == 'high').toList();
      final lows = extremes.where((e) => e.type == 'low').toList();
      expect(highs, isNotEmpty);
      expect(lows, isNotEmpty);

      for (final e in extremes) {
        expect(e.heightMeters.isFinite, isTrue);
        expect(e.type == 'high' || e.type == 'low', isTrue);
      }
    });
  });
}
