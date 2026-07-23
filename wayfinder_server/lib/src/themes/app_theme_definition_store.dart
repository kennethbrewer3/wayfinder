import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../settings/app_settings_constants.dart';
import '../settings/app_settings_store.dart';
import 'app_theme_ids.dart';

/// Shared TOC custom themes (seed + optional ColorScheme role overrides).
abstract final class AppThemeDefinitionStore {
  static const allowedBrightness = {'light', 'dark'};

  static const allowedOverrideRoles = {
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
  };

  static Future<List<AppThemeDefinition>> list(Session session) {
    return AppThemeDefinition.db.find(
      session,
      orderBy: (t) => t.name,
    );
  }

  static Future<AppThemeDefinition?> get(Session session, UuidValue id) {
    return AppThemeDefinition.db.findById(session, id);
  }

  static Future<AppThemeDefinition> create(
    Session session, {
    required String name,
    required String brightness,
    required String seedColor,
    required String overridesJson,
  }) async {
    final normalized = _normalize(
      name: name,
      brightness: brightness,
      seedColor: seedColor,
      overridesJson: overridesJson,
    );
    final now = DateTime.now().toUtc();
    return AppThemeDefinition.db.insertRow(
      session,
      AppThemeDefinition(
        name: normalized.name,
        brightness: normalized.brightness,
        seedColor: normalized.seedColor,
        overridesJson: normalized.overridesJson,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  static Future<AppThemeDefinition> update(
    Session session, {
    required UuidValue id,
    required String name,
    required String brightness,
    required String seedColor,
    required String overridesJson,
  }) async {
    final existing = await AppThemeDefinition.db.findById(session, id);
    if (existing == null) {
      throw ArgumentError.value(id, 'id', 'Theme not found');
    }
    final normalized = _normalize(
      name: name,
      brightness: brightness,
      seedColor: seedColor,
      overridesJson: overridesJson,
    );
    return AppThemeDefinition.db.updateRow(
      session,
      existing.copyWith(
        name: normalized.name,
        brightness: normalized.brightness,
        seedColor: normalized.seedColor,
        overridesJson: normalized.overridesJson,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }

  static Future<bool> delete(Session session, UuidValue id) async {
    final deleted = await AppThemeDefinition.db.deleteWhere(
      session,
      where: (t) => t.id.equals(id),
    );
    if (deleted.isEmpty) {
      return false;
    }

    final lightId = AppThemeIds.forCustom(id);
    final darkId = AppThemeIds.forCustom(id, dark: true);
    final fallback = AppSettingsConstants.defaultAppTheme;

    final settings = await AppSettingsStore.getOrCreate(session);
    if (settings.appTheme == lightId || settings.appTheme == darkId) {
      await AppSettingsStore.update(
        session,
        settings.copyWith(appTheme: fallback),
      );
    }

    final prefs = await UserClientPreferences.db.find(
      session,
      where: (t) => t.appTheme.equals(lightId) | t.appTheme.equals(darkId),
    );
    for (final pref in prefs) {
      await UserClientPreferences.db.updateRow(
        session,
        pref.copyWith(
          appTheme: fallback,
          updatedAt: DateTime.now().toUtc(),
        ),
      );
    }
    return true;
  }

  static Future<AppThemeDefinition> importDefinition(
    Session session,
    Map<String, dynamic> body,
  ) {
    final name = (body['name'] as String?)?.trim() ?? '';
    final brightness = (body['brightness'] as String?)?.trim() ?? 'light';
    final seedColor = (body['seedColor'] as String?)?.trim() ?? '';
    final overrides = body['overrides'];
    final overridesJson = overrides is Map
        ? jsonEncode(overrides)
        : (body['overridesJson'] as String? ?? '{}');
    return create(
      session,
      name: name.isEmpty ? 'Imported theme' : name,
      brightness: brightness,
      seedColor: seedColor,
      overridesJson: overridesJson,
    );
  }

  static Map<String, dynamic> toExportJson(AppThemeDefinition theme) {
    Object? overrides;
    try {
      overrides = jsonDecode(theme.overridesJson);
    } catch (_) {
      overrides = <String, dynamic>{};
    }
    return {
      'schemaVersion': 1,
      'name': theme.name,
      'brightness': theme.brightness,
      'seedColor': theme.seedColor,
      'overrides': overrides is Map ? overrides : <String, dynamic>{},
    };
  }

  static ({
    String name,
    String brightness,
    String seedColor,
    String overridesJson,
  })
  _normalize({
    required String name,
    required String brightness,
    required String seedColor,
    required String overridesJson,
  }) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw FormatException('Theme name is required');
    }
    if (trimmedName.length > 80) {
      throw FormatException('Theme name is too long');
    }
    final normalizedBrightness = brightness.trim().toLowerCase();
    if (!allowedBrightness.contains(normalizedBrightness)) {
      throw FormatException('Unsupported theme brightness: $brightness');
    }
    final normalizedSeed = _normalizeHexColor(seedColor, field: 'seedColor');
    final overrides = _normalizeOverridesJson(overridesJson);
    return (
      name: trimmedName,
      brightness: normalizedBrightness,
      seedColor: normalizedSeed,
      overridesJson: overrides,
    );
  }

  static String _normalizeOverridesJson(String raw) {
    late final Object? decoded;
    try {
      decoded = jsonDecode(raw.isEmpty ? '{}' : raw);
    } catch (_) {
      throw const FormatException('overridesJson must be a JSON object');
    }
    if (decoded is! Map) {
      throw const FormatException('overridesJson must be a JSON object');
    }
    final out = <String, String>{};
    for (final entry in decoded.entries) {
      final key = entry.key.toString();
      if (!allowedOverrideRoles.contains(key)) {
        throw FormatException('Unsupported color override role: $key');
      }
      final value = entry.value?.toString();
      if (value == null || value.trim().isEmpty) {
        continue;
      }
      out[key] = _normalizeHexColor(value, field: key);
    }
    return jsonEncode(out);
  }

  static String _normalizeHexColor(String raw, {required String field}) {
    var value = raw.trim();
    if (value.startsWith('#')) {
      value = value.substring(1);
    }
    if (value.length == 6 || value.length == 8) {
      final ok = RegExp(r'^[0-9a-fA-F]+$').hasMatch(value);
      if (ok) {
        return '#${value.toUpperCase()}';
      }
    }
    throw FormatException('Invalid hex color for $field: $raw');
  }
}
