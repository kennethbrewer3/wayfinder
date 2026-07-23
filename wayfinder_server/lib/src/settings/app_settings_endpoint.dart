import 'package:serverpod/serverpod.dart';

import '../core/endpoint_logging.dart';
import '../generated/protocol.dart';
import '../access/wayfinder_permissions.dart';
import '../pmtiles/pmtiles_catalog_sync.dart';
import '../pmtiles/pmtiles_storage.dart';
import 'app_settings_constants.dart';
import 'app_settings_store.dart';
import 'rest_api_key_service.dart';
import 'user_client_preferences_store.dart';

class AppSettingsEndpoint extends Endpoint with EndpointLogging {
  static const _tag = 'appSettings';

  Future<AppSettings> getSettings(Session session) {
    return loggedCall(
      session,
      _tag,
      'getSettings',
      () => AppSettingsStore.getOrCreate(session),
    );
  }

  /// Personal UI prefs for the signed-in user (or shared TOC defaults when open).
  Future<UserClientPreferences> getMyClientPreferences(Session session) {
    return loggedCall(
      session,
      _tag,
      'getMyClientPreferences',
      () => UserClientPreferencesStore.getForCaller(session),
      requiredPermission: WayfinderPermission.viewMap,
    );
  }

  /// Saves personal UI prefs for the signed-in user (any role with view_map).
  Future<UserClientPreferences> updateMyClientPreferences(
    Session session,
    String measurementUnits,
    String angleDisplayFormat,
    String bearingReference,
    String circleSizeDisplay,
    String appTheme,
    String appLocale,
    double mapMarkerSizeScale,
    bool mapViewportDebugBorder,
    bool mapTileBorderDebug,
    bool mapCompassRoseEnabled,
    bool mapMgrsGridEnabled,
    bool darkMapTilesInDarkMode,
    bool polygonSnapRightAngles,
    bool polygonSnap45Angles,
  ) {
    return loggedCall(
      session,
      _tag,
      'updateMyClientPreferences',
      () => UserClientPreferencesStore.updateForCaller(
        session,
        measurementUnits: measurementUnits,
        angleDisplayFormat: angleDisplayFormat,
        bearingReference: bearingReference,
        circleSizeDisplay: circleSizeDisplay,
        appTheme: appTheme,
        appLocale: appLocale,
        mapMarkerSizeScale: mapMarkerSizeScale,
        mapViewportDebugBorder: mapViewportDebugBorder,
        mapTileBorderDebug: mapTileBorderDebug,
        mapCompassRoseEnabled: mapCompassRoseEnabled,
        mapMgrsGridEnabled: mapMgrsGridEnabled,
        darkMapTilesInDarkMode: darkMapTilesInDarkMode,
        polygonSnapRightAngles: polygonSnapRightAngles,
        polygonSnap45Angles: polygonSnap45Angles,
      ),
      onSuccess: (prefs) =>
          'units=${prefs.measurementUnits} theme=${prefs.appTheme} '
          'locale=${prefs.appLocale}',
      requiredPermission: WayfinderPermission.viewMap,
    );
  }

  Future<AppSettings> updateHomeLocation(
    Session session,
    double latitude,
    double longitude,
    double zoom,
  ) {
    return loggedCall(
      session,
      _tag,
      'updateHomeLocation',
      () async {
        AppSettingsStore.validateHomeLocation(
          latitude: latitude,
          longitude: longitude,
          zoom: zoom,
        );

        final settings = await AppSettingsStore.getOrCreate(session);
        return AppSettingsStore.update(
          session,
          settings.copyWith(
            homeLatitude: latitude,
            homeLongitude: longitude,
            homeZoom: zoom,
          ),
        );
      },
      onSuccess: (settings) =>
          'lat=${settings.homeLatitude} lng=${settings.homeLongitude} '
          'zoom=${settings.homeZoom}',
      requiredPermission: WayfinderPermission.manageMapHome,
    );
  }

  Future<AppSettings> resetHomeLocation(Session session) {
    return loggedCall(
      session,
      _tag,
      'resetHomeLocation',
      () async {
        final settings = await AppSettingsStore.getOrCreate(session);
        return AppSettingsStore.update(
          session,
          settings.copyWith(
            homeLatitude: AppSettingsConstants.defaultHomeLatitude,
            homeLongitude: AppSettingsConstants.defaultHomeLongitude,
            homeZoom: AppSettingsConstants.defaultHomeZoom,
          ),
        );
      },
      requiredPermission: WayfinderPermission.manageMapHome,
    );
  }

  Future<AppSettings> updateMapZoomRange(
    Session session,
    double mapMinZoom,
    double mapMaxZoom,
  ) {
    return loggedCall(
      session,
      _tag,
      'updateMapZoomRange',
      () async {
        AppSettingsStore.validateMapZoomRange(
          mapMinZoom: mapMinZoom,
          mapMaxZoom: mapMaxZoom,
        );
        final settings = await AppSettingsStore.getOrCreate(session);
        return AppSettingsStore.update(
          session,
          settings.copyWith(
            mapMinZoom: mapMinZoom,
            mapMaxZoom: mapMaxZoom,
          ),
        );
      },
      onSuccess: (settings) =>
          'min=${settings.mapMinZoom} max=${settings.mapMaxZoom}',
      requiredPermission: WayfinderPermission.manageMapZoom,
    );
  }

  Future<AppSettings> updatePmtilesStoragePath(
    Session session,
    String storagePath,
  ) {
    return loggedCall(
      session,
      _tag,
      'updatePmtilesStoragePath',
      () async {
        final trimmed = storagePath.trim();
        AppSettingsStore.validatePmtilesStoragePath(trimmed);

        final settings = await AppSettingsStore.getOrCreate(session);
        final updated = await AppSettingsStore.update(
          session,
          settings.copyWith(pmtilesStoragePath: trimmed),
        );
        PmtilesStorage.configure(
          AppSettingsStore.effectivePmtilesStoragePath(updated),
        );
        await PmtilesStorage().ensureReady();
        await PmtilesCatalogSync.sync(session);
        return updated;
      },
      onSuccess: (settings) => 'path="${settings.pmtilesStoragePath}"',
    );
  }

  Future<AppSettings> updateClientPreferences(
    Session session,
    String measurementUnits,
    String angleDisplayFormat,
    String bearingReference,
    String circleSizeDisplay,
    String appTheme,
    String appLocale,
    double mapMarkerSizeScale,
    bool mapViewportDebugBorder,
    bool mapTileBorderDebug,
    bool mapCompassRoseEnabled,
    bool mapMgrsGridEnabled,
    bool darkMapTilesInDarkMode,
    bool polygonSnapRightAngles,
    bool polygonSnap45Angles,
    double mapMinZoom,
    double mapMaxZoom,
  ) {
    return loggedCall(
      session,
      _tag,
      'updateClientPreferences',
      () async {
        // Shared TOC defaults for open/bootstrap mode and legacy clients.
        // Zoom range is intentionally ignored here — use [updateMapZoomRange]
        // (requires manage_map_zoom).
        AppSettingsStore.validatePersonalClientPreferences(
          measurementUnits: measurementUnits,
          angleDisplayFormat: angleDisplayFormat,
          bearingReference: bearingReference,
          circleSizeDisplay: circleSizeDisplay,
          appTheme: appTheme,
          appLocale: appLocale,
          mapMarkerSizeScale: mapMarkerSizeScale,
        );
        // Keep validating unused zoom args so malformed clients still fail loudly.
        AppSettingsStore.validateMapZoomRange(
          mapMinZoom: mapMinZoom,
          mapMaxZoom: mapMaxZoom,
        );

        final settings = await AppSettingsStore.getOrCreate(session);
        return AppSettingsStore.update(
          session,
          settings.copyWith(
            measurementUnits: measurementUnits,
            angleDisplayFormat: angleDisplayFormat,
            bearingReference: bearingReference,
            circleSizeDisplay: circleSizeDisplay,
            appTheme: appTheme,
            appLocale: appLocale,
            mapMarkerSizeScale: mapMarkerSizeScale,
            mapViewportDebugBorder: mapViewportDebugBorder,
            mapTileBorderDebug: mapTileBorderDebug,
            mapCompassRoseEnabled: mapCompassRoseEnabled,
            mapMgrsGridEnabled: mapMgrsGridEnabled,
            darkMapTilesInDarkMode: darkMapTilesInDarkMode,
            polygonSnapRightAngles: polygonSnapRightAngles,
            polygonSnap45Angles: polygonSnap45Angles,
          ),
        );
      },
      onSuccess: (settings) =>
          'units=${settings.measurementUnits} '
          'angles=${settings.angleDisplayFormat} '
          'bearing=${settings.bearingReference} '
          'circles=${settings.circleSizeDisplay} '
          'theme=${settings.appTheme} '
          'locale=${settings.appLocale} '
          'markerScale=${settings.mapMarkerSizeScale}',
      requiredPermission: WayfinderPermission.manageSettings,
    );
  }

  Future<RestApiKeyInfo> getRestApiKeyStatus(Session session) {
    return loggedCall(
      session,
      _tag,
      'getRestApiKeyStatus',
      () => RestApiKeyService.readStatus(session),
      onSuccess: (info) => 'enabled=${info.enabled}',
      requiredPermission: WayfinderPermission.manageApiKeys,
    );
  }

  Future<List<RestApiKey>> listRestApiKeys(Session session) {
    return loggedCall(
      session,
      _tag,
      'listRestApiKeys',
      () => RestApiKeyService.listKeys(session),
      onSuccess: (keys) => 'count=${keys.length}',
      requiredPermission: WayfinderPermission.manageApiKeys,
    );
  }

  Future<RestApiKeyCreated> createRestApiKey(Session session, String name) {
    return loggedCall(
      session,
      _tag,
      'createRestApiKey',
      () => RestApiKeyService.createKey(session, name),
      onSuccess: (created) => 'name="${created.key.name}"',
      requiredPermission: WayfinderPermission.manageApiKeys,
    );
  }

  Future<bool> deleteRestApiKey(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'deleteRestApiKey',
      () => RestApiKeyService.deleteKey(session, id),
      onSuccess: (deleted) => deleted ? 'deleted id=$id' : 'not found id=$id',
      requiredPermission: WayfinderPermission.manageApiKeys,
    );
  }

  Future<RestApiKeyInfo> clearRestApiKeys(Session session) {
    return loggedCall(
      session,
      _tag,
      'clearRestApiKeys',
      () async {
        await RestApiKeyService.clearStoredKeys(session);
        return RestApiKeyService.readStatus(session);
      },
      onSuccess: (info) => 'enabled=${info.enabled}',
      requiredPermission: WayfinderPermission.manageApiKeys,
    );
  }
}
