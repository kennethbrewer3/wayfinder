import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/constants.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/platform_file_utils.dart';
import '../models/pmtiles_file.dart' as local;
import '../models/pmtiles_source.dart';

class PmtilesRepository {
  PmtilesRepository({
    required Client client,
    required String webServerUrl,
  })  : _client = client,
        _webServerUrl = _normalizeBaseUrl(webServerUrl);

  final Client _client;
  final String _webServerUrl;
  static final _log = AppLogger.logPmtiles;

  Future<List<local.PmtilesFile>> listFiles() async {
    _log.debug('📋 Loading PMTiles catalog from server');
    final files = await _client.pmtiles.listFiles();
    final mapped = files.map(_mapFile).toList()
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    _log.success('📋 Catalog loaded', data: 'count=${mapped.length}');
    return mapped;
  }

  Future<String?> activeFileId() async {
    final activeId = await _client.pmtiles.activeFileId();
    _log.debug('🎯 Active PMTiles id', data: activeId?.uuid ?? '(none)');
    return activeId?.uuid;
  }

  Future<void> repairPersistence() async {
    final activeId = await activeFileId();
    if (activeId != null) {
      return;
    }

    final files = await listFiles();
    if (files.isEmpty) {
      return;
    }

    _log.warn('🎯 No active file on server — selecting first catalog entry');
    await setActiveFile(files.first.id);
  }

  Future<PmtilesSource?> resolveActiveSource() async {
    _log.debug('🧭 Resolving active PMTiles source');

    if (AppConstants.pmtilesPath.isNotEmpty) {
      _log.info(
        '🧭 Using dart-define PMTILES_PATH override',
        data: AppConstants.pmtilesPath,
      );
      return PmtilesSourcePath(AppConstants.pmtilesPath);
    }

    final activeId = await activeFileId();
    if (activeId == null) {
      final files = await listFiles();
      if (files.isEmpty) {
        _log.warn('🧭 No PMTiles files on server');
        return null;
      }
      await setActiveFile(files.first.id);
      return resolveActiveSource();
    }

    final url = '$_webServerUrl/pmtiles/files/$activeId';
    _log.success('🧭 Resolved server PMTiles URL', data: url);
    return PmtilesSourceUrl(url);
  }

  Future<local.PmtilesFile> uploadFile(PlatformFile file) async {
    _log.info('📤 Upload started', data: describePlatformFile(file));

    final name = file.name;
    if (!_isPmtilesFile(name)) {
      throw FormatException('Only .pmtiles files are supported.');
    }

    final uri = Uri.parse('$_webServerUrl/pmtiles/upload').replace(
      queryParameters: {'name': name},
    );

    final response = await _postFileStream(uri, file);

    if (response.statusCode != 200) {
      _log.error(
        '📤 Server upload failed',
        data: 'status=${response.statusCode} body=${response.body}',
      );
      final message = _uploadErrorMessage(response);
      throw StateError(message);
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final entry = _mapFile(PmtilesFile.fromJson(decoded));
    _log.success(
      '📤 Upload complete',
      data: 'id=${entry.id} name="${entry.name}"',
    );
    return entry;
  }

  Future<http.Response> _postFileStream(Uri uri, PlatformFile file) async {
    final stream = _openUploadStream(file);
    final request = http.StreamedRequest('POST', uri);
    request.headers['Content-Type'] = 'application/octet-stream';
    if (file.size > 0) {
      request.contentLength = file.size;
    }

    var uploaded = 0;
    _log.info(
      '📤 Streaming upload to server',
      data: 'size=${formatBytes(file.size)} url=$uri',
    );

    final responseFuture = request.send();
    try {
      await for (final chunk in stream) {
        uploaded += chunk.length;
        request.sink.add(chunk);
        if (uploaded == chunk.length ||
            uploaded % (32 * 1024 * 1024) < chunk.length) {
          _log.debug(
            '📤 Upload progress',
            data: '${formatBytes(uploaded)} / ${formatBytes(file.size)}',
          );
        }
      }
    } catch (error, stackTrace) {
      _log.error(
        '📤 Failed while reading file for upload',
        error: error,
        stackTrace: stackTrace,
      );
      await request.sink.close();
      rethrow;
    }

    await request.sink.close();
    final streamedResponse =
        await responseFuture.timeout(const Duration(hours: 2));
    return http.Response.fromStream(streamedResponse);
  }

  Stream<List<int>> _openUploadStream(PlatformFile file) {
    final readStream = file.readStream;
    if (readStream != null) {
      return readStream;
    }

    final bytes = file.bytes;
    if (bytes != null && bytes.isNotEmpty) {
      return Stream.value(bytes);
    }

    throw StateError(
      'Could not read "${file.name}". '
      'Large .pmtiles files must be uploaded using a stream — try choosing the file again.',
    );
  }

  String _uploadErrorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final error = decoded['error'];
      if (error is String && error.isNotEmpty) {
        return 'Server upload failed: $error';
      }
    } catch (_) {
      // Ignore malformed error bodies.
    }
    return 'Server upload failed (HTTP ${response.statusCode}).';
  }

  Future<void> setActiveFile(String id) async {
    _log.info('🎯 Setting active PMTiles file', data: id);
    await _client.pmtiles.setActiveFile(UuidValue.fromString(id));
    _log.success('🎯 Active file updated', data: id);
  }

  Future<void> clearActiveFile() async {
    _log.info('🎯 Clearing active PMTiles file');
    await _client.pmtiles.clearActiveFile();
    _log.success('🎯 Active file cleared');
  }

  Future<void> deleteFile(String id) async {
    _log.info('🗑️ Delete requested', data: id);
    final deleted = await _client.pmtiles.deleteFile(UuidValue.fromString(id));
    if (!deleted) {
      throw StateError('PMTiles file not found: $id');
    }
    _log.success('🗑️ Delete complete', data: id);
  }

  local.PmtilesFile _mapFile(PmtilesFile file) {
    return local.PmtilesFile(
      id: file.id.uuid,
      name: file.name,
      sizeBytes: file.sizeBytes,
      addedAt: file.addedAt.toUtc(),
    );
  }

  bool _isPmtilesFile(String name) {
    return name.toLowerCase().endsWith('.pmtiles');
  }

  static String _normalizeBaseUrl(String url) {
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
}
