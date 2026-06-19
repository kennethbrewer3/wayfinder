import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:wayfinder_client/wayfinder_client.dart' as wf;

import '../../../core/app_globals.dart';
import '../../../core/logging/app_logger.dart';
import '../models/geocoding_models.dart';

class GeocodingRepository {
  GeocodingRepository({
    required wf.Client client,
    required String webServerUrl,
  })  : _client = client,
        _webServerUrl = _normalizeBaseUrl(webServerUrl);

  final wf.Client _client;
  final String _webServerUrl;
  static final _log = AppLogger.logSettings;

  Future<GeocodingImportState> getSettings() async {
    try {
      final settings = await _client.geocoding.getSettings();
      return _mapSettings(settings);
    } catch (error, _) {
      _log.warn(
        '🌍 Geocoding settings RPC failed, trying REST',
        error: error,
      );
      return _getSettingsRest();
    }
  }

  Future<GeocodingImportState> updateImportConfig({
    required String sourceUrl,
    List<String>? countryCodes,
  }) async {
    final trimmed = sourceUrl.trim();
    try {
      final settings = await _client.geocoding.updateSourceUrl(
        trimmed,
        countryCodes: countryCodes,
      );
      return _mapSettings(settings);
    } catch (error, _) {
      _log.warn(
        '🌍 Geocoding updateImportConfig RPC failed, trying REST',
        error: error,
      );
      return _updateSettingsRest(trimmed, countryCodes: countryCodes);
    }
  }

  Future<GeocodingImportState> startImport({
    String? sourceUrl,
    List<String>? countryCodes,
  }) async {
    try {
      final settings = await _client.geocoding.startImport(
        sourceUrl: sourceUrl?.trim(),
        countryCodes: countryCodes,
      );
      return _mapSettings(settings);
    } catch (error, _) {
      _log.warn(
        '🌍 Geocoding startImport RPC failed, trying REST',
        error: error,
      );
      return _startImportRest(
        sourceUrl?.trim(),
        countryCodes: countryCodes,
      );
    }
  }

  Future<GeocodingImportState> startHousenumbersImport({
    String? sourceUrl,
  }) async {
    try {
      final settings = await _client.geocoding.startHousenumbersImport(
        sourceUrl: sourceUrl?.trim(),
      );
      return _mapSettings(settings);
    } catch (error, _) {
      _log.warn(
        '🏠 Housenumbers startImport RPC failed, trying REST',
        error: error,
      );
      return _startHousenumbersImportRest(sourceUrl?.trim());
    }
  }

  Future<String> exportPlacesArchive() async {
    try {
      return await _client.geocoding.exportPlacesArchive();
    } catch (error, _) {
      _log.warn(
        '🌍 Places archive export RPC failed, trying REST',
        error: error,
      );
      return _exportPlacesArchiveRest();
    }
  }

  Future<String> exportHousenumbersArchive() async {
    try {
      return await _client.geocoding.exportHousenumbersArchive();
    } catch (error, _) {
      _log.warn(
        '🏠 Housenumbers archive export RPC failed, trying REST',
        error: error,
      );
      return _exportHousenumbersArchiveRest();
    }
  }

  Future<int> importPlacesArchive(String archiveJson) async {
    try {
      return await _client.geocoding.importPlacesArchive(archiveJson);
    } catch (error, _) {
      _log.warn(
        '🌍 Places archive import RPC failed, trying REST',
        error: error,
      );
      return _importPlacesArchiveRest(archiveJson);
    }
  }

  Future<int> importHousenumbersArchive(String archiveJson) async {
    try {
      return await _client.geocoding.importHousenumbersArchive(archiveJson);
    } catch (error, _) {
      _log.warn(
        '🏠 Housenumbers archive import RPC failed, trying REST',
        error: error,
      );
      return _importHousenumbersArchiveRest(archiveJson);
    }
  }

  Future<int> clearPlaces() async {
    try {
      return await _client.geocoding.clearPlaces();
    } catch (error, _) {
      _log.warn(
        '🌍 Places clear RPC failed, trying REST',
        error: error,
      );
      return _clearPlacesRest();
    }
  }

  Future<int> clearHousenumbers() async {
    try {
      return await _client.geocoding.clearHousenumbers();
    } catch (error, _) {
      _log.warn(
        '🏠 Housenumbers clear RPC failed, trying REST',
        error: error,
      );
      return _clearHousenumbersRest();
    }
  }

  Future<List<GeocodingPlaceResult>> searchPlaces(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      return const [];
    }

    try {
      final results = await _client.geocoding.searchPlaces(trimmed);
      return results.map(_mapPlace).toList();
    } catch (error, _) {
      _log.warn(
        '🌍 Geocoding search RPC failed, trying REST',
        error: error,
      );
      return _searchRest(trimmed);
    }
  }

  Future<GeocodingImportState> _getSettingsRest() async {
    final response =
        await http.get(Uri.parse('$_webServerUrl/api/geocoding/settings'));
    if (response.statusCode != 200) {
      throw Exception(
        'GET /api/geocoding/settings returned ${response.statusCode}',
      );
    }
    return _mapSettingsJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<GeocodingImportState> _updateSettingsRest(
    String sourceUrl, {
    List<String>? countryCodes,
  }) async {
    final response = await http.put(
      Uri.parse('$_webServerUrl/api/geocoding/settings'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'sourceUrl': sourceUrl,
        if (countryCodes != null && countryCodes.isNotEmpty)
          'countryCodes': countryCodes,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'PUT /api/geocoding/settings returned ${response.statusCode}',
      );
    }
    return _mapSettingsJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<GeocodingImportState> _startImportRest(
    String? sourceUrl, {
    List<String>? countryCodes,
  }) async {
    final response = await http.post(
      Uri.parse('$_webServerUrl/api/geocoding/import'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (sourceUrl != null && sourceUrl.isNotEmpty) 'sourceUrl': sourceUrl,
        if (countryCodes != null && countryCodes.isNotEmpty)
          'countryCodes': countryCodes,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'POST /api/geocoding/import returned ${response.statusCode}',
      );
    }
    return _mapSettingsJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<GeocodingImportState> _startHousenumbersImportRest(
    String? sourceUrl,
  ) async {
    final response = await http.post(
      Uri.parse('$_webServerUrl/api/geocoding/import/housenumbers'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (sourceUrl != null && sourceUrl.isNotEmpty) 'sourceUrl': sourceUrl,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'POST /api/geocoding/import/housenumbers returned ${response.statusCode}',
      );
    }
    return _mapSettingsJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<String> _exportPlacesArchiveRest() async {
    final response =
        await http.get(Uri.parse('$_webServerUrl/api/geocoding/export/places'));
    if (response.statusCode != 200) {
      throw Exception(
        'GET /api/geocoding/export/places returned ${response.statusCode}',
      );
    }
    return response.body;
  }

  Future<String> _exportHousenumbersArchiveRest() async {
    final response = await http.get(
      Uri.parse('$_webServerUrl/api/geocoding/export/housenumbers'),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'GET /api/geocoding/export/housenumbers returned ${response.statusCode}',
      );
    }
    return response.body;
  }

  Future<int> _importPlacesArchiveRest(String archiveJson) async {
    final response = await http.post(
      Uri.parse('$_webServerUrl/api/geocoding/archive/places'),
      headers: const {'Content-Type': 'application/json'},
      body: archiveJson,
    );
    if (response.statusCode != 200) {
      throw Exception(
        'POST /api/geocoding/archive/places returned ${response.statusCode}',
      );
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return (decoded['rowCount'] as num?)?.toInt() ?? 0;
  }

  Future<int> _importHousenumbersArchiveRest(String archiveJson) async {
    final response = await http.post(
      Uri.parse('$_webServerUrl/api/geocoding/archive/housenumbers'),
      headers: const {'Content-Type': 'application/json'},
      body: archiveJson,
    );
    if (response.statusCode != 200) {
      throw Exception(
        'POST /api/geocoding/archive/housenumbers returned ${response.statusCode}',
      );
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return (decoded['rowCount'] as num?)?.toInt() ?? 0;
  }

  Future<int> _clearPlacesRest() async {
    final response =
        await http.delete(Uri.parse('$_webServerUrl/api/geocoding/places'));
    if (response.statusCode != 200) {
      throw Exception(
        'DELETE /api/geocoding/places returned ${response.statusCode}',
      );
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return (decoded['removed'] as num?)?.toInt() ?? 0;
  }

  Future<int> _clearHousenumbersRest() async {
    final response = await http.delete(
      Uri.parse('$_webServerUrl/api/geocoding/housenumbers'),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'DELETE /api/geocoding/housenumbers returned ${response.statusCode}',
      );
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return (decoded['removed'] as num?)?.toInt() ?? 0;
  }

  Future<List<GeocodingPlaceResult>> _searchRest(String query) async {
    final uri = Uri.parse('$_webServerUrl/api/geocoding/search').replace(
      queryParameters: {'q': query},
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('GET /api/geocoding/search returned ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      return const [];
    }

    return [
      for (final item in decoded)
        if (item is Map<String, dynamic>) _mapPlaceJson(item),
    ];
  }

  GeocodingImportState _mapSettings(wf.GeocodingSettings settings) {
    final placesReady = settings.importStatus == geocodingStatusCompleted &&
        settings.importedRowCount > 0;
    final housenumbersReady =
        settings.housenumbersImportStatus == geocodingStatusCompleted &&
            settings.housenumbersImportedRowCount > 0;
    final placesRunning =
        settings.importStatus == geocodingStatusDownloading ||
            settings.importStatus == geocodingStatusImporting;
    final housenumbersRunning =
        settings.housenumbersImportStatus == geocodingStatusDownloading ||
            settings.housenumbersImportStatus == geocodingStatusImporting;

    return GeocodingImportState(
      sourceUrl: settings.sourceUrl,
      countryCodes: settings.countryCodes,
      importStatus: settings.importStatus,
      importedRowCount: settings.importedRowCount,
      importProgress: settings.importProgress,
      importError: settings.importError,
      importedAt: settings.importedAt,
      housenumbersSourceUrl: settings.housenumbersSourceUrl,
      housenumbersImportStatus: settings.housenumbersImportStatus,
      housenumbersImportedRowCount: settings.housenumbersImportedRowCount,
      housenumbersImportProgress: settings.housenumbersImportProgress,
      housenumbersImportError: settings.housenumbersImportError,
      housenumbersImportedAt: settings.housenumbersImportedAt,
      isReady: placesReady || housenumbersReady,
      isRunning: placesRunning || housenumbersRunning,
      isPlacesRunning: placesRunning,
      isHousenumbersRunning: housenumbersRunning,
    );
  }

  GeocodingImportState _mapSettingsJson(Map<String, dynamic> json) {
    return GeocodingImportState(
      sourceUrl: json['sourceUrl'] as String? ?? defaultGeocodingSourceUrl,
      countryCodes: json['countryCodes'] as String?,
      importStatus: json['importStatus'] as String? ?? geocodingStatusIdle,
      importedRowCount: (json['importedRowCount'] as num?)?.toInt() ?? 0,
      importProgress: (json['importProgress'] as num?)?.toDouble() ?? 0,
      importError: json['importError'] as String?,
      importedAt: _parseDate(json['importedAt']),
      housenumbersSourceUrl: json['housenumbersSourceUrl'] as String? ??
          defaultHousenumbersSourceUrl,
      housenumbersImportStatus:
          json['housenumbersImportStatus'] as String? ?? geocodingStatusIdle,
      housenumbersImportedRowCount:
          (json['housenumbersImportedRowCount'] as num?)?.toInt() ?? 0,
      housenumbersImportProgress:
          (json['housenumbersImportProgress'] as num?)?.toDouble() ?? 0,
      housenumbersImportError: json['housenumbersImportError'] as String?,
      housenumbersImportedAt: _parseDate(json['housenumbersImportedAt']),
      isReady: json['isReady'] as bool? ?? false,
      isRunning: json['isRunning'] as bool? ?? false,
      isPlacesRunning: json['isPlacesRunning'] as bool? ?? false,
      isHousenumbersRunning: json['isHousenumbersRunning'] as bool? ?? false,
    );
  }

  GeocodingPlaceResult _mapPlace(wf.GeocodeSearchResult result) {
    return GeocodingPlaceResult(
      id: result.id,
      name: result.name,
      displayName: result.displayName,
      latitude: result.latitude,
      longitude: result.longitude,
      countryCode: result.countryCode,
      importance: result.importance,
      resultType: result.resultType,
    );
  }

  GeocodingPlaceResult _mapPlaceJson(Map<String, dynamic> json) {
    return GeocodingPlaceResult(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      displayName: json['displayName'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      countryCode: json['countryCode'] as String?,
      importance: (json['importance'] as num?)?.toDouble() ?? 0,
      resultType:
          json['resultType'] as String? ?? geocodingResultTypePlace,
    );
  }

  DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  static String _normalizeBaseUrl(String input) {
    return input.replaceAll(RegExp(r'/+$'), '');
  }
}

final geocodingRepositoryProvider = Provider<GeocodingRepository>((ref) {
  return GeocodingRepository(
    client: client,
    webServerUrl: appServerConfig.webUrl,
  );
});
