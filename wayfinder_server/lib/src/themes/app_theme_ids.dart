import 'package:serverpod/serverpod.dart';

import '../settings/app_settings_constants.dart';

/// Storage ids for [AppSettings.appTheme] / user prefs.
///
/// Built-ins use enum names (`light`, `militaryDark`, …). Custom TOC themes
/// use `custom:<uuid>` (light) or `custom:<uuid>:dark`.
abstract final class AppThemeIds {
  static const customPrefix = 'custom:';
  static const darkSuffix = ':dark';
  static const lightSuffix = ':light';

  static bool isBuiltIn(String value) =>
      AppSettingsConstants.allowedAppThemes.contains(value);

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

  static bool looksValid(String value) {
    if (isBuiltIn(value)) {
      return true;
    }
    return tryParseCustomId(value) != null;
  }
}
