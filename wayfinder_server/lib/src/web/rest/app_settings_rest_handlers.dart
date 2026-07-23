import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../../pmtiles/pmtiles_catalog_sync.dart';
import '../../pmtiles/pmtiles_storage.dart';
import '../../settings/app_settings_constants.dart';
import '../../settings/app_settings_store.dart';
import 'rest_json.dart';

abstract final class AppSettingsRestHandlers {
  static Future<Result> getHomeLocation(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final settings = await AppSettingsStore.getOrCreate(session);
      return RestJson.ok(_encodeHomeLocation(settings));
    });
  }

  static Future<Result> updateHomeLocation(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final body = await RestJson.readObject(request);
      final latitude = _readDouble(body['latitude']);
      final longitude = _readDouble(body['longitude']);
      final zoom = _readDouble(body['zoom']);
      if (latitude == null || longitude == null || zoom == null) {
        throw const FormatException(
          'Fields "latitude", "longitude", and "zoom" are required.',
        );
      }

      AppSettingsStore.validateHomeLocation(
        latitude: latitude,
        longitude: longitude,
        zoom: zoom,
      );

      final settings = await AppSettingsStore.getOrCreate(session);
      final updated = await AppSettingsStore.update(
        session,
        settings.copyWith(
          homeLatitude: latitude,
          homeLongitude: longitude,
          homeZoom: zoom,
        ),
      );
      return RestJson.ok(_encodeHomeLocation(updated));
    });
  }

  static Future<Result> resetHomeLocation(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final settings = await AppSettingsStore.getOrCreate(session);
      final updated = await AppSettingsStore.update(
        session,
        settings.copyWith(
          homeLatitude: AppSettingsConstants.defaultHomeLatitude,
          homeLongitude: AppSettingsConstants.defaultHomeLongitude,
          homeZoom: AppSettingsConstants.defaultHomeZoom,
        ),
      );
      return RestJson.ok(_encodeHomeLocation(updated));
    });
  }

  static Future<Result> getMapZoomRange(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final settings = await AppSettingsStore.getOrCreate(session);
      return RestJson.ok({
        'mapMinZoom': settings.mapMinZoom,
        'mapMaxZoom': settings.mapMaxZoom,
      });
    });
  }

  static Future<Result> updateMapZoomRange(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final body = await RestJson.readObject(request);
      final mapMinZoom = _readDouble(body['mapMinZoom']);
      final mapMaxZoom = _readDouble(body['mapMaxZoom']);
      if (mapMinZoom == null || mapMaxZoom == null) {
        throw const FormatException(
          'Fields "mapMinZoom" and "mapMaxZoom" are required.',
        );
      }

      AppSettingsStore.validateMapZoomRange(
        mapMinZoom: mapMinZoom,
        mapMaxZoom: mapMaxZoom,
      );

      final settings = await AppSettingsStore.getOrCreate(session);
      final updated = await AppSettingsStore.update(
        session,
        settings.copyWith(
          mapMinZoom: mapMinZoom,
          mapMaxZoom: mapMaxZoom,
        ),
      );
      return RestJson.ok({
        'mapMinZoom': updated.mapMinZoom,
        'mapMaxZoom': updated.mapMaxZoom,
      });
    });
  }

  static Future<Result> getPmtilesStoragePath(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final settings = await AppSettingsStore.getOrCreate(session);
      return RestJson.ok(_encodePmtilesStorage(settings));
    });
  }

  static Future<Result> updatePmtilesStoragePath(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final body = await RestJson.readObject(request);
      final storagePath = (body['storagePath'] as String?)?.trim();
      if (storagePath == null || storagePath.isEmpty) {
        throw const FormatException('Field "storagePath" is required.');
      }

      AppSettingsStore.validatePmtilesStoragePath(storagePath);
      final settings = await AppSettingsStore.getOrCreate(session);
      final updated = await AppSettingsStore.update(
        session,
        settings.copyWith(pmtilesStoragePath: storagePath),
      );
      PmtilesStorage.configure(
        AppSettingsStore.effectivePmtilesStoragePath(updated),
      );
      await PmtilesStorage().ensureReady();
      await PmtilesCatalogSync.sync(session);
      return RestJson.ok(_encodePmtilesStorage(updated));
    });
  }

  static Future<Result> getClientPreferences(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final settings = await AppSettingsStore.getOrCreate(session);
      return RestJson.ok(_encodeClientPreferences(settings));
    });
  }

  static Future<Result> updateClientPreferences(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final body = await RestJson.readObject(request);
      final measurementUnits = _readString(body['measurementUnits']);
      final angleDisplayFormat = _readString(body['angleDisplayFormat']);
      final bearingReference =
          _readString(body['bearingReference']) ??
          AppSettingsConstants.defaultBearingReference;
      final circleSizeDisplay = _readString(body['circleSizeDisplay']);
      final appTheme = _readString(body['appTheme']);
      final appLocale = _readString(body['appLocale']);
      final mapMarkerSizeScale = _readDouble(body['mapMarkerSizeScale']);
      final mapViewportDebugBorder = _readBool(body['mapViewportDebugBorder']);
      final mapTileBorderDebug = _readBool(body['mapTileBorderDebug']);
      final mapCompassRoseEnabled = _readBool(body['mapCompassRoseEnabled']);
      final mapMgrsGridEnabled = _readBool(body['mapMgrsGridEnabled']) ?? false;
      final polygonSnapRightAngles =
          _readBool(body['polygonSnapRightAngles']) ?? true;
      final polygonSnap45Angles =
          _readBool(body['polygonSnap45Angles']) ?? false;
      if (measurementUnits == null ||
          angleDisplayFormat == null ||
          circleSizeDisplay == null ||
          appTheme == null ||
          appLocale == null ||
          mapMarkerSizeScale == null ||
          mapViewportDebugBorder == null ||
          mapTileBorderDebug == null ||
          mapCompassRoseEnabled == null) {
        throw const FormatException(
          'Fields "measurementUnits", "angleDisplayFormat", '
          '"circleSizeDisplay", "appTheme", "appLocale", '
          '"mapMarkerSizeScale", "mapViewportDebugBorder", '
          '"mapTileBorderDebug", and "mapCompassRoseEnabled" are required.',
        );
      }

      AppSettingsStore.validatePersonalClientPreferences(
        measurementUnits: measurementUnits,
        angleDisplayFormat: angleDisplayFormat,
        bearingReference: bearingReference,
        circleSizeDisplay: circleSizeDisplay,
        appTheme: appTheme,
        appLocale: appLocale,
        mapMarkerSizeScale: mapMarkerSizeScale,
      );

      final settings = await AppSettingsStore.getOrCreate(session);
      // Zoom range is not updated here — use PUT /settings/map-zoom.
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
          polygonSnapRightAngles: polygonSnapRightAngles,
          polygonSnap45Angles: polygonSnap45Angles,
        ),
      );
      return RestJson.ok(_encodeClientPreferences(updated));
    });
  }

  static Map<String, Object?> _encodeClientPreferences(AppSettings settings) {
    return {
      'measurementUnits': settings.measurementUnits,
      'angleDisplayFormat': settings.angleDisplayFormat,
      'bearingReference': settings.bearingReference,
      'circleSizeDisplay': settings.circleSizeDisplay,
      'appTheme': settings.appTheme,
      'appLocale': settings.appLocale,
      'mapMarkerSizeScale': settings.mapMarkerSizeScale,
      'mapViewportDebugBorder': settings.mapViewportDebugBorder,
      'mapTileBorderDebug': settings.mapTileBorderDebug,
      'mapCompassRoseEnabled': settings.mapCompassRoseEnabled,
      'mapMgrsGridEnabled': settings.mapMgrsGridEnabled,
      'polygonSnapRightAngles': settings.polygonSnapRightAngles,
      'polygonSnap45Angles': settings.polygonSnap45Angles,
      'mapMinZoom': settings.mapMinZoom,
      'mapMaxZoom': settings.mapMaxZoom,
      'updatedAt': settings.updatedAt.toIso8601String(),
    };
  }

  static Map<String, Object?> _encodePmtilesStorage(AppSettings settings) {
    return {
      'storagePath': settings.pmtilesStoragePath,
      'effectiveStoragePath': AppSettingsStore.effectivePmtilesStoragePath(
        settings,
      ),
      'updatedAt': settings.updatedAt.toIso8601String(),
    };
  }

  static Map<String, Object?> _encodeHomeLocation(AppSettings settings) {
    return {
      'latitude': settings.homeLatitude,
      'longitude': settings.homeLongitude,
      'zoom': settings.homeZoom,
      'updatedAt': settings.updatedAt.toIso8601String(),
    };
  }

  static double? _readDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.trim());
    }
    return null;
  }

  static String? _readString(Object? value) {
    if (value is! String) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static bool? _readBool(Object? value) {
    if (value is bool) {
      return value;
    }
    return null;
  }
}
