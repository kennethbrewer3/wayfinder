import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:wayfinder_client/wayfinder_client.dart' as wf;

import '../../../core/app_globals.dart';
import '../../../core/logging/app_logger.dart';
import '../../map/models/home_location.dart';

class AppSettingsRepository {
  AppSettingsRepository({
    required wf.Client client,
    required String webServerUrl,
  })  : _client = client,
        _webServerUrl = _normalizeBaseUrl(webServerUrl);

  final wf.Client _client;
  final String _webServerUrl;
  static final _log = AppLogger.logSettings;

  Future<HomeLocation> getHomeLocation() async {
    try {
      final settings = await _client.appSettings.getSettings();
      return _mapHomeLocation(settings);
    } catch (error, _) {
      _log.warn(
        '🏠 Home location RPC failed, trying REST',
        error: error,
      );
      return _getHomeLocationRest();
    }
  }

  Future<HomeLocation> updateHomeLocation(HomeLocation location) async {
    try {
      final settings = await _client.appSettings.updateHomeLocation(
        location.latitude,
        location.longitude,
        location.zoom,
      );
      return _mapHomeLocation(settings);
    } catch (error, _) {
      _log.warn(
        '🏠 Home location update RPC failed, trying REST',
        error: error,
      );
      return _updateHomeLocationRest(location);
    }
  }

  Future<HomeLocation> resetHomeLocation() async {
    try {
      final settings = await _client.appSettings.resetHomeLocation();
      return _mapHomeLocation(settings);
    } catch (error, _) {
      _log.warn(
        '🏠 Home location reset RPC failed, trying REST',
        error: error,
      );
      return _resetHomeLocationRest();
    }
  }

  Future<PmtilesStorageSettings> getPmtilesStoragePath() async {
    try {
      final settings = await _client.appSettings.getSettings();
      return _mapPmtilesStorage(settings);
    } catch (error, _) {
      _log.warn(
        '🗺️ PMTiles storage path RPC failed, trying REST',
        error: error,
      );
      return _getPmtilesStoragePathRest();
    }
  }

  Future<PmtilesStorageSettings> updatePmtilesStoragePath(
    String storagePath,
  ) async {
    try {
      final settings = await _client.appSettings.updatePmtilesStoragePath(
        storagePath.trim(),
      );
      return _mapPmtilesStorage(settings);
    } catch (error, _) {
      _log.warn(
        '🗺️ PMTiles storage path update RPC failed, trying REST',
        error: error,
      );
      return _updatePmtilesStoragePathRest(storagePath.trim());
    }
  }

  Future<HomeLocation> _getHomeLocationRest() async {
    final response =
        await http.get(Uri.parse('$_webServerUrl/api/settings/home'));
    if (response.statusCode != 200) {
      throw Exception(
        'GET /api/settings/home returned ${response.statusCode}',
      );
    }
    return _mapHomeLocationJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<HomeLocation> _updateHomeLocationRest(HomeLocation location) async {
    final response = await http.put(
      Uri.parse('$_webServerUrl/api/settings/home'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'latitude': location.latitude,
        'longitude': location.longitude,
        'zoom': location.zoom,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'PUT /api/settings/home returned ${response.statusCode}',
      );
    }
    return _mapHomeLocationJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<HomeLocation> _resetHomeLocationRest() async {
    final response =
        await http.delete(Uri.parse('$_webServerUrl/api/settings/home'));
    if (response.statusCode != 200) {
      throw Exception(
        'DELETE /api/settings/home returned ${response.statusCode}',
      );
    }
    return _mapHomeLocationJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<PmtilesStorageSettings> _getPmtilesStoragePathRest() async {
    final response = await http.get(
      Uri.parse('$_webServerUrl/api/settings/pmtiles-storage'),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'GET /api/settings/pmtiles-storage returned ${response.statusCode}',
      );
    }
    return _mapPmtilesStorageJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<PmtilesStorageSettings> _updatePmtilesStoragePathRest(
    String storagePath,
  ) async {
    final response = await http.put(
      Uri.parse('$_webServerUrl/api/settings/pmtiles-storage'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'storagePath': storagePath}),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'PUT /api/settings/pmtiles-storage returned ${response.statusCode}',
      );
    }
    return _mapPmtilesStorageJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  HomeLocation _mapHomeLocation(wf.AppSettings settings) {
    return HomeLocation(
      latitude: settings.homeLatitude,
      longitude: settings.homeLongitude,
      zoom: settings.homeZoom,
    );
  }

  HomeLocation _mapHomeLocationJson(Map<String, dynamic> json) {
    return HomeLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      zoom: (json['zoom'] as num).toDouble(),
    );
  }

  PmtilesStorageSettings _mapPmtilesStorage(wf.AppSettings settings) {
    return PmtilesStorageSettings(
      storagePath: settings.pmtilesStoragePath,
      effectiveStoragePath: settings.pmtilesStoragePath,
    );
  }

  PmtilesStorageSettings _mapPmtilesStorageJson(Map<String, dynamic> json) {
    return PmtilesStorageSettings(
      storagePath: json['storagePath'] as String? ?? '',
      effectiveStoragePath: json['effectiveStoragePath'] as String? ?? '',
    );
  }

  static String _normalizeBaseUrl(String input) {
    return input.replaceAll(RegExp(r'/+$'), '');
  }
}

final appSettingsRepositoryProvider = Provider<AppSettingsRepository>((ref) {
  return AppSettingsRepository(
    client: client,
    webServerUrl: appServerConfig.webUrl,
  );
});

class PmtilesStorageSettings {
  const PmtilesStorageSettings({
    required this.storagePath,
    required this.effectiveStoragePath,
  });

  final String storagePath;
  final String effectiveStoragePath;
}
