import 'marker_weather_snapshot.dart';
import 'weather_display_units.dart';

class WeatherReadingFormatter {
  const WeatherReadingFormatter({
    required this.reading,
    required this.displayUnits,
  });

  final MarkerWeatherReading reading;
  final WeatherDisplayUnits displayUnits;

  String formatTemperature(double? value, String sourceUnit) {
    final celsius = _celsiusFromTemperature(value, sourceUnit);
    if (celsius == null) {
      return '—';
    }
    return switch (displayUnits) {
      WeatherDisplayUnits.metric =>
        '${_formatNumber(celsius, fractionDigits: 1)}°C',
      WeatherDisplayUnits.imperial =>
        '${_formatNumber(_fahrenheitFromCelsius(celsius), fractionDigits: 0)}°F',
    };
  }

  String formatWindSpeed() {
    final metersPerSecond = _metersPerSecondFromWind(
      reading.windSpeed,
      reading.windSpeedUnit,
    );
    if (metersPerSecond == null) {
      return '—';
    }
    final direction = formatCompassDirection(reading.windDirectionDegrees);
    return switch (displayUnits) {
      WeatherDisplayUnits.metric =>
        '${_formatNumber(metersPerSecond * 3.6, fractionDigits: 0)} km/h $direction',
      WeatherDisplayUnits.imperial =>
        '${_formatNumber(metersPerSecond * 2.2369362921, fractionDigits: 0)} mph $direction',
    };
  }

  String formatPrecipitation() {
    return _formatLengthMeasurement(
      reading.precipitation,
      reading.precipitationUnit,
      metricUnit: 'mm',
      imperialUnit: 'in',
      fractionDigits: 1,
    );
  }

  String formatSnowfall() {
    return _formatLengthMeasurement(
      reading.snowfall,
      reading.snowfallUnit,
      metricUnit: 'mm',
      imperialUnit: 'in',
      fractionDigits: 1,
    );
  }

  String formatPressure() {
    final hectopascals = _hectopascalsFromPressure(
      reading.pressure,
      reading.pressureUnit,
    );
    if (hectopascals == null) {
      return '—';
    }
    return switch (displayUnits) {
      WeatherDisplayUnits.metric =>
        '${_formatNumber(hectopascals, fractionDigits: 0)} hPa',
      WeatherDisplayUnits.imperial =>
        '${_formatNumber(hectopascals / 33.8638866667, fractionDigits: 2)} inHg',
    };
  }

  String formatWaterLevel() {
    return _formatDistanceMeasurement(
      reading.waterLevel,
      reading.waterLevelUnit,
      metricUnit: 'm',
      imperialUnit: 'ft',
      fractionDigits: 2,
    );
  }

  String formatWindRun() {
    return _formatDistanceMeasurement(
      reading.windRun,
      reading.windRunUnit,
      metricUnit: 'km',
      imperialUnit: 'mi',
      fractionDigits: 1,
    );
  }

  String formatLuminosity() {
    return formatWeatherValue(
      reading.luminosity,
      reading.luminosityUnit,
      fractionDigits: 0,
    );
  }

  String formatSolarRadiation() {
    return formatWeatherValue(
      reading.solarRadiation,
      reading.solarRadiationUnit,
      fractionDigits: 1,
    );
  }

  String formatBatteryVoltage() {
    return formatWeatherValue(
      reading.batteryVoltage,
      reading.batteryVoltageUnit,
      fractionDigits: 1,
    );
  }

  String formatPercent(double? value, String unit) {
    return formatWeatherValue(value, unit, fractionDigits: 0);
  }

  String _formatLengthMeasurement(
    double? value,
    String sourceUnit, {
    required String metricUnit,
    required String imperialUnit,
    required int fractionDigits,
  }) {
    final millimeters = _millimetersFromLength(value, sourceUnit);
    if (millimeters == null) {
      return '—';
    }
    return switch (displayUnits) {
      WeatherDisplayUnits.metric => _formatNumber(
        millimeters,
        fractionDigits: fractionDigits,
        suffix: metricUnit,
      ),
      WeatherDisplayUnits.imperial => _formatNumber(
        millimeters / 25.4,
        fractionDigits: fractionDigits,
        suffix: imperialUnit,
      ),
    };
  }

  String _formatDistanceMeasurement(
    double? value,
    String sourceUnit, {
    required String metricUnit,
    required String imperialUnit,
    required int fractionDigits,
  }) {
    final meters = _metersFromDistance(value, sourceUnit);
    if (meters == null) {
      return '—';
    }
    return switch (displayUnits) {
      WeatherDisplayUnits.metric => _formatNumber(
        metricUnit == 'km' ? meters / 1000 : meters,
        fractionDigits: fractionDigits,
        suffix: metricUnit,
      ),
      WeatherDisplayUnits.imperial => _formatNumber(
        meters / 0.3048 / (imperialUnit == 'mi' ? 5280 : 1),
        fractionDigits: fractionDigits,
        suffix: imperialUnit,
      ),
    };
  }

  String _formatNumber(
    double value, {
    required int fractionDigits,
    String suffix = '',
  }) {
    final text = fractionDigits == 0
        ? value.round().toString()
        : value.toStringAsFixed(fractionDigits);
    return suffix.isEmpty ? text : '$text$suffix';
  }
}

double? _celsiusFromTemperature(double? value, String unit) {
  if (value == null) {
    return null;
  }
  return switch (unit.trim().toUpperCase()) {
    'F' => (value - 32) * 5 / 9,
    _ => value,
  };
}

double _fahrenheitFromCelsius(double celsius) => celsius * 9 / 5 + 32;

double? _metersPerSecondFromWind(double? value, String unit) {
  if (value == null) {
    return null;
  }
  final normalized = unit.trim().toLowerCase().replaceAll(' ', '');
  return switch (normalized) {
    'km/h' || 'kph' => value / 3.6,
    'mph' => value * 0.44704,
    'kt' || 'kts' || 'knots' => value * 0.514444,
    'm/s' || 'mps' => value,
    _ => value / 3.6,
  };
}

double? _millimetersFromLength(double? value, String unit) {
  if (value == null) {
    return null;
  }
  final normalized = unit.trim().toLowerCase();
  if (normalized == 'in' || normalized == 'inch' || normalized == 'inches') {
    return value * 25.4;
  }
  return value;
}

double? _metersFromDistance(double? value, String unit) {
  if (value == null) {
    return null;
  }
  final normalized = unit.trim().toLowerCase();
  return switch (normalized) {
    'km' || 'kilometers' => value * 1000,
    'mi' || 'miles' => value * 1609.344,
    'ft' || 'feet' => value * 0.3048,
    _ => value,
  };
}

double? _hectopascalsFromPressure(double? value, String unit) {
  if (value == null) {
    return null;
  }
  final normalized = unit.trim().toLowerCase();
  if (normalized == 'inhg') {
    return value * 33.8638866667;
  }
  return value;
}
