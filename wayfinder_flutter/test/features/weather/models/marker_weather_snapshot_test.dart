import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/weather/models/marker_weather_snapshot.dart';

void main() {
  test('parses latest weather reading from marker weatherJson', () {
    final snapshot = MarkerWeatherSnapshot.fromMarkerWeatherJson('''
{
  "observedAt": "2026-06-29T15:00:00.000Z",
  "source": "aprs",
  "temperature": 22.4,
  "temperatureUnit": "C",
  "humidityPercent": 58,
  "weatherCode": 3,
  "windSpeed": 12.0,
  "windSpeedUnit": "km/h",
  "windDirectionDegrees": 225,
  "pressure": 1015.0
}
''');

    expect(snapshot, isNotNull);
    expect(snapshot!.latest.temperature, 22.4);
    expect(snapshot.latest.source, 'aprs');
    expect(
      weatherConditionPresentationForCode(snapshot.latest.weatherCode!).labelKey,
      WeatherConditionLabel.overcast,
    );
    expect(formatCompassDirection(snapshot.latest.windDirectionDegrees), 'SW');
  });

  test('parses weather history entries', () {
    final snapshot = MarkerWeatherSnapshot.fromMarkerWeatherJson('''
{
  "observedAt": "2026-06-29T15:00:00.000Z",
  "temperature": 20,
  "condition": "Rain",
  "history": [
    {
      "observedAt": "2026-06-29T14:00:00.000Z",
      "temperature": 19,
      "condition": "Cloudy"
    }
  ]
}
''');

    expect(snapshot, isNotNull);
    expect(snapshot!.history.length, 1);
    expect(snapshot.latest.temperature, 20);
    expect(
      weatherConditionPresentation(condition: 'Rain').displayLabel,
      'Rain',
    );
  });

  test('returns null for empty weatherJson', () {
    expect(MarkerWeatherSnapshot.fromMarkerWeatherJson(null), isNull);
    expect(MarkerWeatherSnapshot.fromMarkerWeatherJson(''), isNull);
  });
}
