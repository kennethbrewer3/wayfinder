import 'package:wayfinder_client/wayfinder_client.dart';

import 'app_theme_choice.dart';

/// Storage ids for the user's selected app theme preference.
///
/// Built-ins use [AppThemeChoice.name]. Custom TOC themes use `custom:<uuid>`
/// (light) or `custom:<uuid>:dark`. Dark mode for a custom theme is generated
/// from the same seed via [ColorScheme.fromSeed].
abstract final class AppThemeIds {
  static const customPrefix = 'custom:';
  static const darkSuffix = ':dark';
  static const lightSuffix = ':light';
  static const defaultId = 'light';

  static bool isBuiltIn(String value) =>
      AppThemeChoice.values.any((choice) => choice.name == value);

  static bool isCustom(String value) => value.startsWith(customPrefix);

  static bool isCustomDark(String value) {
    if (!isCustom(value)) {
      return false;
    }
    final raw = value.substring(customPrefix.length);
    return raw.endsWith(darkSuffix);
  }

  static String forCustom(UuidValue id, {bool dark = false}) {
    final base = '$customPrefix${id.uuid}';
    return dark ? '$base$darkSuffix' : base;
  }

  static String forCustomString(String uuid, {bool dark = false}) {
    final base = '$customPrefix$uuid';
    return dark ? '$base$darkSuffix' : base;
  }

  /// `custom:<uuid>` without a brightness suffix.
  static String customBaseId(String value) {
    final id = tryParseCustomId(value);
    if (id == null) {
      return value;
    }
    return forCustom(id);
  }

  static bool matchesCustom(String themeId, UuidValue id) {
    return tryParseCustomId(themeId) == id;
  }

  static UuidValue? tryParseCustomId(String value) {
    if (!isCustom(value)) {
      return null;
    }
    var raw = value.substring(customPrefix.length).trim();
    if (raw.endsWith(darkSuffix)) {
      raw = raw.substring(0, raw.length - darkSuffix.length);
    } else if (raw.endsWith(lightSuffix)) {
      raw = raw.substring(0, raw.length - lightSuffix.length);
    }
    if (raw.isEmpty) {
      return null;
    }
    try {
      return UuidValue.fromString(raw);
    } catch (_) {
      return null;
    }
  }

  static String withDarkMode(String themeId, bool dark) {
    final customId = tryParseCustomId(themeId);
    if (customId != null) {
      return forCustom(customId, dark: dark);
    }
    final builtIn = AppThemeChoice.values
        .where((choice) => choice.name == themeId)
        .firstOrNull;
    if (builtIn != null) {
      return AppThemeChoice.combine(
        builtIn.family,
        dark ? AppThemeBrightness.dark : AppThemeBrightness.light,
      ).name;
    }
    return dark ? AppThemeChoice.dark.name : AppThemeChoice.light.name;
  }

  static String normalize(String? value) {
    if (value == null || value.isEmpty) {
      return defaultId;
    }
    if (isBuiltIn(value) || tryParseCustomId(value) != null) {
      return value;
    }
    return defaultId;
  }
}
