abstract final class AppSettingsConstants {
  static const defaultHomeLatitude = 38.903481;
  static const defaultHomeLongitude = -77.262817;
  static const defaultHomeZoom = 12.0;
  static const absoluteHomeZoomMax = 30.0;
  static const defaultMapMinZoom = 2.0;
  static const defaultMapMaxZoom = 18.0;
  static const absoluteMapMinZoom = 1.0;
  static const absoluteMapMaxZoom = 30.0;
  static const defaultPmtilesStoragePath = 'storage/pmtiles';

  static const defaultMeasurementUnits = 'metric';
  static const defaultAngleDisplayFormat = 'decimal';
  static const defaultCircleSizeDisplay = 'radius';
  static const defaultAppTheme = 'light';
  static const defaultAppLocale = 'system';
  static const defaultMapMarkerSizeScale = 1.0;

  static const allowedMeasurementUnits = {'metric', 'imperial', 'nautical'};
  static const allowedAngleDisplayFormats = {'decimal', 'dms'};
  static const allowedCircleSizeDisplays = {'radius', 'diameter', 'none'};
  static const allowedAppThemes = {
    'light',
    'dark',
    'militaryLight',
    'militaryDark',
  };
  static const allowedAppLocales = {'system', 'en', 'es', 'fr'};
}
