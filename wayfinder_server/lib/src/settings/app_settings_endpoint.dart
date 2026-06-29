import 'package:serverpod/serverpod.dart';

import '../core/endpoint_logging.dart';
import '../generated/protocol.dart';
import '../pmtiles/pmtiles_catalog_sync.dart';
import '../pmtiles/pmtiles_storage.dart';
import 'app_settings_constants.dart';
import 'app_settings_store.dart';
import 'rest_api_key_service.dart';

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
    String circleSizeDisplay,
    String appTheme,
    String appLocale,
  ) {
    return loggedCall(
      session,
      _tag,
      'updateClientPreferences',
      () async {
        AppSettingsStore.validateClientPreferences(
          measurementUnits: measurementUnits,
          angleDisplayFormat: angleDisplayFormat,
          circleSizeDisplay: circleSizeDisplay,
          appTheme: appTheme,
          appLocale: appLocale,
        );

        final settings = await AppSettingsStore.getOrCreate(session);
        return AppSettingsStore.update(
          session,
          settings.copyWith(
            measurementUnits: measurementUnits,
            angleDisplayFormat: angleDisplayFormat,
            circleSizeDisplay: circleSizeDisplay,
            appTheme: appTheme,
            appLocale: appLocale,
          ),
        );
      },
      onSuccess: (settings) =>
          'units=${settings.measurementUnits} '
          'angles=${settings.angleDisplayFormat} '
          'circles=${settings.circleSizeDisplay} '
          'theme=${settings.appTheme} '
          'locale=${settings.appLocale}',
    );
  }

  Future<RestApiKeyInfo> getRestApiKeyStatus(Session session) {
    return loggedCall(
      session,
      _tag,
      'getRestApiKeyStatus',
      () => RestApiKeyService.readStatus(session),
      onSuccess: (info) => 'enabled=${info.enabled}',
    );
  }

  Future<List<RestApiKey>> listRestApiKeys(Session session) {
    return loggedCall(
      session,
      _tag,
      'listRestApiKeys',
      () => RestApiKeyService.listKeys(session),
      onSuccess: (keys) => 'count=${keys.length}',
    );
  }

  Future<RestApiKeyCreated> createRestApiKey(Session session, String name) {
    return loggedCall(
      session,
      _tag,
      'createRestApiKey',
      () => RestApiKeyService.createKey(session, name),
      onSuccess: (created) => 'name="${created.key.name}"',
    );
  }

  Future<bool> deleteRestApiKey(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'deleteRestApiKey',
      () => RestApiKeyService.deleteKey(session, id),
      onSuccess: (deleted) => deleted ? 'deleted id=$id' : 'not found id=$id',
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
    );
  }
}
