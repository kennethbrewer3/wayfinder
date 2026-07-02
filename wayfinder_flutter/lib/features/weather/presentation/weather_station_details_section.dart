import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../models/marker_weather_snapshot.dart';

class WeatherStationDetailsSection extends StatelessWidget {
  const WeatherStationDetailsSection({
    super.key,
    required this.marker,
  });

  final MapMarker marker;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final snapshot = MarkerWeatherSnapshot.fromMarkerWeatherJson(marker.weatherJson);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: snapshot == null
              ? _WeatherEmptyState(message: l10n.weatherNoData)
              : _WeatherContent(
                  l10n: l10n,
                  snapshot: snapshot,
                ),
        ),
      ),
    );
  }
}

class _WeatherContent extends StatelessWidget {
  const _WeatherContent({
    required this.l10n,
    required this.snapshot,
  });

  final AppLocalizations l10n;
  final MarkerWeatherSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reading = snapshot.latest;
    final condition = weatherConditionPresentation(
      weatherCode: reading.weatherCode,
      condition: reading.condition,
    );
    final conditionLabel =
        condition.displayLabel ?? _conditionLabel(l10n, condition.labelKey);
    final updatedAt =
        DateFormat.yMMMd().add_jm().format(reading.observedAt.toLocal());
    final tempUnit = formatTemperatureUnit(reading.temperatureUnit);

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
                  if (reading.source != null && reading.source!.trim().isNotEmpty)
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
                formatTemperature(reading.temperature, tempUnit),
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
                value: formatTemperature(
                  reading.apparentTemperature,
                  tempUnit,
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
                value:
                    '${reading.windSpeed!.round()} ${reading.windSpeedUnit} ${formatCompassDirection(reading.windDirectionDegrees)}',
              ),
            if (reading.precipitation != null)
              _WeatherMetricTile(
                icon: Icons.grain,
                label: l10n.weatherPrecipitation,
                value: formatWeatherValue(
                  reading.precipitation,
                  reading.precipitationUnit,
                  fractionDigits: 1,
                ),
              ),
            if (reading.pressure != null)
              _WeatherMetricTile(
                icon: Icons.speed,
                label: l10n.weatherPressure,
                value:
                    '${reading.pressure!.round()} ${reading.pressureUnit}',
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
            _HistoryRow(l10n: l10n, reading: entry),
        ],
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.l10n,
    required this.reading,
  });

  final AppLocalizations l10n;
  final MarkerWeatherReading reading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final condition = weatherConditionPresentation(
      weatherCode: reading.weatherCode,
      condition: reading.condition,
    );
    final label =
        condition.displayLabel ?? _conditionLabel(l10n, condition.labelKey);
    final timestamp =
        DateFormat.MMMd().add_jm().format(reading.observedAt.toLocal());
    final tempUnit = formatTemperatureUnit(reading.temperatureUnit);

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
              formatTemperature(reading.temperature, tempUnit),
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
