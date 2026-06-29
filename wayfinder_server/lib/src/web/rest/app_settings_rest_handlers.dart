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
      final circleSizeDisplay = _readString(body['circleSizeDisplay']);
      final appTheme = _readString(body['appTheme']);
      final appLocale = _readString(body['appLocale']);
      if (measurementUnits == null ||
          angleDisplayFormat == null ||
          circleSizeDisplay == null ||
          appTheme == null ||
          appLocale == null) {
        throw const FormatException(
          'Fields "measurementUnits", "angleDisplayFormat", '
          '"circleSizeDisplay", "appTheme", and "appLocale" are required.',
        );
      }

      AppSettingsStore.validateClientPreferences(
        measurementUnits: measurementUnits,
        angleDisplayFormat: angleDisplayFormat,
        circleSizeDisplay: circleSizeDisplay,
        appTheme: appTheme,
        appLocale: appLocale,
      );

      final settings = await AppSettingsStore.getOrCreate(session);
      final updated = await AppSettingsStore.update(
        session,
        settings.copyWith(
          measurementUnits: measurementUnits,
          angleDisplayFormat: angleDisplayFormat,
          circleSizeDisplay: circleSizeDisplay,
          appTheme: appTheme,
          appLocale: appLocale,
        ),
      );
      return RestJson.ok(_encodeClientPreferences(updated));
    });
  }

  static Map<String, Object?> _encodeClientPreferences(AppSettings settings) {
    return {
      'measurementUnits': settings.measurementUnits,
      'angleDisplayFormat': settings.angleDisplayFormat,
      'circleSizeDisplay': settings.circleSizeDisplay,
      'appTheme': settings.appTheme,
      'appLocale': settings.appLocale,
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
}
