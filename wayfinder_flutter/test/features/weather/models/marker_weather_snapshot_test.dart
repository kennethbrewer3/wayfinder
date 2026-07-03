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

  test('parses extended APRS weather fields', () {
    final snapshot = MarkerWeatherSnapshot.fromMarkerWeatherJson('''
{
  "observedAt": "2026-06-29T15:00:00.000Z",
  "temperature": 22.4,
  "temperatureUnit": "C",
  "dewPoint": 12.3,
  "luminosity": 850,
  "solarRadiation": 18.5,
  "uvIndex": 6,
  "snowfall": 2.5,
  "waterLevel": 1.42,
  "soilTemperature": 14.2,
  "soilMoisture": 38,
  "leafWetness": 12,
  "indoorTemperature": 21.0,
  "indoorHumidityPercent": 45,
  "batteryVoltage": 13.2,
  "windRun": 48.5,
  "stationStatus": "OK",
  "sensorHealth": "All sensors reporting"
}
''');

    expect(snapshot, isNotNull);
    final reading = snapshot!.latest;
    expect(reading.dewPoint, 12.3);
    expect(reading.luminosity, 850);
    expect(reading.solarRadiation, 18.5);
    expect(reading.uvIndex, 6);
    expect(reading.snowfall, 2.5);
    expect(reading.waterLevel, 1.42);
    expect(reading.soilTemperature, 14.2);
    expect(reading.soilMoisture, 38);
    expect(reading.leafWetness, 12);
    expect(reading.indoorTemperature, 21.0);
    expect(reading.indoorHumidityPercent, 45);
    expect(reading.batteryVoltage, 13.2);
    expect(reading.windRun, 48.5);
    expect(reading.stationStatus, 'OK');
    expect(reading.sensorHealth, 'All sensors reporting');
    expect(reading.hasMeasurements, isTrue);
  });
}
