import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/serverpod_client.dart';
import '../../markers/providers/markers_provider.dart';
import '../models/marker_weather_snapshot.dart';
import '../models/weather_display_units.dart';
import '../models/weather_reading_formatter.dart';

class WeatherStationDetailsSection extends ConsumerStatefulWidget {
  const WeatherStationDetailsSection({
    super.key,
    required this.marker,
  });

  final MapMarker marker;

  @override
  ConsumerState<WeatherStationDetailsSection> createState() =>
      _WeatherStationDetailsSectionState();
}

class _WeatherStationDetailsSectionState
    extends ConsumerState<WeatherStationDetailsSection> {
  bool _savingUnits = false;

  MapMarker get _marker {
    final markers = ref.watch(markersProvider).valueOrNull;
    if (markers == null) {
      return widget.marker;
    }
    for (final marker in markers) {
      if (marker.id == widget.marker.id) {
        return marker;
      }
    }
    return widget.marker;
  }

  Future<void> _setDisplayUnits(WeatherDisplayUnits units) async {
    if (_savingUnits) {
      return;
    }
    final marker = _marker;
    final current = readWeatherDisplayUnits(marker.weatherJson);
    if (current == units) {
      return;
    }

    setState(() => _savingUnits = true);
    try {
      final client = ref.read(serverClientProvider);
      await client.mapMarker.updateMarker(
        marker.copyWith(
          weatherJson: updateWeatherJsonDisplayUnits(marker.weatherJson, units),
          updatedAt: DateTime.now().toUtc(),
        ),
      );
      ref.invalidate(markersProvider);
    } finally {
      if (mounted) {
        setState(() => _savingUnits = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final marker = _marker;
    final displayUnits = readWeatherDisplayUnits(marker.weatherJson);
    final snapshot = MarkerWeatherSnapshot.fromMarkerWeatherJson(
      marker.weatherJson,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.55,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _UnitsToggleRow(
                l10n: l10n,
                displayUnits: displayUnits,
                enabled: !_savingUnits,
                onChanged: _setDisplayUnits,
              ),
              const SizedBox(height: 12),
              if (snapshot == null)
                _WeatherEmptyState(message: l10n.weatherNoData)
              else
                _WeatherContent(
                  l10n: l10n,
                  snapshot: snapshot,
                  displayUnits: displayUnits,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnitsToggleRow extends StatelessWidget {
  const _UnitsToggleRow({
    required this.l10n,
    required this.displayUnits,
    required this.enabled,
    required this.onChanged,
  });

  final AppLocalizations l10n;
  final WeatherDisplayUnits displayUnits;
  final bool enabled;
  final ValueChanged<WeatherDisplayUnits> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.weatherDisplayUnitsLabel,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        SegmentedButton<WeatherDisplayUnits>(
          segments: [
            ButtonSegment(
              value: WeatherDisplayUnits.metric,
              label: Text(l10n.measurementMetric),
            ),
            ButtonSegment(
              value: WeatherDisplayUnits.imperial,
              label: Text(l10n.measurementImperial),
            ),
          ],
          selected: {displayUnits},
          onSelectionChanged: enabled
              ? (selection) => onChanged(selection.first)
              : null,
          showSelectedIcon: false,
        ),
      ],
    );
  }
}

class _WeatherContent extends StatelessWidget {
  const _WeatherContent({
    required this.l10n,
    required this.snapshot,
    required this.displayUnits,
  });

  final AppLocalizations l10n;
  final MarkerWeatherSnapshot snapshot;
  final WeatherDisplayUnits displayUnits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reading = snapshot.latest;
    final formatter = WeatherReadingFormatter(
      reading: reading,
      displayUnits: displayUnits,
    );
    final condition = weatherConditionPresentation(
      weatherCode: reading.weatherCode,
      condition: reading.condition,
    );
    final conditionLabel =
        condition.displayLabel ?? _conditionLabel(l10n, condition.labelKey);
    final updatedAt = DateFormat.yMMMd().add_jm().format(
      reading.observedAt.toLocal(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _conditionIcon(condition.iconName),
              size: 42,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.weatherStationCurrentConditions,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    conditionLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    l10n.weatherUpdatedAt(updatedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (reading.source != null &&
                      reading.source!.trim().isNotEmpty)
                    Text(
                      l10n.weatherSource(reading.source!.trim()),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (reading.temperature != null)
              Text(
                formatter.formatTemperature(
                  reading.temperature,
                  reading.temperatureUnit,
                ),
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (reading.apparentTemperature != null)
              _WeatherMetricTile(
                icon: Icons.thermostat,
                label: l10n.weatherFeelsLike,
                value: formatter.formatTemperature(
                  reading.apparentTemperature,
                  reading.temperatureUnit,
                ),
              ),
            if (reading.humidityPercent != null)
              _WeatherMetricTile(
                icon: Icons.water_drop_outlined,
                label: l10n.weatherHumidity,
                value: '${reading.humidityPercent}%',
              ),
            if (reading.windSpeed != null)
              _WeatherMetricTile(
                icon: Icons.air,
                label: l10n.weatherWind,
                value: formatter.formatWindSpeed(),
              ),
            if (reading.precipitation != null)
              _WeatherMetricTile(
                icon: Icons.grain,
                label: l10n.weatherPrecipitation,
                value: formatter.formatPrecipitation(),
              ),
            if (reading.pressure != null)
              _WeatherMetricTile(
                icon: Icons.speed,
                label: l10n.weatherPressure,
                value: formatter.formatPressure(),
              ),
            if (reading.dewPoint != null)
              _WeatherMetricTile(
                icon: Icons.water_drop_outlined,
                label: l10n.weatherDewPoint,
                value: formatter.formatTemperature(
                  reading.dewPoint,
                  reading.dewPointUnit ?? reading.temperatureUnit,
                ),
              ),
            if (reading.luminosity != null)
              _WeatherMetricTile(
                icon: Icons.wb_sunny,
                label: l10n.weatherLuminosity,
                value: formatter.formatLuminosity(),
              ),
            if (reading.solarRadiation != null)
              _WeatherMetricTile(
                icon: Icons.solar_power,
                label: l10n.weatherSolarRadiation,
                value: formatter.formatSolarRadiation(),
              ),
            if (reading.uvIndex != null)
              _WeatherMetricTile(
                icon: Icons.wb_sunny_outlined,
                label: l10n.weatherUvIndex,
                value: reading.uvIndex!.round().toString(),
              ),
            if (reading.snowfall != null)
              _WeatherMetricTile(
                icon: Icons.ac_unit,
                label: l10n.weatherSnowfall,
                value: formatter.formatSnowfall(),
              ),
            if (reading.waterLevel != null)
              _WeatherMetricTile(
                icon: Icons.water,
                label: l10n.weatherWaterLevel,
                value: formatter.formatWaterLevel(),
              ),
            if (reading.soilTemperature != null)
              _WeatherMetricTile(
                icon: Icons.thermostat,
                label: l10n.weatherSoilTemperature,
                value: formatter.formatTemperature(
                  reading.soilTemperature,
                  reading.soilTemperatureUnit ?? reading.temperatureUnit,
                ),
              ),
            if (reading.soilMoisture != null)
              _WeatherMetricTile(
                icon: Icons.grass,
                label: l10n.weatherSoilMoisture,
                value: formatter.formatPercent(
                  reading.soilMoisture,
                  reading.soilMoistureUnit,
                ),
              ),
            if (reading.leafWetness != null)
              _WeatherMetricTile(
                icon: Icons.water_drop,
                label: l10n.weatherLeafWetness,
                value: formatter.formatPercent(
                  reading.leafWetness,
                  reading.leafWetnessUnit,
                ),
              ),
            if (reading.indoorTemperature != null)
              _WeatherMetricTile(
                icon: Icons.home,
                label: l10n.weatherIndoorTemperature,
                value: formatter.formatTemperature(
                  reading.indoorTemperature,
                  reading.indoorTemperatureUnit ?? reading.temperatureUnit,
                ),
              ),
            if (reading.indoorHumidityPercent != null)
              _WeatherMetricTile(
                icon: Icons.home_outlined,
                label: l10n.weatherIndoorHumidity,
                value: '${reading.indoorHumidityPercent}%',
              ),
            if (reading.batteryVoltage != null)
              _WeatherMetricTile(
                icon: Icons.battery_std,
                label: l10n.weatherBatteryVoltage,
                value: formatter.formatBatteryVoltage(),
              ),
            if (reading.windRun != null)
              _WeatherMetricTile(
                icon: Icons.straighten,
                label: l10n.weatherWindRun,
                value: formatter.formatWindRun(),
              ),
            if (reading.stationStatus != null &&
                reading.stationStatus!.trim().isNotEmpty)
              _WeatherMetricTile(
                icon: Icons.info_outline,
                label: l10n.weatherStationStatus,
                value: reading.stationStatus!.trim(),
              ),
            if (reading.sensorHealth != null &&
                reading.sensorHealth!.trim().isNotEmpty)
              _WeatherMetricTile(
                icon: Icons.health_and_safety,
                label: l10n.weatherSensorHealth,
                value: reading.sensorHealth!.trim(),
              ),
          ],
        ),
        if (snapshot.history.length > 1) ...[
          const SizedBox(height: 14),
          Text(
            l10n.weatherHistoryTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          for (final entry in snapshot.history.take(5))
            _HistoryRow(
              l10n: l10n,
              reading: entry,
              displayUnits: displayUnits,
            ),
        ],
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.l10n,
    required this.reading,
    required this.displayUnits,
  });

  final AppLocalizations l10n;
  final MarkerWeatherReading reading;
  final WeatherDisplayUnits displayUnits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = WeatherReadingFormatter(
      reading: reading,
      displayUnits: displayUnits,
    );
    final condition = weatherConditionPresentation(
      weatherCode: reading.weatherCode,
      condition: reading.condition,
    );
    final label =
        condition.displayLabel ?? _conditionLabel(l10n, condition.labelKey);
    final timestamp = DateFormat.MMMd().add_jm().format(
      reading.observedAt.toLocal(),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 112,
            child: Text(
              timestamp,
              style: theme.textTheme.bodySmall,
            ),
          ),
          Icon(_conditionIcon(condition.iconName), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: theme.textTheme.bodySmall),
          ),
          if (reading.temperature != null)
            Text(
              formatter.formatTemperature(
                reading.temperature,
                reading.temperatureUnit,
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

class _WeatherMetricTile extends StatelessWidget {
  const _WeatherMetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 148,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(height: 6),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeatherEmptyState extends StatelessWidget {
  const _WeatherEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(Icons.cloud_queue, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _conditionLabel(AppLocalizations l10n, WeatherConditionLabel labelKey) {
  return switch (labelKey) {
    WeatherConditionLabel.clear => l10n.weatherConditionClear,
    WeatherConditionLabel.partlyCloudy => l10n.weatherConditionPartlyCloudy,
    WeatherConditionLabel.overcast => l10n.weatherConditionOvercast,
    WeatherConditionLabel.fog => l10n.weatherConditionFog,
    WeatherConditionLabel.drizzle => l10n.weatherConditionDrizzle,
    WeatherConditionLabel.rain => l10n.weatherConditionRain,
    WeatherConditionLabel.snow => l10n.weatherConditionSnow,
    WeatherConditionLabel.showers => l10n.weatherConditionShowers,
    WeatherConditionLabel.thunderstorm => l10n.weatherConditionThunderstorm,
    WeatherConditionLabel.unknown => l10n.weatherConditionUnknown,
  };
}

IconData _conditionIcon(String iconName) {
  return switch (iconName) {
    'clear' => Icons.wb_sunny,
    'partly_cloudy' => Icons.wb_cloudy,
    'cloudy' => Icons.cloud,
    'fog' => Icons.foggy,
    'drizzle' => Icons.grain,
    'rain' => Icons.umbrella,
    'snow' => Icons.ac_unit,
    'showers' => Icons.water_drop,
    'thunderstorm' => Icons.thunderstorm,
    _ => Icons.device_thermostat,
  };
}
