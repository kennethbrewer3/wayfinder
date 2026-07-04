import 'dart:convert';

const markerWeatherJsonDisplayUnitsField = 'displayUnits';

/// Preserves a weather station's saved unit preference when new readings arrive.
String? preserveWeatherJsonDisplayUnits(String? previous, String? next) {
  if (next == null || next.trim().isEmpty) {
    return next;
  }
  if (previous == null || previous.trim().isEmpty) {
    return next;
  }

  try {
    final previousJson = jsonDecode(previous);
    final nextJson = jsonDecode(next);
    if (previousJson is! Map<String, dynamic> ||
        nextJson is! Map<String, dynamic>) {
      return next;
    }

    final savedUnits = previousJson[markerWeatherJsonDisplayUnitsField];
    if (savedUnits is! String || savedUnits.trim().isEmpty) {
      return next;
    }
    if (nextJson.containsKey(markerWeatherJsonDisplayUnitsField)) {
      return next;
    }

    final merged = Map<String, dynamic>.from(nextJson)
      ..[markerWeatherJsonDisplayUnitsField] = savedUnits;
    return jsonEncode(merged);
  } catch (_) {
    return next;
  }
}
