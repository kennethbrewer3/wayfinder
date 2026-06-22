import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

String formatCoordinateField(double value) {
  return value.toStringAsFixed(5);
}

double? parseCoordinateField(String raw, {required bool isLatitude}) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  final value = double.tryParse(trimmed);
  if (value == null) {
    return null;
  }
  if (isLatitude && (value < -90 || value > 90)) {
    return null;
  }
  if (!isLatitude && (value < -180 || value > 180)) {
    return null;
  }
  return value;
}

LatLng? parseLatLngFields(String latitudeRaw, String longitudeRaw) {
  final latitude = parseCoordinateField(latitudeRaw, isLatitude: true);
  final longitude = parseCoordinateField(longitudeRaw, isLatitude: false);
  if (latitude == null || longitude == null) {
    return null;
  }
  return LatLng(latitude, longitude);
}

class CoordinateFormFields extends StatelessWidget {
  const CoordinateFormFields({
    super.key,
    required this.latitudeController,
    required this.longitudeController,
    this.title,
    this.latitudeLabel,
    this.longitudeLabel,
    this.helperText,
  });

  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final String? title;
  final String? latitudeLabel;
  final String? longitudeLabel;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title ?? l10n.coordinatesTitle,
          style: theme.textTheme.labelLarge,
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: latitudeController,
                decoration: InputDecoration(
                  labelText: latitudeLabel ?? l10n.settingsLatitude,
                  hintText: '38.89511',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: longitudeController,
                decoration: InputDecoration(
                  labelText: longitudeLabel ?? l10n.settingsLongitude,
                  hintText: '-77.03637',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
