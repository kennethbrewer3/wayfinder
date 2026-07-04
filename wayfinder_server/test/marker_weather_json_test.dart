import 'package:test/test.dart';

import 'package:wayfinder_server/src/map/marker_weather_json.dart';

void main() {
  test('preserves displayUnits when new weatherJson omits it', () {
    const previous = '''
{
  "displayUnits": "imperial",
  "observedAt": "2026-06-29T15:00:00.000Z",
  "temperature": 20,
  "temperatureUnit": "C"
}
''';
    const next = '''
{
  "observedAt": "2026-06-29T16:00:00.000Z",
  "temperature": 21,
  "temperatureUnit": "C"
}
''';

    final merged = preserveWeatherJsonDisplayUnits(previous, next);
    expect(merged, isNotNull);
    expect(merged!, contains('"displayUnits":"imperial"'));
  });
}
