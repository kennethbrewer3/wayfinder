import 'package:serverpod/serverpod.dart';

import '../access/access_control.dart';
import '../generated/protocol.dart';
import 'app_settings_store.dart';

/// Per-signed-in-user UI preferences (theme, locale, units, map display, etc.).
abstract final class UserClientPreferencesStore {
  static Future<UserClientPreferences> getOrCreateForAuthUser(
    Session session,
    UuidValue authUserId,
  ) async {
    final existing = await UserClientPreferences.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );
    if (existing != null) {
      return existing;
    }

    final defaults = await AppSettingsStore.getOrCreate(session);
    final now = DateTime.now().toUtc();
    return UserClientPreferences.db.insertRow(
      session,
      UserClientPreferences(
        authUserId: authUserId,
        measurementUnits: defaults.measurementUnits,
        angleDisplayFormat: defaults.angleDisplayFormat,
        bearingReference: defaults.bearingReference,
        circleSizeDisplay: defaults.circleSizeDisplay,
        appTheme: defaults.appTheme,
        appLocale: defaults.appLocale,
        mapMarkerSizeScale: defaults.mapMarkerSizeScale,
        mapViewportDebugBorder: defaults.mapViewportDebugBorder,
        mapTileBorderDebug: defaults.mapTileBorderDebug,
        mapCompassRoseEnabled: defaults.mapCompassRoseEnabled,
        mapMgrsGridEnabled: defaults.mapMgrsGridEnabled,
        darkMapTilesInDarkMode: defaults.darkMapTilesInDarkMode,
        polygonSnapRightAngles: defaults.polygonSnapRightAngles,
        polygonSnap45Angles: defaults.polygonSnap45Angles,
        updatedAt: now,
      ),
    );
  }

  /// Resolves prefs for the current caller.
  ///
  /// - Auth required + signed in → per-user row (created from TOC defaults).
  /// - Open / bootstrap mode → synthetic row from shared [AppSettings].
  static Future<UserClientPreferences> getForCaller(Session session) async {
    final authRequired = await AccessControl.isAuthRequired(session);
    final auth = session.authenticated;
    if (!authRequired) {
      return _fromAppSettings(await AppSettingsStore.getOrCreate(session));
    }
    if (auth == null) {
      throw AccessDeniedException(
        'Authentication required. Sign in to continue.',
      );
    }
    return getOrCreateForAuthUser(session, AccessControl.authUserIdOf(auth));
  }

  static Future<UserClientPreferences> updateForCaller(
    Session session, {
    required String measurementUnits,
    required String angleDisplayFormat,
    required String bearingReference,
    required String circleSizeDisplay,
    required String appTheme,
    required String appLocale,
    required double mapMarkerSizeScale,
    required bool mapViewportDebugBorder,
    required bool mapTileBorderDebug,
    required bool mapCompassRoseEnabled,
    required bool mapMgrsGridEnabled,
    required bool darkMapTilesInDarkMode,
    required bool polygonSnapRightAngles,
    required bool polygonSnap45Angles,
  }) async {
    AppSettingsStore.validatePersonalClientPreferences(
      measurementUnits: measurementUnits,
      angleDisplayFormat: angleDisplayFormat,
      bearingReference: bearingReference,
      circleSizeDisplay: circleSizeDisplay,
      appTheme: appTheme,
      appLocale: appLocale,
      mapMarkerSizeScale: mapMarkerSizeScale,
    );
    await AppSettingsStore.assertAppThemeExists(session, appTheme);

    final authRequired = await AccessControl.isAuthRequired(session);
    if (!authRequired) {
      final settings = await AppSettingsStore.getOrCreate(session);
      final updated = await AppSettingsStore.update(
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
      return _fromAppSettings(updated);
    }

    final auth = session.authenticated;
    if (auth == null) {
      throw AccessDeniedException(
        'Authentication required. Sign in to continue.',
      );
    }
    final authUserId = AccessControl.authUserIdOf(auth);
    final current = await getOrCreateForAuthUser(session, authUserId);
    return UserClientPreferences.db.updateRow(
      session,
      current.copyWith(
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
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }

  static Future<void> deleteForAuthUser(
    Session session,
    UuidValue authUserId,
  ) async {
    await UserClientPreferences.db.deleteWhere(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );
  }

  static UserClientPreferences _fromAppSettings(AppSettings settings) {
    return UserClientPreferences(
      // Not persisted — open/bootstrap mode mirrors the shared AppSettings row.
      authUserId: UuidValue.fromString('00000000-0000-0000-0000-000000000000'),
      measurementUnits: settings.measurementUnits,
      angleDisplayFormat: settings.angleDisplayFormat,
      bearingReference: settings.bearingReference,
      circleSizeDisplay: settings.circleSizeDisplay,
      appTheme: settings.appTheme,
      appLocale: settings.appLocale,
      mapMarkerSizeScale: settings.mapMarkerSizeScale,
      mapViewportDebugBorder: settings.mapViewportDebugBorder,
      mapTileBorderDebug: settings.mapTileBorderDebug,
      mapCompassRoseEnabled: settings.mapCompassRoseEnabled,
      mapMgrsGridEnabled: settings.mapMgrsGridEnabled,
      darkMapTilesInDarkMode: settings.darkMapTilesInDarkMode,
      polygonSnapRightAngles: settings.polygonSnapRightAngles,
      polygonSnap45Angles: settings.polygonSnap45Angles,
      updatedAt: settings.updatedAt,
    );
  }
}
