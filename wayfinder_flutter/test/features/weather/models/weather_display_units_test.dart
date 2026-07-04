import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinder_flutter/features/weather/models/marker_weather_snapshot.dart';
import 'package:wayfinder_flutter/features/weather/models/weather_display_units.dart';
import 'package:wayfinder_flutter/features/weather/models/weather_reading_formatter.dart';

void main() {
  test('reads and updates displayUnits in weatherJson', () {
    const raw = '''
{
  "displayUnits": "imperial",
  "observedAt": "2026-06-29T15:00:00.000Z",
  "temperature": 22.4,
  "temperatureUnit": "C"
}
''';

    expect(readWeatherDisplayUnits(raw), WeatherDisplayUnits.imperial);

    final updated = updateWeatherJsonDisplayUnits(
      raw,
      WeatherDisplayUnits.metric,
    );
    expect(readWeatherDisplayUnits(updated), WeatherDisplayUnits.metric);
    expect(
      MarkerWeatherSnapshot.fromMarkerWeatherJson(updated)?.displayUnits,
      WeatherDisplayUnits.metric,
    );
  });

  test('formats weather readings in imperial units', () {
    final reading = MarkerWeatherReading(
      observedAt: DateTime.utc(2026, 6, 29, 15),
      temperature: 0,
      temperatureUnit: 'C',
      windSpeed: 36,
      windSpeedUnit: 'km/h',
      windDirectionDegrees: 90,
      precipitation: 25.4,
      precipitationUnit: 'mm',
      pressure: 1013.25,
      pressureUnit: 'hPa',
    );
    final formatter = WeatherReadingFormatter(
      reading: reading,
      displayUnits: WeatherDisplayUnits.imperial,
    );

    expect(formatter.formatTemperature(0, 'C'), '32°F');
    expect(formatter.formatWindSpeed(), '22 mph E');
    expect(formatter.formatPrecipitation(), '1.0in');
    expect(formatter.formatPressure(), '29.92 inHg');
  });
}
