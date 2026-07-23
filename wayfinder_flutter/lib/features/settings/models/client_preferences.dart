import 'package:wayfinder_client/wayfinder_client.dart' as wf;

import '../../../app/app_locale_choice.dart';
import '../../../app/app_theme_choice.dart';
import '../../circles/models/circle_size_display.dart';
import '../../lines/models/angle_display_format.dart';
import '../../lines/models/bearing_reference.dart';
import '../../lines/models/measurement_units.dart';
import '../../markers/models/map_marker_size.dart';
import '../../map/models/map_zoom_limits.dart';

class ClientPreferences {
  const ClientPreferences({
    required this.measurementUnits,
    required this.angleDisplayFormat,
    required this.bearingReference,
    required this.circleSizeDisplay,
    required this.appTheme,
    required this.appLocale,
    required this.mapMarkerSizeScale,
    required this.mapViewportDebugBorder,
    required this.mapTileBorderDebug,
    required this.mapCompassRoseEnabled,
    required this.mapMgrsGridEnabled,
    required this.darkMapTilesInDarkMode,
    required this.polygonSnapRightAngles,
    required this.polygonSnap45Angles,
    required this.mapMinZoom,
    required this.mapMaxZoom,
  });

  final MeasurementUnits measurementUnits;
  final AngleDisplayFormat angleDisplayFormat;
  final BearingReference bearingReference;
  final CircleSizeDisplay circleSizeDisplay;
  final AppThemeChoice appTheme;
  final AppLocaleChoice appLocale;
  final double mapMarkerSizeScale;
  final bool mapViewportDebugBorder;
  final bool mapTileBorderDebug;
  final bool mapCompassRoseEnabled;
  final bool mapMgrsGridEnabled;
  final bool darkMapTilesInDarkMode;
  final bool polygonSnapRightAngles;
  final bool polygonSnap45Angles;
  final double mapMinZoom;
  final double mapMaxZoom;

  static final defaults = ClientPreferences(
    measurementUnits: MeasurementUnits.metric,
    angleDisplayFormat: AngleDisplayFormat.decimal,
    bearingReference: BearingReference.trueNorth,
    circleSizeDisplay: CircleSizeDisplay.radius,
    appTheme: AppThemeChoice.light,
    appLocale: AppLocaleChoice.system,
    mapMarkerSizeScale: mapMarkerSizeScaleDefault,
    mapViewportDebugBorder: false,
    mapTileBorderDebug: false,
    mapCompassRoseEnabled: true,
    mapMgrsGridEnabled: false,
    darkMapTilesInDarkMode: true,
    polygonSnapRightAngles: true,
    polygonSnap45Angles: false,
    mapMinZoom: MapZoomRange.defaults.min,
    mapMaxZoom: MapZoomRange.defaults.max,
  );

  factory ClientPreferences.fromAppSettings(wf.AppSettings settings) {
    final zoomRange = normalizeMapZoomRange(
      min: settings.mapMinZoom,
      max: settings.mapMaxZoom,
    );
    return ClientPreferences(
      measurementUnits: measurementUnitsFromStorage(settings.measurementUnits),
      angleDisplayFormat: angleDisplayFormatFromStorage(
        settings.angleDisplayFormat,
      ),
      bearingReference: bearingReferenceFromStorage(settings.bearingReference),
      circleSizeDisplay: circleSizeDisplayFromStorage(
        settings.circleSizeDisplay,
      ),
      appTheme: appThemeChoiceFromStorage(settings.appTheme),
      appLocale: appLocaleChoiceFromStorage(settings.appLocale),
      mapMarkerSizeScale: clampMapMarkerSizeScale(settings.mapMarkerSizeScale),
      mapViewportDebugBorder: settings.mapViewportDebugBorder,
      mapTileBorderDebug: settings.mapTileBorderDebug,
      mapCompassRoseEnabled: settings.mapCompassRoseEnabled,
      mapMgrsGridEnabled: settings.mapMgrsGridEnabled,
      darkMapTilesInDarkMode: settings.darkMapTilesInDarkMode,
      polygonSnapRightAngles: settings.polygonSnapRightAngles,
      polygonSnap45Angles: settings.polygonSnap45Angles,
      mapMinZoom: zoomRange.min,
      mapMaxZoom: zoomRange.max,
    );
  }

  factory ClientPreferences.fromUserClientPreferences(
    wf.UserClientPreferences prefs,
  ) {
    return ClientPreferences(
      measurementUnits: measurementUnitsFromStorage(prefs.measurementUnits),
      angleDisplayFormat: angleDisplayFormatFromStorage(
        prefs.angleDisplayFormat,
      ),
      bearingReference: bearingReferenceFromStorage(prefs.bearingReference),
      circleSizeDisplay: circleSizeDisplayFromStorage(prefs.circleSizeDisplay),
      appTheme: appThemeChoiceFromStorage(prefs.appTheme),
      appLocale: appLocaleChoiceFromStorage(prefs.appLocale),
      mapMarkerSizeScale: clampMapMarkerSizeScale(prefs.mapMarkerSizeScale),
      mapViewportDebugBorder: prefs.mapViewportDebugBorder,
      mapTileBorderDebug: prefs.mapTileBorderDebug,
      mapCompassRoseEnabled: prefs.mapCompassRoseEnabled,
      mapMgrsGridEnabled: prefs.mapMgrsGridEnabled,
      darkMapTilesInDarkMode: prefs.darkMapTilesInDarkMode,
      polygonSnapRightAngles: prefs.polygonSnapRightAngles,
      polygonSnap45Angles: prefs.polygonSnap45Angles,
      mapMinZoom: MapZoomRange.defaults.min,
      mapMaxZoom: MapZoomRange.defaults.max,
    );
  }

  factory ClientPreferences.fromJson(Map<String, dynamic> json) {
    final zoomRange = normalizeMapZoomRange(
      min: (json['mapMinZoom'] as num?)?.toDouble(),
      max: (json['mapMaxZoom'] as num?)?.toDouble(),
    );
    return ClientPreferences(
      measurementUnits: measurementUnitsFromStorage(
        json['measurementUnits'] as String?,
      ),
      angleDisplayFormat: angleDisplayFormatFromStorage(
        json['angleDisplayFormat'] as String?,
      ),
      bearingReference: bearingReferenceFromStorage(
        json['bearingReference'] as String?,
      ),
      circleSizeDisplay: circleSizeDisplayFromStorage(
        json['circleSizeDisplay'] as String?,
      ),
      appTheme: appThemeChoiceFromStorage(json['appTheme'] as String?),
      appLocale: appLocaleChoiceFromStorage(json['appLocale'] as String?),
      mapMarkerSizeScale: clampMapMarkerSizeScale(
        (json['mapMarkerSizeScale'] as num?)?.toDouble() ??
            mapMarkerSizeScaleDefault,
      ),
      mapViewportDebugBorder: json['mapViewportDebugBorder'] as bool? ?? false,
      mapTileBorderDebug: json['mapTileBorderDebug'] as bool? ?? false,
      mapCompassRoseEnabled: json['mapCompassRoseEnabled'] as bool? ?? true,
      mapMgrsGridEnabled: json['mapMgrsGridEnabled'] as bool? ?? false,
      darkMapTilesInDarkMode: json['darkMapTilesInDarkMode'] as bool? ?? true,
      polygonSnapRightAngles: json['polygonSnapRightAngles'] as bool? ?? true,
      polygonSnap45Angles: json['polygonSnap45Angles'] as bool? ?? false,
      mapMinZoom: zoomRange.min,
      mapMaxZoom: zoomRange.max,
    );
  }

  ClientPreferences copyWith({
    MeasurementUnits? measurementUnits,
    AngleDisplayFormat? angleDisplayFormat,
    BearingReference? bearingReference,
    CircleSizeDisplay? circleSizeDisplay,
    AppThemeChoice? appTheme,
    AppLocaleChoice? appLocale,
    double? mapMarkerSizeScale,
    bool? mapViewportDebugBorder,
    bool? mapTileBorderDebug,
    bool? mapCompassRoseEnabled,
    bool? mapMgrsGridEnabled,
    bool? darkMapTilesInDarkMode,
    bool? polygonSnapRightAngles,
    bool? polygonSnap45Angles,
    double? mapMinZoom,
    double? mapMaxZoom,
  }) {
    return ClientPreferences(
      measurementUnits: measurementUnits ?? this.measurementUnits,
      angleDisplayFormat: angleDisplayFormat ?? this.angleDisplayFormat,
      bearingReference: bearingReference ?? this.bearingReference,
      circleSizeDisplay: circleSizeDisplay ?? this.circleSizeDisplay,
      appTheme: appTheme ?? this.appTheme,
      appLocale: appLocale ?? this.appLocale,
      mapMarkerSizeScale: mapMarkerSizeScale ?? this.mapMarkerSizeScale,
      mapViewportDebugBorder:
          mapViewportDebugBorder ?? this.mapViewportDebugBorder,
      mapTileBorderDebug: mapTileBorderDebug ?? this.mapTileBorderDebug,
      mapCompassRoseEnabled:
          mapCompassRoseEnabled ?? this.mapCompassRoseEnabled,
      mapMgrsGridEnabled: mapMgrsGridEnabled ?? this.mapMgrsGridEnabled,
      darkMapTilesInDarkMode:
          darkMapTilesInDarkMode ?? this.darkMapTilesInDarkMode,
      polygonSnapRightAngles:
          polygonSnapRightAngles ?? this.polygonSnapRightAngles,
      polygonSnap45Angles: polygonSnap45Angles ?? this.polygonSnap45Angles,
      mapMinZoom: mapMinZoom ?? this.mapMinZoom,
      mapMaxZoom: mapMaxZoom ?? this.mapMaxZoom,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'measurementUnits': measurementUnitsToStorage(measurementUnits),
      'angleDisplayFormat': angleDisplayFormatToStorage(angleDisplayFormat),
      'bearingReference': bearingReferenceToStorage(bearingReference),
      'circleSizeDisplay': circleSizeDisplayToStorage(circleSizeDisplay),
      'appTheme': appThemeChoiceToStorage(appTheme),
      'appLocale': appLocaleChoiceToStorage(appLocale),
      'mapMarkerSizeScale': clampMapMarkerSizeScale(mapMarkerSizeScale),
      'mapViewportDebugBorder': mapViewportDebugBorder,
      'mapTileBorderDebug': mapTileBorderDebug,
      'mapCompassRoseEnabled': mapCompassRoseEnabled,
      'mapMgrsGridEnabled': mapMgrsGridEnabled,
      'darkMapTilesInDarkMode': darkMapTilesInDarkMode,
      'polygonSnapRightAngles': polygonSnapRightAngles,
      'polygonSnap45Angles': polygonSnap45Angles,
      'mapMinZoom': mapMinZoom,
      'mapMaxZoom': mapMaxZoom,
    };
  }

  /// Device-local prefs omit shared map zoom limits (those stay on the server).
  Map<String, dynamic> toLocalJson() {
    final json = toJson();
    json.remove('mapMinZoom');
    json.remove('mapMaxZoom');
    return json;
  }
}
