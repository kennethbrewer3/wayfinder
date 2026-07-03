import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/rest_api_headers.dart';
import '../models/marker_icon_catalog.dart';
import '../models/marker_icon_registry.dart';

class MarkerIconRepository {
  MarkerIconRepository({
    required Client client,
    required String webServerUrl,
  })  : _client = client,
        _webServerUrl = _normalizeBaseUrl(webServerUrl);

  final Client _client;
  final String _webServerUrl;
  static final _log = AppLogger.logMarkers;

  Future<List<MarkerIconCatalogEntry>> listRemoteEntries() async {
    return _client.markerIcon.listCatalog();
  }

  Future<MarkerIconCatalog> loadCatalog() async {
    _log.debug('📍 Loading marker icon catalog from server');
    try {
      final remote = await _client.markerIcon.listCatalog();
      final catalog = MarkerIconCatalog.merge(
        defaults: markerIconOptions,
        remote: remote,
        webBaseUrl: _webServerUrl,
      );
      _log.success(
        '📍 Marker icon catalog loaded',
        data: 'remote=${remote.length} total=${catalog.options.length}',
      );
      return catalog;
    } catch (error, stackTrace) {
      _log.error(
        '📍 Failed to load marker icon catalog',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> uploadSvg({
    required String key,
    required List<int> bytes,
  }) async {
    final uri = Uri.parse('$_webServerUrl/api/marker-icons/$key/svg');
    final request = http.Request('POST', uri)
      ..headers.addAll(
        await RestApiHeaders.readOnly(
          extra: {'Content-Type': 'image/svg+xml'},
        ),
      )
      ..bodyBytes = bytes;

    _log.debug('📍 Uploading marker icon SVG', data: 'key=$key bytes=${bytes.length}');
    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = _readErrorMessage(body) ??
          'Upload failed (${response.statusCode})';
      throw StateError(message);
    }
    _log.success('📍 Marker icon SVG uploaded', data: 'key=$key');
  }

  Future<void> uploadSvgFile(String key, PlatformFile file) async {
    final bytes = await _readFileBytes(file);
    await uploadSvg(key: key, bytes: bytes);
  }

  Future<Map<String, dynamic>> createIcon({
    required String key,
    required String label,
    String? materialIcon,
    bool coloredAsset = false,
    double glyphScale = 1.0,
    int? sortOrder,
  }) async {
    final uri = Uri.parse('$_webServerUrl/api/marker-icons');
    final payload = <String, dynamic>{
      'key': key,
      'label': label,
      if (materialIcon != null) 'materialIcon': materialIcon,
      'coloredAsset': coloredAsset,
      'glyphScale': glyphScale,
      if (sortOrder != null) 'sortOrder': sortOrder,
    };
    final response = await http.post(
      uri,
      headers: await RestApiHeaders.json(),
      body: jsonEncode(payload),
    );
    return _decodeJsonResponse(response);
  }

  Future<Map<String, dynamic>> updateIcon({
    required String key,
    String? label,
    bool? coloredAsset,
    double? glyphScale,
    int? sortOrder,
  }) async {
    final uri = Uri.parse('$_webServerUrl/api/marker-icons/$key');
    final payload = <String, dynamic>{
      if (label != null) 'label': label,
      if (coloredAsset != null) 'coloredAsset': coloredAsset,
      if (glyphScale != null) 'glyphScale': glyphScale,
      if (sortOrder != null) 'sortOrder': sortOrder,
    };
    final response = await http.patch(
      uri,
      headers: await RestApiHeaders.json(),
      body: jsonEncode(payload),
    );
    return _decodeJsonResponse(response);
  }

  Future<void> deleteIcon(String key) async {
    final uri = Uri.parse('$_webServerUrl/api/marker-icons/$key');
    final response = await http.delete(
      uri,
      headers: await RestApiHeaders.readOnly(),
    );
    if (response.statusCode == 204) {
      _log.success('📍 Marker icon deleted', data: 'key=$key');
      return;
    }
    _decodeJsonResponse(response);
  }

  Future<List<int>> _readFileBytes(PlatformFile file) async {
    final bytes = file.bytes;
    if (bytes != null && bytes.isNotEmpty) {
      return bytes;
    }

    final readStream = file.readStream;
    if (readStream != null) {
      return readStream.fold<List<int>>(
        <int>[],
        (previous, chunk) => previous..addAll(chunk),
      );
    }

    throw StateError('Could not read SVG file bytes');
  }

  Map<String, dynamic> _decodeJsonResponse(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? decoded['error']?.toString()
          : null;
      throw StateError(message ?? 'Request failed (${response.statusCode})');
    }
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Unexpected response from marker icon API');
    }
    return decoded;
  }

  String? _readErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded['error']?.toString();
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  static String _normalizeBaseUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      return trimmed;
    }
    return trimmed.endsWith('/') ? trimmed.substring(0, trimmed.length - 1) : trimmed;
  }
}
