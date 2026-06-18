import 'dart:io';

/// Wayfinder-specific environment variables (in addition to Serverpod's
/// built-in `SERVERPOD_*` variables for ports and database settings).
class WayfinderEnv {
  WayfinderEnv._();

  /// Directory containing PMTiles map archives (`.pmtiles` files).
  ///
  /// Set `WAYFINDER_PMTILES_STORAGE` in `.env`, `docker-compose.yaml` comments,
  /// or the shell when starting the server. Pre-existing files in this folder
  /// are registered in the catalog at startup; client uploads are also stored
  /// here.
  ///
  /// Example: `/Volumes/maptiles` (SMB mount on macOS).
  static String get pmtilesStoragePath =>
      Platform.environment['WAYFINDER_PMTILES_STORAGE'] ?? 'storage/pmtiles';
}
