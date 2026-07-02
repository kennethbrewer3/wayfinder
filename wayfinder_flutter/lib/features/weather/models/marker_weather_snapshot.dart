import 'dart:convert';

class MarkerWeatherReading {
  const MarkerWeatherReading({
    required this.observedAt,
    this.source,
    this.temperature,
    this.temperatureUnit = 'C',
    this.apparentTemperature,
    this.humidityPercent,
    this.precipitation,
    this.precipitationUnit = 'mm',
    this.weatherCode,
    this.condition,
    this.windSpeed,
    this.windSpeedUnit = 'km/h',
    this.windDirectionDegrees,
    this.pressure,
    this.pressureUnit = 'hPa',
  });

  final DateTime observedAt;
  final String? source;
  final double? temperature;
  final String temperatureUnit;
  final double? apparentTemperature;
  final int? humidityPercent;
  final double? precipitation;
  final String precipitationUnit;
  final int? weatherCode;
  final String? condition;
  final double? windSpeed;
  final String windSpeedUnit;
  final int? windDirectionDegrees;
  final double? pressure;
  final String pressureUnit;

  bool get hasMeasurements =>
      temperature != null ||
      apparentTemperature != null ||
      humidityPercent != null ||
      precipitation != null ||
      windSpeed != null ||
      pressure != null ||
      weatherCode != null ||
      (condition != null && condition!.trim().isNotEmpty);

  factory MarkerWeatherReading.fromJson(Map<String, dynamic> json) {
    final observedAtRaw = json['observedAt'];
    final observedAt = observedAtRaw is String
        ? DateTime.tryParse(observedAtRaw) ?? DateTime.now().toUtc()
        : DateTime.now().toUtc();

    return MarkerWeatherReading(
      observedAt: observedAt,
      source: json['source'] as String?,
      temperature: _optionalDouble(json['temperature']),
      temperatureUnit: json['temperatureUnit'] as String? ?? 'C',
      apparentTemperature: _optionalDouble(json['apparentTemperature']),
      humidityPercent: _optionalInt(json['humidityPercent'] ?? json['humidity']),
      precipitation: _optionalDouble(json['precipitation']),
      precipitationUnit: json['precipitationUnit'] as String? ?? 'mm',
      weatherCode: _optionalInt(json['weatherCode']),
      condition: json['condition'] as String?,
      windSpeed: _optionalDouble(json['windSpeed']),
      windSpeedUnit: json['windSpeedUnit'] as String? ?? 'km/h',
      windDirectionDegrees: _optionalInt(
        json['windDirectionDegrees'] ?? json['windDirection'],
      ),
      pressure: _optionalDouble(json['pressure']),
      pressureUnit: json['pressureUnit'] as String? ?? 'hPa',
    );
  }
}

class MarkerWeatherSnapshot {
  const MarkerWeatherSnapshot({
    required this.latest,
    required this.history,
  });

  final MarkerWeatherReading latest;
  final List<MarkerWeatherReading> history;

  static MarkerWeatherSnapshot? fromMarkerWeatherJson(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  static MarkerWeatherSnapshot? fromJson(Map<String, dynamic> json) {
    final historyRaw = json['history'];
    final history = <MarkerWeatherReading>[];

    if (historyRaw is List) {
      for (final entry in historyRaw) {
        if (entry is Map<String, dynamic>) {
          final reading = MarkerWeatherReading.fromJson(entry);
          if (reading.hasMeasurements) {
            history.add(reading);
          }
        }
      }
    }

    MarkerWeatherReading? latest;
    if (json.isNotEmpty &&
        json.keys.any((key) => key != 'history' && key != 'source')) {
      final latestCandidate = MarkerWeatherReading.fromJson(json);
      if (latestCandidate.hasMeasurements) {
        latest = latestCandidate;
      }
    }

    latest ??= history.isNotEmpty ? history.first : null;
    if (latest == null) {
      return null;
    }

    final sortedHistory = [...history]
      ..sort((a, b) => b.observedAt.compareTo(a.observedAt));
    final dedupedHistory = <MarkerWeatherReading>[];
    for (final reading in sortedHistory) {
      if (dedupedHistory.any(
        (existing) => existing.observedAt == reading.observedAt,
      )) {
        continue;
      }
      dedupedHistory.add(reading);
    }

    return MarkerWeatherSnapshot(
      latest: latest,
      history: dedupedHistory,
    );
  }
}

double? _optionalDouble(Object? raw) {
  if (raw is num) {
    return raw.toDouble();
  }
  return null;
}

int? _optionalInt(Object? raw) {
  if (raw is num) {
    return raw.round();
  }
  return null;
}

WeatherConditionPresentation weatherConditionPresentation({
  int? weatherCode,
  String? condition,
}) {
  if (condition != null && condition.trim().isNotEmpty) {
    final normalized = condition.trim().toLowerCase();
    final labelKey = switch (normalized) {
      'clear' || 'sunny' => WeatherConditionLabel.clear,
      'partly cloudy' || 'partly_cloudy' => WeatherConditionLabel.partlyCloudy,
      'overcast' || 'cloudy' => WeatherConditionLabel.overcast,
      'fog' || 'foggy' => WeatherConditionLabel.fog,
      'drizzle' => WeatherConditionLabel.drizzle,
      'rain' || 'rainy' => WeatherConditionLabel.rain,
      'snow' || 'snowy' => WeatherConditionLabel.snow,
      'showers' => WeatherConditionLabel.showers,
      'thunderstorm' || 'storm' => WeatherConditionLabel.thunderstorm,
      _ => WeatherConditionLabel.unknown,
    };
    return WeatherConditionPresentation(
      labelKey: labelKey,
      iconName: _iconNameForLabel(labelKey),
      displayLabel: condition.trim(),
    );
  }

  if (weatherCode != null) {
    return weatherConditionPresentationForCode(weatherCode);
  }

  return const WeatherConditionPresentation(
    labelKey: WeatherConditionLabel.unknown,
    iconName: 'unknown',
  );
}

WeatherConditionPresentation weatherConditionPresentationForCode(int code) {
  final labelKey = switch (code) {
    0 => WeatherConditionLabel.clear,
    1 || 2 => WeatherConditionLabel.partlyCloudy,
    3 => WeatherConditionLabel.overcast,
    45 || 48 => WeatherConditionLabel.fog,
    51 || 53 || 55 || 56 || 57 => WeatherConditionLabel.drizzle,
    61 || 63 || 65 || 66 || 67 => WeatherConditionLabel.rain,
    71 || 73 || 75 || 77 || 85 || 86 => WeatherConditionLabel.snow,
    80 || 81 || 82 => WeatherConditionLabel.showers,
    95 || 96 || 99 => WeatherConditionLabel.thunderstorm,
    _ => WeatherConditionLabel.unknown,
  };
  return WeatherConditionPresentation(
    labelKey: labelKey,
    iconName: _iconNameForLabel(labelKey),
  );
}

String _iconNameForLabel(WeatherConditionLabel labelKey) {
  return switch (labelKey) {
    WeatherConditionLabel.clear => 'clear',
    WeatherConditionLabel.partlyCloudy => 'partly_cloudy',
    WeatherConditionLabel.overcast => 'cloudy',
    WeatherConditionLabel.fog => 'fog',
    WeatherConditionLabel.drizzle => 'drizzle',
    WeatherConditionLabel.rain => 'rain',
    WeatherConditionLabel.snow => 'snow',
    WeatherConditionLabel.showers => 'showers',
    WeatherConditionLabel.thunderstorm => 'thunderstorm',
    WeatherConditionLabel.unknown => 'unknown',
  };
}

enum WeatherConditionLabel {
  clear,
  partlyCloudy,
  overcast,
  fog,
  drizzle,
  rain,
  snow,
  showers,
  thunderstorm,
  unknown,
}

class WeatherConditionPresentation {
  const WeatherConditionPresentation({
    required this.labelKey,
    required this.iconName,
    this.displayLabel,
  });

  final WeatherConditionLabel labelKey;
  final String iconName;
  final String? displayLabel;
}

String formatCompassDirection(int? degrees) {
  if (degrees == null) {
    return '—';
  }
  const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
  final index = ((degrees / 45).round()) % directions.length;
  return directions[index];
}

String formatWeatherValue(double? value, String unit, {int fractionDigits = 0}) {
  if (value == null) {
    return '—';
  }
  if (fractionDigits == 0) {
    return '${value.round()}$unit';
  }
  return '${value.toStringAsFixed(fractionDigits)}$unit';
}

String formatTemperature(double? value, String unit) {
  return formatWeatherValue(value, unit);
}

String formatTemperatureUnit(String unit) {
  if (unit == 'C') {
    return '°C';
  }
  if (unit == 'F') {
    return '°F';
  }
  return unit.startsWith('°') ? unit : '°$unit';
}
