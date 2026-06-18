import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/platform_file_utils.dart';
import '../models/pmtiles_archive_entry.dart';
import '../models/pmtiles_file.dart' as local;
import '../models/pmtiles_group.dart' as local_group;
import '../models/pmtiles_geo_bounds.dart';
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

  static int _compareNames(String a, String b) =>
      a.toLowerCase().compareTo(b.toLowerCase());

  Future<List<local.PmtilesFile>> listFiles() async {
    _log.debug('📋 Loading PMTiles catalog from server');
    final files = await _client.pmtiles.listFiles();
    final mapped = files.map(_mapFile).toList()
      ..sort((a, b) => _compareNames(a.name, b.name));
    _log.success('📋 Catalog loaded', data: 'count=${mapped.length}');
    return mapped;
  }

  Future<List<local.PmtilesFile>> listEnabledFiles() async {
    final files = await listFiles();
    return files.where((file) => file.enabledOnMap).toList();
  }

  Future<List<PmtilesSource>> resolveEnabledSources() async {
    final entries = await resolveEnabledEntries();
    return entries.map((entry) => entry.source).toList();
  }

  Future<List<PmtilesArchiveEntry>> resolveEnabledEntries() async {
    _log.debug('🧭 Resolving enabled PMTiles entries');
    final files = await _client.pmtiles.listFiles();
    final enabled = files.where((file) => file.isActive).toList()
      ..sort((a, b) => _compareNames(a.name, b.name));
    if (enabled.isEmpty) {
      _log.warn('🧭 No enabled PMTiles files on server');
      return const [];
    }

    return [
      for (final file in enabled) _mapArchiveEntry(file),
    ];
  }

  PmtilesArchiveEntry _mapArchiveEntry(PmtilesFile file) {
    final bounds = _boundsFromServer(file);
    return PmtilesArchiveEntry(
      id: file.id.uuid,
      name: file.name,
      source: PmtilesSourceUrl('$_webServerUrl/pmtiles/files/${file.id.uuid}'),
      bounds: bounds.bounds,
      boundsKnown: bounds.known,
      minZoom: file.minZoom ?? 0,
      maxZoom: file.maxZoom ?? 22,
    );
  }

  ({PmtilesGeoBounds bounds, bool known}) _boundsFromServer(PmtilesFile file) {
    final minLat = file.minLatitude;
    final maxLat = file.maxLatitude;
    final minLon = file.minLongitude;
    final maxLon = file.maxLongitude;
    if (minLat == null ||
        maxLat == null ||
        minLon == null ||
        maxLon == null) {
      return (
        bounds: const PmtilesGeoBounds(
          south: -90,
          west: -180,
          north: 90,
          east: 180,
        ),
        known: false,
      );
    }

    return (
      bounds: PmtilesGeoBounds.fromPositions(
        LatLng(minLat, minLon),
        LatLng(maxLat, maxLon),
      ),
      known: true,
    );
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

  Future<void> setFileEnabled(String id, {required bool enabled}) async {
    _log.info('🎯 Setting PMTiles enabled state', data: 'id=$id enabled=$enabled');
    await _client.pmtiles.setFileEnabled(
      UuidValue.fromString(id),
      enabled: enabled,
    );
    _log.success('🎯 PMTiles enabled state updated', data: id);
  }

  Future<void> enableAllFiles() async {
    _log.info('🎯 Enabling all PMTiles files on map');
    await _client.pmtiles.enableAllFiles();
    _log.success('🎯 All PMTiles files enabled on map');
  }

  Future<void> disableAllFiles() async {
    _log.info('🎯 Disabling all PMTiles files on map');
    await _client.pmtiles.disableAllFiles();
    _log.success('🎯 All PMTiles files disabled on map');
  }

  Future<List<local_group.PmtilesGroup>> listGroups() async {
    _log.debug('📋 Loading PMTiles groups from server');
    final groups = await _client.pmtiles.listGroups();
    final mapped = groups.map(_mapGroup).toList()
      ..sort((a, b) => _compareNames(a.name, b.name));
    _log.success('📋 Groups loaded', data: 'count=${mapped.length}');
    return mapped;
  }

  Future<local_group.PmtilesGroup> createGroup(String name) async {
    _log.info('📁 Creating PMTiles group', data: name);
    final group = await _client.pmtiles.createGroup(name);
    _log.success('📁 Group created', data: group.name);
    return _mapGroup(group);
  }

  Future<local_group.PmtilesGroup> renameGroup(String id, String name) async {
    _log.info('📁 Renaming PMTiles group', data: 'id=$id name=$name');
    final group = await _client.pmtiles.renameGroup(
      UuidValue.fromString(id),
      name,
    );
    return _mapGroup(group);
  }

  Future<void> deleteGroup(String id) async {
    _log.info('📁 Deleting PMTiles group', data: id);
    final deleted = await _client.pmtiles.deleteGroup(UuidValue.fromString(id));
    if (!deleted) {
      throw StateError('PMTiles group not found: $id');
    }
  }

  Future<void> setFileGroup(String fileId, {String? groupId}) async {
    _log.info(
      '📁 Assigning PMTiles file to group',
      data: 'fileId=$fileId groupId=${groupId ?? '(none)'}',
    );
    await _client.pmtiles.setFileGroup(
      UuidValue.fromString(fileId),
      groupId == null ? null : UuidValue.fromString(groupId),
    );
  }

  Future<void> setGroupEnabled(String groupId, {required bool enabled}) async {
    _log.info(
      '🎯 Setting PMTiles group enabled state',
      data: 'groupId=$groupId enabled=$enabled',
    );
    await _client.pmtiles.setGroupEnabled(
      UuidValue.fromString(groupId),
      enabled: enabled,
    );
  }

  Future<void> setUngroupedEnabled({required bool enabled}) async {
    _log.info(
      '🎯 Setting ungrouped PMTiles enabled state',
      data: 'enabled=$enabled',
    );
    await _client.pmtiles.setUngroupedEnabled(enabled: enabled);
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
      enabledOnMap: file.isActive,
      groupId: file.groupId?.uuid,
    );
  }

  local_group.PmtilesGroup _mapGroup(PmtilesGroup group) {
    return local_group.PmtilesGroup(
      id: group.id.uuid,
      name: group.name,
      sortOrder: group.sortOrder,
      createdAt: group.createdAt.toUtc(),
    );
  }

  bool _isPmtilesFile(String name) {
    return name.toLowerCase().endsWith('.pmtiles');
  }

  static String _normalizeBaseUrl(String url) {
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
}
