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

  Future<List<MarkerIconCategoryDefinition>> listCategories() async {
    return _client.markerIcon.listCategories();
  }

  Future<MarkerIconCategoryDefinition> createCategory({
    required String key,
    required String label,
    int? sortOrder,
  }) async {
    _log.debug('📍 Creating marker icon category', data: 'key=$key');
    final entry = await _client.markerIcon.createCategory(
      key,
      label,
      sortOrder: sortOrder,
    );
    _log.success('📍 Marker icon category created', data: 'key=$key');
    return entry;
  }

  Future<MarkerIconCategoryDefinition> updateCategory({
    required String key,
    required String label,
    int? sortOrder,
  }) async {
    _log.debug('📍 Updating marker icon category', data: 'key=$key');
    final entry = await _client.markerIcon.updateCategory(
      key,
      label,
      sortOrder: sortOrder,
    );
    _log.success('📍 Marker icon category updated', data: 'key=$key');
    return entry;
  }

  Future<void> deleteCategory(String key) async {
    _log.debug('📍 Deleting marker icon category', data: 'key=$key');
    final deleted = await _client.markerIcon.deleteCategory(key);
    if (!deleted) {
      throw StateError('Marker icon category not found: $key');
    }
    _log.success('📍 Marker icon category deleted', data: 'key=$key');
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
    final uri = Uri.parse('$_webServerUrl/marker-icons/upload').replace(
      queryParameters: {'key': key},
    );
    final request = http.Request('POST', uri)
      ..headers.addAll(
        await RestApiHeaders.readOnly(
          extra: {'Content-Type': 'image/svg+xml'},
        ),
      )
      ..bodyBytes = bytes;

    _log.debug(
      '📍 Uploading marker icon SVG',
      data: 'key=$key bytes=${bytes.length}',
    );
    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message =
          _readErrorMessage(body) ?? 'Upload failed (${response.statusCode})';
      throw StateError(message);
    }
    _log.success('📍 Marker icon SVG uploaded', data: 'key=$key');
  }

  Future<void> uploadSvgFile(String key, PlatformFile file) async {
    final bytes = await _readFileBytes(file);
    await uploadSvg(key: key, bytes: bytes);
  }

  Future<MarkerIconCatalogEntry> createIcon({
    required String key,
    required String label,
    String? category,
    String? materialIcon,
    bool coloredAsset = false,
    double glyphScale = 1.0,
    int? sortOrder,
  }) async {
    _log.debug('📍 Creating marker icon metadata', data: 'key=$key');
    final entry = await _client.markerIcon.createIcon(
      key,
      label,
      category: category,
      materialIcon: materialIcon,
      coloredAsset: coloredAsset,
      glyphScale: glyphScale,
      sortOrder: sortOrder,
    );
    _log.success('📍 Marker icon metadata created', data: 'key=$key');
    return entry;
  }

  Future<MarkerIconCatalogEntry> updateIcon({
    required String key,
    required String label,
    String? category,
    String? materialIcon,
    bool? coloredAsset,
    double? glyphScale,
    int? sortOrder,
  }) async {
    _log.debug('📍 Updating marker icon metadata', data: 'key=$key');
    final entry = await _client.markerIcon.updateIcon(
      key,
      label,
      category: category,
      materialIcon: materialIcon,
      coloredAsset: coloredAsset,
      glyphScale: glyphScale,
      sortOrder: sortOrder,
    );
    _log.success('📍 Marker icon metadata updated', data: 'key=$key');
    return entry;
  }

  Future<void> deleteIcon(String key) async {
    _log.debug('📍 Deleting marker icon', data: 'key=$key');
    final deleted = await _client.markerIcon.deleteIcon(key);
    if (!deleted) {
      throw StateError('Marker icon not found: $key');
    }
    _log.success('📍 Marker icon deleted', data: 'key=$key');
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
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }
}
