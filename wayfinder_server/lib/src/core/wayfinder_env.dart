import 'dart:io';

/// Wayfinder-specific environment variables (in addition to Serverpod's
/// built-in `SERVERPOD_*` variables for ports and database settings).
class WayfinderEnv {
  WayfinderEnv._();

  static Map<String, String>? _dotEnvCache;

  /// Directory containing PMTiles map archives (`.pmtiles` files).
  ///
  /// Prefer [configuredPmtilesStoragePath] after startup. This getter is only
  /// used for early logging and as a fallback before the database is read.
  static String get pmtilesStoragePath => resolveInitialPmtilesStoragePath();

  /// Resolves the initial PMTiles folder from process env and `.env`.
  static String resolveInitialPmtilesStoragePath() {
    for (final key in ['WAYFINDER_PMTILES_STORAGE', 'WAYFINDER_PMTILES_HOST_PATH']) {
      final value = Platform.environment[key]?.trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    for (final key in ['WAYFINDER_PMTILES_HOST_PATH', 'WAYFINDER_PMTILES_STORAGE']) {
      final value = _readDotEnv(key);
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return 'storage/pmtiles';
  }

  static String? _readDotEnv(String key) {
    _dotEnvCache ??= _loadDotEnv();
    return _dotEnvCache![key];
  }

  static Map<String, String> _loadDotEnv() {
    final result = <String, String>{};
    final file = File('.env');
    if (!file.existsSync()) {
      return result;
    }

    for (final line in file.readAsLinesSync()) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) {
        continue;
      }
      final separator = trimmed.indexOf('=');
      if (separator <= 0) {
        continue;
      }
      final name = trimmed.substring(0, separator).trim();
      var value = trimmed.substring(separator + 1).trim();
      if ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'"))) {
        value = value.substring(1, value.length - 1);
      }
      result[name] = value;
    }
    return result;
  }
}
