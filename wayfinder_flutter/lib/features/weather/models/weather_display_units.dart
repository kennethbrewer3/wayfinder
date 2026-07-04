import 'dart:convert';

enum WeatherDisplayUnits {
  metric,
  imperial,
}

const weatherJsonDisplayUnitsField = 'displayUnits';

WeatherDisplayUnits weatherDisplayUnitsFromStorage(String? value) {
  return switch (value?.toLowerCase()) {
    'imperial' => WeatherDisplayUnits.imperial,
    _ => WeatherDisplayUnits.metric,
  };
}

String weatherDisplayUnitsToStorage(WeatherDisplayUnits units) {
  return switch (units) {
    WeatherDisplayUnits.metric => 'metric',
    WeatherDisplayUnits.imperial => 'imperial',
  };
}

WeatherDisplayUnits readWeatherDisplayUnits(String? weatherJson) {
  final raw = _readDisplayUnitsRaw(weatherJson);
  return weatherDisplayUnitsFromStorage(raw);
}

String? updateWeatherJsonDisplayUnits(
  String? weatherJson,
  WeatherDisplayUnits units,
) {
  final storageValue = weatherDisplayUnitsToStorage(units);
  if (weatherJson == null || weatherJson.trim().isEmpty) {
    return jsonEncode({weatherJsonDisplayUnitsField: storageValue});
  }

  try {
    final decoded = jsonDecode(weatherJson);
    if (decoded is! Map<String, dynamic>) {
      return jsonEncode({weatherJsonDisplayUnitsField: storageValue});
    }
    final updated = Map<String, dynamic>.from(decoded)
      ..[weatherJsonDisplayUnitsField] = storageValue;
    return jsonEncode(updated);
  } catch (_) {
    return jsonEncode({weatherJsonDisplayUnitsField: storageValue});
  }
}

String? _readDisplayUnitsRaw(String? weatherJson) {
  if (weatherJson == null || weatherJson.trim().isEmpty) {
    return null;
  }
  try {
    final decoded = jsonDecode(weatherJson);
    if (decoded is Map<String, dynamic>) {
      return decoded[weatherJsonDisplayUnitsField] as String?;
    }
  } catch (_) {
    return null;
  }
  return null;
}

bool isWeatherJsonMetadataField(String key) {
  return key == 'history' || key == 'source' || key == weatherJsonDisplayUnitsField;
}
