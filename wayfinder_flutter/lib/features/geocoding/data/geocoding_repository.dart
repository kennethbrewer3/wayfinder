import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/app_globals.dart';
import '../../../core/logging/app_logger.dart';
import '../models/geocoding_models.dart';

class GeocodingRepository {
  GeocodingRepository({String? geocodingWebServerUrl})
      : _webServerUrl = _normalizeOptionalBaseUrl(geocodingWebServerUrl);

  final String? _webServerUrl;
  static final _log = AppLogger.logSettings;

  bool get isConfigured =>
      _webServerUrl != null && _webServerUrl!.trim().isNotEmpty;

  String get baseUrl {
    final url = _webServerUrl;
    if (url == null || url.isEmpty) {
      throw StateError('Geocoding server URL is not configured.');
    }
    return url;
  }

  Future<bool> isServerReachable() async {
    if (!isConfigured) {
      return false;
    }
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (error, _) {
      _log.warn('🌍 Geocoding server health check failed', error: error);
      return false;
    }
  }

  Future<GeocodingImportState> getSettings() => _getSettingsRest();

  Future<GeocodingSearchReadiness> getSearchReadiness() async {
    final uri = Uri.parse('$baseUrl/api/geocoding/search-readiness');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception(
        'GET /api/geocoding/search-readiness returned ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid search readiness response');
    }
    return GeocodingSearchReadiness.fromJson(decoded);
  }

  Future<GeocodingImportState> updateImportConfig({
    required String sourceUrl,
    List<String>? countryCodes,
  }) =>
      _updateSettingsRest(sourceUrl.trim(), countryCodes: countryCodes);

  Future<GeocodingImportState> startImport({
    String? sourceUrl,
    List<String>? countryCodes,
  }) =>
      _startImportRest(sourceUrl?.trim(), countryCodes: countryCodes);

  Future<GeocodingImportState> startHousenumbersImport({
    String? sourceUrl,
  }) =>
      _startHousenumbersImportRest(sourceUrl?.trim());

  Future<GeocodingImportState> cancelImport() => _cancelImportRest();

  Future<GeocodingImportState> cancelHousenumbersImport() =>
      _cancelHousenumbersImportRest();

  Future<String> exportPlacesArchive() => _exportPlacesArchiveRest();

  Future<String> exportHousenumbersArchive() =>
      _exportHousenumbersArchiveRest();

  Future<int> importPlacesArchive(String archiveJson) =>
      _importPlacesArchiveRest(archiveJson);

  Future<int> importHousenumbersArchive(String archiveJson) =>
      _importHousenumbersArchiveRest(archiveJson);

  Future<int> clearPlaces() => _clearPlacesRest();

  Future<int> clearHousenumbers() => _clearHousenumbersRest();

  Future<List<GeocodingPlaceResult>> searchPlaces(String query) async {
    if (!isConfigured) {
      return const [];
    }
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      return const [];
    }
    if (!await isServerReachable()) {
      return const [];
    }
    return _searchRest(trimmed);
  }

  Future<GeocodingImportState> _getSettingsRest() async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/geocoding/settings'));
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
      Uri.parse('$baseUrl/api/geocoding/settings'),
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
      Uri.parse('$baseUrl/api/geocoding/import'),
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
      Uri.parse('$baseUrl/api/geocoding/import/housenumbers'),
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

  Future<GeocodingImportState> _cancelImportRest() async {
    final response =
        await http.post(Uri.parse('$baseUrl/api/geocoding/import/cancel'));
    if (response.statusCode != 200) {
      throw Exception(
        'POST /api/geocoding/import/cancel returned ${response.statusCode}',
      );
    }
    return _mapSettingsJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<GeocodingImportState> _cancelHousenumbersImportRest() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/geocoding/import/housenumbers/cancel'),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'POST /api/geocoding/import/housenumbers/cancel returned ${response.statusCode}',
      );
    }
    return _mapSettingsJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<String> _exportPlacesArchiveRest() async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/geocoding/export/places'));
    if (response.statusCode != 200) {
      throw Exception(
        'GET /api/geocoding/export/places returned ${response.statusCode}',
      );
    }
    return response.body;
  }

  Future<String> _exportHousenumbersArchiveRest() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/geocoding/export/housenumbers'),
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
      Uri.parse('$baseUrl/api/geocoding/archive/places'),
      headers: const {'Content-Type': 'application/json'},
      body: archiveJson,
    );
    if (response.statusCode != 200) {
      throw Exception(
        'POST /api/geocoding/archive/places returned ${response.statusCode}',
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return (decoded['importedRowCount'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  Future<int> _importHousenumbersArchiveRest(String archiveJson) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/geocoding/archive/housenumbers'),
      headers: const {'Content-Type': 'application/json'},
      body: archiveJson,
    );
    if (response.statusCode != 200) {
      throw Exception(
        'POST /api/geocoding/archive/housenumbers returned ${response.statusCode}',
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return (decoded['importedRowCount'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  Future<int> _clearPlacesRest() async {
    final response =
        await http.delete(Uri.parse('$baseUrl/api/geocoding/places'));
    if (response.statusCode != 200) {
      throw Exception(
        'DELETE /api/geocoding/places returned ${response.statusCode}',
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return (decoded['removedRowCount'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  Future<int> _clearHousenumbersRest() async {
    final response =
        await http.delete(Uri.parse('$baseUrl/api/geocoding/housenumbers'));
    if (response.statusCode != 200) {
      throw Exception(
        'DELETE /api/geocoding/housenumbers returned ${response.statusCode}',
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return (decoded['removedRowCount'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  Future<List<GeocodingPlaceResult>> _searchRest(String query) async {
    final uri = Uri.parse('$baseUrl/api/geocoding/search').replace(
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

  static String? _normalizeOptionalBaseUrl(String? input) {
    if (input == null) {
      return null;
    }
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed.replaceAll(RegExp(r'/+$'), '');
  }
}

final geocodingRepositoryProvider = Provider<GeocodingRepository>((ref) {
  return GeocodingRepository(
    geocodingWebServerUrl: appServerConfig.geocodingWebUrl,
  );
});
