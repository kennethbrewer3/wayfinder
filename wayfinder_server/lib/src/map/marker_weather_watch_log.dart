import 'dart:convert';

/// Pure helpers for turning weather station `weatherJson` into watch-log text.
///
/// Ignores `displayUnits` and `history` so unit-preference toggles and history
/// reshuffles do not create log noise.

const weatherStationMarkerIcon = 'weather_station';

bool weatherReadingsChanged(String? previous, String? next) {
  final nextPayload = weatherReadingComparablePayload(next);
  if (nextPayload == null) {
    return false;
  }
  final previousPayload = weatherReadingComparablePayload(previous);
  if (previousPayload == null) {
    return true;
  }
  return _canonicalJson(previousPayload) != _canonicalJson(nextPayload);
}

/// Returns a short summary for a watch-log line, or null if nothing useful.
String? formatWeatherWatchLogSummary(String? weatherJson) {
  final map = _decodeWeatherMap(weatherJson);
  if (map == null) {
    return null;
  }

  final parts = <String>[];

  final temperature = _asDouble(map['temperature']);
  if (temperature != null) {
    final unit = _asNonEmptyString(map['temperatureUnit']) ?? 'C';
    parts.add('${_formatNumber(temperature)}°$unit');
  }

  final humidity = _asInt(map['humidityPercent']) ?? _asInt(map['humidity']);
  if (humidity != null) {
    parts.add('$humidity% RH');
  }

  final condition = _asNonEmptyString(map['condition']);
  if (condition != null) {
    parts.add(condition);
  }

  final windSpeed = _asDouble(map['windSpeed']);
  if (windSpeed != null) {
    final unit = _asNonEmptyString(map['windSpeedUnit']) ?? 'km/h';
    final degrees =
        _asInt(map['windDirectionDegrees']) ?? _asInt(map['windDirection']);
    final direction = compassDirectionFromDegrees(degrees);
    parts.add(
      direction == null
          ? 'wind ${_formatNumber(windSpeed)} $unit'
          : 'wind ${_formatNumber(windSpeed)} $unit $direction',
    );
  }

  final pressure = _asDouble(map['pressure']);
  if (pressure != null) {
    final unit = _asNonEmptyString(map['pressureUnit']) ?? 'hPa';
    parts.add('${_formatNumber(pressure)} $unit');
  }

  final precipitation = _asDouble(map['precipitation']);
  if (precipitation != null) {
    final unit = _asNonEmptyString(map['precipitationUnit']) ?? 'mm';
    parts.add('precip ${_formatNumber(precipitation)} $unit');
  }

  final stationStatus = _asNonEmptyString(map['stationStatus']);
  if (stationStatus != null && stationStatus.toUpperCase() != 'OK') {
    parts.add('status: $stationStatus');
  }

  if (parts.isEmpty) {
    return null;
  }
  return parts.join(', ');
}

DateTime? weatherObservedAt(String? weatherJson) {
  final map = _decodeWeatherMap(weatherJson);
  if (map == null) {
    return null;
  }
  final raw = map['observedAt'];
  if (raw is! String) {
    return null;
  }
  return DateTime.tryParse(raw)?.toUtc();
}

String? weatherSource(String? weatherJson) {
  final map = _decodeWeatherMap(weatherJson);
  if (map == null) {
    return null;
  }
  return _asNonEmptyString(map['source']);
}

String weatherWatchLogSeverity(String? weatherJson) {
  final map = _decodeWeatherMap(weatherJson);
  final status = _asNonEmptyString(map?['stationStatus'])?.toLowerCase();
  if (status == null) {
    return 'info';
  }
  if (_containsAny(status, const [
    'critical',
    'alarm',
    'offline',
    'fail',
    'fault',
  ])) {
    return 'critical';
  }
  if (_containsAny(status, const ['warn', 'degraded', 'error'])) {
    return 'warning';
  }
  return 'info';
}

Map<String, dynamic>? weatherReadingComparablePayload(String? weatherJson) {
  final map = _decodeWeatherMap(weatherJson);
  if (map == null) {
    return null;
  }
  final payload = Map<String, dynamic>.from(map)
    ..remove('displayUnits')
    ..remove('history');
  if (payload.isEmpty) {
    return null;
  }
  return payload;
}

String? compassDirectionFromDegrees(int? degrees) {
  if (degrees == null) {
    return null;
  }
  const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
  final normalized = degrees % 360;
  final index =
      (((normalized < 0 ? normalized + 360 : normalized) / 45).round() % 8)
          .toInt();
  return directions[index];
}

Map<String, dynamic>? _decodeWeatherMap(String? weatherJson) {
  if (weatherJson == null || weatherJson.trim().isEmpty) {
    return null;
  }
  try {
    final decoded = jsonDecode(weatherJson);
    if (decoded is! Map) {
      return null;
    }
    return Map<String, dynamic>.from(decoded);
  } catch (_) {
    return null;
  }
}

String _canonicalJson(Map<String, dynamic> map) {
  final keys = map.keys.toList()..sort();
  return jsonEncode({for (final key in keys) key: map[key]});
}

double? _asDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value.trim());
  }
  return null;
}

int? _asInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.round();
  }
  if (value is String) {
    return int.tryParse(value.trim()) ?? double.tryParse(value.trim())?.round();
  }
  return null;
}

String? _asNonEmptyString(Object? value) {
  if (value is! String) {
    return null;
  }
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.round().toString();
  }
  final fixed = value.toStringAsFixed(1);
  if (fixed.endsWith('.0')) {
    return fixed.substring(0, fixed.length - 2);
  }
  return fixed;
}

bool _containsAny(String haystack, List<String> needles) {
  for (final needle in needles) {
    if (haystack.contains(needle)) {
      return true;
    }
  }
  return false;
}
