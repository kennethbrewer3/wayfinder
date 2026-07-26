import 'package:test/test.dart';

import 'package:wayfinder_server/src/map/marker_weather_watch_log.dart';

void main() {
  group('weatherReadingsChanged', () {
    test('is false when only displayUnits changes', () {
      const previous = '''
{
  "displayUnits": "metric",
  "observedAt": "2026-06-29T15:00:00.000Z",
  "temperature": 22.4,
  "temperatureUnit": "C"
}
''';
      const next = '''
{
  "displayUnits": "imperial",
  "observedAt": "2026-06-29T15:00:00.000Z",
  "temperature": 22.4,
  "temperatureUnit": "C"
}
''';
      expect(weatherReadingsChanged(previous, next), isFalse);
    });

    test('is true when temperature changes', () {
      const previous = '''
{"observedAt":"2026-06-29T15:00:00.000Z","temperature":22.4}
''';
      const next = '''
{"observedAt":"2026-06-29T16:00:00.000Z","temperature":23.1}
''';
      expect(weatherReadingsChanged(previous, next), isTrue);
    });

    test('is false when only history changes', () {
      const previous = '''
{
  "observedAt": "2026-06-29T15:00:00.000Z",
  "temperature": 22.4,
  "history": [{"observedAt":"2026-06-29T14:00:00.000Z","temperature":21.8}]
}
''';
      const next = '''
{
  "observedAt": "2026-06-29T15:00:00.000Z",
  "temperature": 22.4,
  "history": []
}
''';
      expect(weatherReadingsChanged(previous, next), isFalse);
    });

    test('is true for first reading', () {
      const next = '''
{"observedAt":"2026-06-29T15:00:00.000Z","temperature":22.4}
''';
      expect(weatherReadingsChanged(null, next), isTrue);
    });
  });

  group('formatWeatherWatchLogSummary', () {
    test('formats common fields', () {
      const json = '''
{
  "temperature": 22.4,
  "temperatureUnit": "C",
  "humidityPercent": 58,
  "condition": "Overcast",
  "windSpeed": 12,
  "windSpeedUnit": "km/h",
  "windDirectionDegrees": 225,
  "pressure": 1015,
  "pressureUnit": "hPa"
}
''';
      expect(
        formatWeatherWatchLogSummary(json),
        '22.4°C, 58% RH, Overcast, wind 12 km/h SW, 1015 hPa',
      );
    });

    test('returns null when empty', () {
      expect(formatWeatherWatchLogSummary('{"displayUnits":"metric"}'), isNull);
    });
  });

  group('weatherWatchLogSeverity', () {
    test('escalates from stationStatus', () {
      expect(
        weatherWatchLogSeverity('{"stationStatus":"sensor fault"}'),
        'critical',
      );
      expect(
        weatherWatchLogSeverity('{"stationStatus":"degraded"}'),
        'warning',
      );
      expect(weatherWatchLogSeverity('{"stationStatus":"OK"}'), 'info');
    });
  });
}
