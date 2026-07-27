/// Application-wide constants for Wayfinder.
class AppConstants {
  AppConstants._();

  static const appName = 'Wayfinder';

  /// Default map center used when no viewport is saved.
  static const defaultLatitude = 38.903481;
  static const defaultLongitude = -77.262817;
  static const defaultZoom = 12.0;

  /// Default interactive map zoom limits. Users can raise the maximum when
  /// higher-resolution offline tiles are available.
  static const defaultMapMinZoom = 2.0;
  static const defaultMapMaxZoom = 18.0;

  /// Hard limits for user-configurable map zoom range.
  static const absoluteMapMinZoom = 1.0;
  static const absoluteMapMaxZoom = 30.0;

  /// Upper bound for saved home-location zoom (independent of map range).
  static const absoluteHomeZoomMax = 30.0;

  /// Default maximum map zoom; prefer [defaultMapMaxZoom].
  static const maxMapZoom = defaultMapMaxZoom;

  static const viewportStorageKey = 'wayfinder.map.viewport';
  static const serverApiUrlStorageKey = 'wayfinder.settings.serverApiUrl';
  static const serverWebUrlStorageKey = 'wayfinder.settings.serverWebUrl';
  static const geocodingWebUrlStorageKey = 'wayfinder.settings.geocodingWebUrl';
  static const routingWebUrlStorageKey = 'wayfinder.settings.routingWebUrl';
}
