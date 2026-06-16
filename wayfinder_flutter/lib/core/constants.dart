/// Application-wide constants for Wayfinder.
class AppConstants {
  AppConstants._();

  static const appName = 'Wayfinder';

  /// Default map center used when no viewport is saved.
  static const defaultLatitude = 38.903481;
  static const defaultLongitude = -77.262817;
  static const defaultZoom = 12.0;

  /// Maximum map zoom for pan/zoom interactions. PMTiles may contain tiles only
  /// up to their archive max zoom; levels above that overzoom the closest tiles.
  static const maxMapZoom = 18.0;

  /// Optional dev override via `--dart-define=PMTILES_PATH=/path/to/tiles.pmtiles`.
  static const pmtilesPath = String.fromEnvironment('PMTILES_PATH');

  static const viewportStorageKey = 'wayfinder.map.viewport';
  static const pmtilesManifestKey = 'wayfinder.pmtiles.manifest';
  static const activePmtilesIdKey = 'wayfinder.pmtiles.activeId';
  static const pmtilesDirectoryName = 'pmtiles';
  static const measurementUnitsStorageKey = 'wayfinder.settings.measurementUnits';
  static const angleDisplayFormatStorageKey = 'wayfinder.settings.angleDisplayFormat';
  static const circleSizeDisplayStorageKey = 'wayfinder.settings.circleSizeDisplay';
}
