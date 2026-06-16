enum MeasurementUnits {
  metric,
  imperial,
  nautical,
}

extension MeasurementUnitsLabel on MeasurementUnits {
  String get label => switch (this) {
        MeasurementUnits.metric => 'Metric',
        MeasurementUnits.imperial => 'Imperial',
        MeasurementUnits.nautical => 'Nautical',
      };

  String get shortLabel => switch (this) {
        MeasurementUnits.metric => 'm/km',
        MeasurementUnits.imperial => 'ft/mi',
        MeasurementUnits.nautical => 'nm',
      };
}

MeasurementUnits measurementUnitsFromStorage(String? value) {
  return switch (value) {
    'imperial' => MeasurementUnits.imperial,
    'nautical' => MeasurementUnits.nautical,
    _ => MeasurementUnits.metric,
  };
}

String measurementUnitsToStorage(MeasurementUnits units) {
  return switch (units) {
    MeasurementUnits.metric => 'metric',
    MeasurementUnits.imperial => 'imperial',
    MeasurementUnits.nautical => 'nautical',
  };
}

String formatLineDistance(double meters, MeasurementUnits units) {
  if (meters.isNaN || meters.isInfinite || meters < 0) {
    return '—';
  }

  return switch (units) {
    MeasurementUnits.metric => _formatMetric(meters),
    MeasurementUnits.imperial => _formatImperial(meters),
    MeasurementUnits.nautical => _formatNautical(meters),
  };
}

String formatArea(double squareMeters, MeasurementUnits units) {
  if (squareMeters.isNaN || squareMeters.isInfinite || squareMeters < 0) {
    return '—';
  }

  return switch (units) {
    MeasurementUnits.metric => _formatMetricArea(squareMeters),
    MeasurementUnits.imperial => _formatImperialArea(squareMeters),
    MeasurementUnits.nautical => _formatNauticalArea(squareMeters),
  };
}

String _formatMetric(double meters) {
  if (meters < 1000) {
    final precision = meters < 100 ? 1 : 0;
    return '${meters.toStringAsFixed(precision)} m';
  }
  return '${(meters / 1000).toStringAsFixed(2)} km';
}

String _formatImperial(double meters) {
  const metersPerFoot = 0.3048;
  const feetPerMile = 5280;
  final feet = meters / metersPerFoot;
  if (feet < feetPerMile) {
    final precision = feet < 100 ? 1 : 0;
    return '${feet.toStringAsFixed(precision)} ft';
  }
  return '${(feet / feetPerMile).toStringAsFixed(2)} mi';
}

String _formatNautical(double meters) {
  const metersPerNauticalMile = 1852.0;
  final nauticalMiles = meters / metersPerNauticalMile;
  if (nauticalMiles < 0.1) {
    final yards = meters / 0.9144;
    return '${yards.toStringAsFixed(0)} yd';
  }
  return '${nauticalMiles.toStringAsFixed(2)} nm';
}

String _formatMetricArea(double squareMeters) {
  const squareMetersPerHectare = 10000.0;
  const squareMetersPerSquareKilometer = 1000000.0;

  if (squareMeters < squareMetersPerHectare) {
    final precision = squareMeters < 100 ? 1 : 0;
    return '${squareMeters.toStringAsFixed(precision)} m²';
  }
  if (squareMeters < squareMetersPerSquareKilometer) {
    return '${(squareMeters / squareMetersPerHectare).toStringAsFixed(2)} ha';
  }
  return '${(squareMeters / squareMetersPerSquareKilometer).toStringAsFixed(2)} km²';
}

String _formatImperialArea(double squareMeters) {
  const squareMetersPerSquareFoot = 0.092903;
  const squareFeetPerAcre = 43560.0;
  const acresPerSquareMile = 640.0;

  final squareFeet = squareMeters / squareMetersPerSquareFoot;
  if (squareFeet < squareFeetPerAcre) {
    final precision = squareFeet < 100 ? 1 : 0;
    return '${squareFeet.toStringAsFixed(precision)} ft²';
  }
  final acres = squareFeet / squareFeetPerAcre;
  if (acres < acresPerSquareMile) {
    return '${acres.toStringAsFixed(2)} ac';
  }
  return '${(acres / acresPerSquareMile).toStringAsFixed(2)} mi²';
}

String _formatNauticalArea(double squareMeters) {
  const squareMetersPerSquareNauticalMile = 1852.0 * 1852.0;

  if (squareMeters < squareMetersPerSquareNauticalMile * 0.01) {
    final precision = squareMeters < 100 ? 1 : 0;
    return '${squareMeters.toStringAsFixed(precision)} m²';
  }
  return '${(squareMeters / squareMetersPerSquareNauticalMile).toStringAsFixed(2)} nm²';
}
