import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../lines/models/measurement_units.dart';

String formatTideHeightMeters(
  double meters,
  MeasurementUnits units,
  AppLocalizations l10n,
) {
  return switch (units) {
    MeasurementUnits.metric => l10n.tidesHeightMeters(
      meters.toStringAsFixed(2),
    ),
    MeasurementUnits.imperial || MeasurementUnits.nautical =>
      l10n.tidesHeightFeet((meters / 0.3048).toStringAsFixed(2)),
  };
}

String formatTideDistanceMeters(
  double? meters,
  MeasurementUnits units,
  AppLocalizations l10n,
) {
  if (meters == null) {
    return l10n.tidesDistanceUnknown;
  }
  return switch (units) {
    MeasurementUnits.metric =>
      meters >= 1000
          ? l10n.tidesDistanceKm((meters / 1000).toStringAsFixed(1))
          : l10n.tidesDistanceMeters(meters.round().toString()),
    MeasurementUnits.imperial || MeasurementUnits.nautical =>
      meters >= 1609.344
          ? l10n.tidesDistanceMiles((meters / 1609.344).toStringAsFixed(1))
          : l10n.tidesDistanceFeet((meters / 0.3048).round().toString()),
  };
}
