import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'app_settings_store.dart';

const mapMarkerSizeScaleMin = 0.75;
const mapMarkerSizeScaleMax = 1.75;

/// User-facing settings stored in [AppSettings] and included in map backups.
Map<String, dynamic> exportAppSettingsBackup(AppSettings settings) {
  return {
    'homeLatitude': settings.homeLatitude,
    'homeLongitude': settings.homeLongitude,
    'homeZoom': settings.homeZoom,
    'pmtilesStoragePath': settings.pmtilesStoragePath,
    'measurementUnits': settings.measurementUnits,
    'angleDisplayFormat': settings.angleDisplayFormat,
    'circleSizeDisplay': settings.circleSizeDisplay,
    'appTheme': settings.appTheme,
    'appLocale': settings.appLocale,
    'mapMarkerSizeScale': settings.mapMarkerSizeScale,
    'mapViewportDebugBorder': settings.mapViewportDebugBorder,
    'mapTileBorderDebug': settings.mapTileBorderDebug,
    'mapCompassRoseEnabled': settings.mapCompassRoseEnabled,
    'mapMinZoom': settings.mapMinZoom,
    'mapMaxZoom': settings.mapMaxZoom,
  };
}

Future<void> restoreAppSettingsBackup(
  Session session,
  Map<String, dynamic> body,
) async {
  final homeLatitude = _readDouble(body['homeLatitude']);
  final homeLongitude = _readDouble(body['homeLongitude']);
  final homeZoom = _readDouble(body['homeZoom']);
  final pmtilesStoragePath = _readString(body['pmtilesStoragePath']);
  final measurementUnits = _readString(body['measurementUnits']);
  final angleDisplayFormat = _readString(body['angleDisplayFormat']);
  final circleSizeDisplay = _readString(body['circleSizeDisplay']);
  final appTheme = _readString(body['appTheme']);
  final appLocale = _readString(body['appLocale']);
  final mapMarkerSizeScale = _readDouble(body['mapMarkerSizeScale']);
  final mapViewportDebugBorder = _readBool(body['mapViewportDebugBorder']);
  final mapTileBorderDebug = _readBool(body['mapTileBorderDebug']);
  final mapCompassRoseEnabled = _readBool(body['mapCompassRoseEnabled']);
  final mapMinZoom = _readDouble(body['mapMinZoom']);
  final mapMaxZoom = _readDouble(body['mapMaxZoom']);

  if (homeLatitude == null ||
      homeLongitude == null ||
      homeZoom == null ||
      pmtilesStoragePath == null ||
      measurementUnits == null ||
      angleDisplayFormat == null ||
      circleSizeDisplay == null ||
      appTheme == null ||
      appLocale == null ||
      mapMarkerSizeScale == null ||
      mapViewportDebugBorder == null ||
      mapTileBorderDebug == null ||
      mapCompassRoseEnabled == null ||
      mapMinZoom == null ||
      mapMaxZoom == null) {
    throw const FormatException('Backup appSettings object is incomplete');
  }

  AppSettingsStore.validateHomeLocation(
    latitude: homeLatitude,
    longitude: homeLongitude,
    zoom: homeZoom,
  );
  AppSettingsStore.validatePmtilesStoragePath(pmtilesStoragePath);
  AppSettingsStore.validateClientPreferences(
    measurementUnits: measurementUnits,
    angleDisplayFormat: angleDisplayFormat,
    circleSizeDisplay: circleSizeDisplay,
    appTheme: appTheme,
    appLocale: appLocale,
    mapMarkerSizeScale: mapMarkerSizeScale,
    mapViewportDebugBorder: mapViewportDebugBorder,
    mapTileBorderDebug: mapTileBorderDebug,
    mapCompassRoseEnabled: mapCompassRoseEnabled,
    mapMinZoom: mapMinZoom,
    mapMaxZoom: mapMaxZoom,
  );

  final settings = await AppSettingsStore.getOrCreate(session);
  await AppSettingsStore.update(
    session,
    settings.copyWith(
      homeLatitude: homeLatitude,
      homeLongitude: homeLongitude,
      homeZoom: homeZoom,
      pmtilesStoragePath: pmtilesStoragePath,
      measurementUnits: measurementUnits,
      angleDisplayFormat: angleDisplayFormat,
      circleSizeDisplay: circleSizeDisplay,
      appTheme: appTheme,
      appLocale: appLocale,
      mapMarkerSizeScale: mapMarkerSizeScale,
      mapViewportDebugBorder: mapViewportDebugBorder,
      mapTileBorderDebug: mapTileBorderDebug,
      mapCompassRoseEnabled: mapCompassRoseEnabled,
      mapMinZoom: mapMinZoom,
      mapMaxZoom: mapMaxZoom,
    ),
  );
}

double? _readDouble(Object? raw) {
  if (raw is num) {
    return raw.toDouble();
  }
  return null;
}

String? _readString(Object? raw) {
  if (raw is String && raw.isNotEmpty) {
    return raw;
  }
  return null;
}

bool? _readBool(Object? raw) {
  if (raw is bool) {
    return raw;
  }
  return null;
}

void validateMapMarkerSizeScale(double value) {
  if (value < mapMarkerSizeScaleMin || value > mapMarkerSizeScaleMax) {
    throw FormatException(
      'mapMarkerSizeScale must be between '
      '$mapMarkerSizeScaleMin and $mapMarkerSizeScaleMax.',
    );
  }
}
