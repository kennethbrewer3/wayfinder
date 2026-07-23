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
    for (final key in [
      'WAYFINDER_PMTILES_STORAGE',
      'WAYFINDER_PMTILES_HOST_PATH',
    ]) {
      final value = Platform.environment[key]?.trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    for (final key in [
      'WAYFINDER_PMTILES_HOST_PATH',
      'WAYFINDER_PMTILES_STORAGE',
    ]) {
      final value = _readDotEnv(key);
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return 'storage/pmtiles';
  }

  /// Directory containing marker icon SVG files.
  static String get markerIconStoragePath =>
      resolveInitialMarkerIconStoragePath();

  static String resolveInitialMarkerIconStoragePath() {
    for (final key in ['WAYFINDER_MARKER_ICON_STORAGE']) {
      final value = Platform.environment[key]?.trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return _readDotEnv('WAYFINDER_MARKER_ICON_STORAGE') ??
        'storage/marker-icons';
  }

  /// Directory containing marker photo / attachment blobs.
  static String get markerAttachmentStoragePath =>
      resolveInitialMarkerAttachmentStoragePath();

  static String resolveInitialMarkerAttachmentStoragePath() {
    for (final key in ['WAYFINDER_MARKER_ATTACHMENT_STORAGE']) {
      final value = Platform.environment[key]?.trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return _readDotEnv('WAYFINDER_MARKER_ATTACHMENT_STORAGE') ??
        'storage/marker-attachments';
  }

  /// Directory containing coastal tide packs (`catalog.json` + pack folders).
  static String get tidesStoragePath => resolveInitialTidesStoragePath();

  static String resolveInitialTidesStoragePath() {
    for (final key in ['WAYFINDER_TIDES_STORAGE']) {
      final value = Platform.environment[key]?.trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return _readDotEnv('WAYFINDER_TIDES_STORAGE') ?? 'storage/tides';
  }

  /// Optional shared secret for `/api` REST requests.
  ///
  /// When set (via process env or `.env`), REST clients must send this value in
  /// the `X-API-Key` header or as `Authorization: Bearer <key>`.
  static String? get restApiKey {
    for (final key in ['WAYFINDER_REST_API_KEY']) {
      final value = Platform.environment[key]?.trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return _readDotEnv('WAYFINDER_REST_API_KEY');
  }

  /// When true, the appliance rejects writes (spare TOC / viewer server).
  ///
  /// Set `WAYFINDER_READ_ONLY=1` or `true` in the process environment or `.env`.
  static bool get readOnly {
    for (final key in ['WAYFINDER_READ_ONLY']) {
      final value = Platform.environment[key]?.trim();
      if (value != null && value.isNotEmpty) {
        return _parseBool(value);
      }
    }
    final fromFile = _readDotEnv('WAYFINDER_READ_ONLY');
    if (fromFile != null && fromFile.isNotEmpty) {
      return _parseBool(fromFile);
    }
    return false;
  }

  /// Force authentication even before any membership rows exist.
  ///
  /// Auth is also required automatically once at least one user membership
  /// exists. Set `WAYFINDER_AUTH_REQUIRED=1` to require login from first boot.
  static bool get authRequired {
    for (final key in ['WAYFINDER_AUTH_REQUIRED']) {
      final value = Platform.environment[key]?.trim();
      if (value != null && value.isNotEmpty) {
        return _parseBool(value);
      }
    }
    final fromFile = _readDotEnv('WAYFINDER_AUTH_REQUIRED');
    if (fromFile != null && fromFile.isNotEmpty) {
      return _parseBool(fromFile);
    }
    return false;
  }

  /// Optional bootstrap admin login id (paired with [bootstrapAdminPassword]).
  ///
  /// This is a local username stored in the email IdP field — Wayfinder does
  /// not send email. Example: `admin`.
  static String? get bootstrapAdminEmail {
    for (final key in ['WAYFINDER_BOOTSTRAP_ADMIN_EMAIL']) {
      final value = Platform.environment[key]?.trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return _readDotEnv('WAYFINDER_BOOTSTRAP_ADMIN_EMAIL')?.trim();
  }

  /// Optional bootstrap admin password (paired with [bootstrapAdminEmail]).
  static String? get bootstrapAdminPassword {
    for (final key in ['WAYFINDER_BOOTSTRAP_ADMIN_PASSWORD']) {
      final value = Platform.environment[key];
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return _readDotEnv('WAYFINDER_BOOTSTRAP_ADMIN_PASSWORD');
  }

  static bool _parseBool(String raw) {
    final value = raw.trim().toLowerCase();
    return value == '1' || value == 'true' || value == 'yes' || value == 'on';
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
