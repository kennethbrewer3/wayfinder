import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

/// Key ColorScheme roles that can be overridden on a custom theme.
const appThemeOverrideRoles = <String>[
  'primary',
  'onPrimary',
  'primaryContainer',
  'onPrimaryContainer',
  'secondary',
  'onSecondary',
  'secondaryContainer',
  'onSecondaryContainer',
  'tertiary',
  'onTertiary',
  'tertiaryContainer',
  'onTertiaryContainer',
  'error',
  'onError',
  'errorContainer',
  'onErrorContainer',
  'surface',
  'onSurface',
  'onSurfaceVariant',
  'outline',
  'outlineVariant',
  'inverseSurface',
  'onInverseSurface',
  'inversePrimary',
  'surfaceTint',
];

/// Roles shown first in the theme editor (seed fills the rest).
const appThemePrimaryOverrideRoles = <String>[
  'primary',
  'onPrimary',
  'secondary',
  'onSecondary',
  'tertiary',
  'onTertiary',
  'surface',
  'onSurface',
  'error',
  'onError',
];

Color? parseThemeHexColor(String? raw) {
  if (raw == null) {
    return null;
  }
  var value = raw.trim();
  if (value.isEmpty) {
    return null;
  }
  if (value.startsWith('#')) {
    value = value.substring(1);
  }
  if (value.length == 6) {
    value = 'FF$value';
  }
  if (value.length != 8) {
    return null;
  }
  final intValue = int.tryParse(value, radix: 16);
  if (intValue == null) {
    return null;
  }
  return Color(intValue);
}

String themeColorToHex(Color color) {
  final argb = color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase();
  if (argb.startsWith('FF')) {
    return '#${argb.substring(2)}';
  }
  return '#$argb';
}

Map<String, String> decodeThemeOverrides(String overridesJson) {
  try {
    final decoded = jsonDecode(overridesJson);
    if (decoded is! Map) {
      return const {};
    }
    final out = <String, String>{};
    for (final entry in decoded.entries) {
      final key = entry.key.toString();
      final value = entry.value?.toString();
      if (!appThemeOverrideRoles.contains(key) ||
          value == null ||
          value.trim().isEmpty) {
        continue;
      }
      out[key] = value.trim();
    }
    return out;
  } catch (_) {
    return const {};
  }
}

String encodeThemeOverrides(Map<String, String> overrides) {
  final cleaned = <String, String>{};
  for (final entry in overrides.entries) {
    if (!appThemeOverrideRoles.contains(entry.key)) {
      continue;
    }
    final value = entry.value.trim();
    if (value.isEmpty) {
      continue;
    }
    cleaned[entry.key] = value;
  }
  return jsonEncode(cleaned);
}

Brightness themeBrightnessFromStorage(String value) {
  return value.trim().toLowerCase() == 'dark'
      ? Brightness.dark
      : Brightness.light;
}

ColorScheme colorSchemeFromThemeDefinition(AppThemeDefinition theme) {
  final seed = parseThemeHexColor(theme.seedColor) ?? const Color(0xFF1B4965);
  final overrides = decodeThemeOverrides(theme.overridesJson);
  var scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: themeBrightnessFromStorage(theme.brightness),
  );
  return scheme.copyWith(
    primary: parseThemeHexColor(overrides['primary']),
    onPrimary: parseThemeHexColor(overrides['onPrimary']),
    primaryContainer: parseThemeHexColor(overrides['primaryContainer']),
    onPrimaryContainer: parseThemeHexColor(overrides['onPrimaryContainer']),
    secondary: parseThemeHexColor(overrides['secondary']),
    onSecondary: parseThemeHexColor(overrides['onSecondary']),
    secondaryContainer: parseThemeHexColor(overrides['secondaryContainer']),
    onSecondaryContainer: parseThemeHexColor(overrides['onSecondaryContainer']),
    tertiary: parseThemeHexColor(overrides['tertiary']),
    onTertiary: parseThemeHexColor(overrides['onTertiary']),
    tertiaryContainer: parseThemeHexColor(overrides['tertiaryContainer']),
    onTertiaryContainer: parseThemeHexColor(overrides['onTertiaryContainer']),
    error: parseThemeHexColor(overrides['error']),
    onError: parseThemeHexColor(overrides['onError']),
    errorContainer: parseThemeHexColor(overrides['errorContainer']),
    onErrorContainer: parseThemeHexColor(overrides['onErrorContainer']),
    surface: parseThemeHexColor(overrides['surface']),
    onSurface: parseThemeHexColor(overrides['onSurface']),
    onSurfaceVariant: parseThemeHexColor(overrides['onSurfaceVariant']),
    outline: parseThemeHexColor(overrides['outline']),
    outlineVariant: parseThemeHexColor(overrides['outlineVariant']),
    inverseSurface: parseThemeHexColor(overrides['inverseSurface']),
    onInverseSurface: parseThemeHexColor(overrides['onInverseSurface']),
    inversePrimary: parseThemeHexColor(overrides['inversePrimary']),
    surfaceTint: parseThemeHexColor(overrides['surfaceTint']),
  );
}

Map<String, dynamic> themeDefinitionToExportJson(AppThemeDefinition theme) {
  return {
    'schemaVersion': 1,
    'name': theme.name,
    'brightness': theme.brightness,
    'seedColor': theme.seedColor,
    'overrides': decodeThemeOverrides(theme.overridesJson),
  };
}
