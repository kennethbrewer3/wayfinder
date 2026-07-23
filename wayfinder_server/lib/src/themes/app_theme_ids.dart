import 'package:serverpod/serverpod.dart';

import '../settings/app_settings_constants.dart';

/// Storage ids for [AppSettings.appTheme] / user prefs.
///
/// Built-ins use enum names (`light`, `militaryDark`, …). Custom TOC themes
/// use `custom:<uuid>`.
abstract final class AppThemeIds {
  static const customPrefix = 'custom:';

  static bool isBuiltIn(String value) =>
      AppSettingsConstants.allowedAppThemes.contains(value);

  static bool isCustom(String value) => value.startsWith(customPrefix);

  static String forCustom(UuidValue id) => '$customPrefix${id.uuid}';

  static UuidValue? tryParseCustomId(String value) {
    if (!isCustom(value)) {
      return null;
    }
    final raw = value.substring(customPrefix.length).trim();
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
