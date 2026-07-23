import 'package:wayfinder_client/wayfinder_client.dart';

import 'app_theme_choice.dart';

/// Storage ids for the user's selected app theme preference.
///
/// Built-ins use [AppThemeChoice.name]. Custom TOC themes use `custom:<uuid>`.
abstract final class AppThemeIds {
  static const customPrefix = 'custom:';
  static const defaultId = 'light';

  static bool isBuiltIn(String value) =>
      AppThemeChoice.values.any((choice) => choice.name == value);

  static bool isCustom(String value) => value.startsWith(customPrefix);

  static String forCustom(UuidValue id) => '$customPrefix${id.uuid}';

  static String forCustomString(String uuid) => '$customPrefix$uuid';

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
