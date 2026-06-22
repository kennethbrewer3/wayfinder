import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../core/wayfinder_env.dart';
import '../generated/protocol.dart';
import 'app_settings_constants.dart';

abstract final class AppSettingsStore {
  static Future<AppSettings> getOrCreate(Session session) async {
    final existing = await AppSettings.db.findFirstRow(session);
    if (existing != null) {
      return _ensurePmtilesStoragePath(session, existing);
    }

    return AppSettings.db.insertRow(
      session,
      AppSettings(
        homeLatitude: AppSettingsConstants.defaultHomeLatitude,
        homeLongitude: AppSettingsConstants.defaultHomeLongitude,
        homeZoom: AppSettingsConstants.defaultHomeZoom,
        pmtilesStoragePath: WayfinderEnv.resolveInitialPmtilesStoragePath(),
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }

  static Future<AppSettings> update(
    Session session,
    AppSettings settings,
  ) {
    return AppSettings.db.updateRow(
      session,
      settings.copyWith(updatedAt: DateTime.now().toUtc()),
    );
  }

  static String effectivePmtilesStoragePath(AppSettings settings) {
    final envPath = Platform.environment['WAYFINDER_PMTILES_STORAGE']?.trim();
    if (envPath != null && envPath.isNotEmpty) {
      return envPath;
    }
    final configured = settings.pmtilesStoragePath.trim();
    if (configured.isNotEmpty) {
      return configured;
    }
    return WayfinderEnv.resolveInitialPmtilesStoragePath();
  }

  static Future<AppSettings> _ensurePmtilesStoragePath(
    Session session,
    AppSettings settings,
  ) async {
    final effective = effectivePmtilesStoragePath(settings);
    if (settings.pmtilesStoragePath.trim() == effective) {
      return settings;
    }

    return update(
      session,
      settings.copyWith(pmtilesStoragePath: effective),
    );
  }

  static void validateHomeLocation({
    required double latitude,
    required double longitude,
    required double zoom,
  }) {
    if (latitude < -90 || latitude > 90) {
      throw FormatException('Latitude must be between -90 and 90.');
    }
    if (longitude < -180 || longitude > 180) {
      throw FormatException('Longitude must be between -180 and 180.');
    }
    if (zoom < 0 || zoom > AppSettingsConstants.maxHomeZoom) {
      throw FormatException(
        'Zoom must be between 0 and ${AppSettingsConstants.maxHomeZoom}.',
      );
    }
  }

  static void validatePmtilesStoragePath(String path) {
    final trimmed = path.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('PMTiles storage path is required.');
    }
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      throw const FormatException('PMTiles storage path must be a local folder.');
    }
  }
}
