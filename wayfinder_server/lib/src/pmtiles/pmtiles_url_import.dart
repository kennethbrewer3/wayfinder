import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../core/wayfinder_log.dart';
import '../generated/protocol.dart';
import 'pmtiles_header_bounds.dart';
import 'pmtiles_storage.dart';

/// Downloads a remote `.pmtiles` archive into local storage and catalogs it.
abstract final class PmtilesUrlImport {
  static const _tag = 'pmtiles';

  /// Hosts we will fetch from (SSRF protection).
  static const allowedHosts = <String>{
    'media.githubusercontent.com',
    'raw.githubusercontent.com',
    'download.mapterhorn.com',
    'build.protomaps.com',
  };

  static Future<Result> import(Session session, Request request) async {
    if (request.method == Method.options) {
      return Response.ok(headers: Headers.empty());
    }

    Map<String, dynamic> body;
    try {
      final raw = await request.readAsString();
      body = jsonDecode(raw) as Map<String, dynamic>;
    } on Object {
      return _badRequest('JSON body with "url" is required');
    }

    final urlRaw = (body['url'] as String?)?.trim() ?? '';
    if (urlRaw.isEmpty) {
      return _badRequest('Field "url" is required');
    }

    final uri = Uri.tryParse(urlRaw);
    if (uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.host.isEmpty) {
      return _badRequest('Field "url" must be an absolute http(s) URL');
    }
    if (!allowedHosts.contains(uri.host.toLowerCase())) {
      return _badRequest(
        'URL host is not allowed. Allowed: ${allowedHosts.join(', ')}',
      );
    }

    var name = (body['name'] as String?)?.trim();
    if (name == null || name.isEmpty) {
      name = uri.pathSegments.isEmpty
          ? 'archive.pmtiles'
          : uri.pathSegments.last;
    }
    name = name.replaceAll('\\', '/').split('/').last;
    if (!name.toLowerCase().endsWith('.pmtiles')) {
      name = '$name.pmtiles';
    }
    if (!_isSafeFileName(name)) {
      return _badRequest('Invalid archive name');
    }

    final storage = PmtilesStorage();
    final existing = await PmtilesFile.db.findFirstRow(
      session,
      where: (t) => t.name.equals(name!),
    );
    if (existing != null &&
        storage.existsForEntry(id: existing.id.uuid, name: existing.name)) {
      return Response(
        409,
        body: Body.fromString(
          jsonEncode({
            'error': 'An archive named "$name" is already in the catalog',
            'id': existing.id.uuid,
          }),
          mimeType: MimeType.json,
        ),
      );
    }

    final id = const Uuid().v4obj();
    final storageId = id.uuid;
    final startedAt = DateTime.now().toUtc();
    var receivedBytes = 0;

    WfLog.info(
      session,
      _tag,
      '📥 Remote import started "$name" | id=$storageId | url=$uri',
    );

    final heartbeat = Timer.periodic(const Duration(seconds: 15), (_) {
      final elapsed = DateTime.now().toUtc().difference(startedAt);
      WfLog.info(
        session,
        _tag,
        '📥 Remote import still downloading "$name" | '
        'received=${_formatBytes(receivedBytes)} | '
        'elapsed=${_formatElapsed(elapsed)}',
      );
    });

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 60);
    client.idleTimeout = const Duration(minutes: 30);
    try {
      final httpRequest = await client.getUrl(uri);
      httpRequest.headers.set(
        HttpHeaders.acceptHeader,
        'application/octet-stream,*/*',
      );
      final response = await httpRequest.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Remote server returned HTTP ${response.statusCode}',
          uri: uri,
        );
      }

      final expected = response.contentLength;
      await storage.ensureReady();
      final file = storage.fileForId(storageId);
      final sink = file.openWrite();
      try {
        await for (final chunk in response) {
          receivedBytes += chunk.length;
          sink.add(chunk);
        }
      } finally {
        await sink.close();
      }

      heartbeat.cancel();

      if (receivedBytes < 127) {
        throw FormatException(
          'Downloaded file is too small to be PMTiles ($receivedBytes bytes)',
        );
      }
      if (expected > 0 && receivedBytes != expected) {
        throw FormatException(
          'Download size mismatch: expected $expected, got $receivedBytes',
        );
      }

      final bounds = await PmtilesHeaderBounds.readFromFile(file);
      final sizeBytes = await file.length();
      final entry = PmtilesFile(
        id: id,
        name: name,
        sizeBytes: sizeBytes,
        isActive: true,
        addedAt: DateTime.now().toUtc(),
        minZoom: bounds.minZoom,
        maxZoom: bounds.maxZoom,
        minLatitude: bounds.minLatitude,
        minLongitude: bounds.minLongitude,
        maxLatitude: bounds.maxLatitude,
        maxLongitude: bounds.maxLongitude,
      );
      await PmtilesFile.db.insertRow(session, entry);

      final elapsed = DateTime.now().toUtc().difference(startedAt);
      WfLog.success(
        session,
        _tag,
        '📥 Remote import complete "$name" | id=${id.uuid} | '
        'size=${_formatBytes(sizeBytes)} | '
        'elapsed=${_formatElapsed(elapsed)}',
      );

      final json = Map<String, dynamic>.from(entry.toJson());
      json.remove('__className__');
      return Response.ok(
        body: Body.fromString(jsonEncode(json), mimeType: MimeType.json),
      );
    } catch (error, stackTrace) {
      heartbeat.cancel();
      WfLog.error(
        session,
        _tag,
        '📥 Remote import failed "$name" | url=$uri | '
        'received=${_formatBytes(receivedBytes)}',
        error: error,
        stackTrace: stackTrace,
      );
      await storage.delete(storageId);
      return Response.internalServerError(
        body: Body.fromString(
          jsonEncode({'error': 'Import failed: $error'}),
          mimeType: MimeType.json,
        ),
      );
    } finally {
      client.close();
    }
  }

  static bool _isSafeFileName(String name) {
    if (name.contains('..') || name.contains('/') || name.contains('\\')) {
      return false;
    }
    return RegExp(
      r'^[A-Za-z0-9][A-Za-z0-9._\- ]*\.pmtiles$',
      caseSensitive: false,
    ).hasMatch(name);
  }

  static Response _badRequest(String message) {
    return Response.badRequest(
      body: Body.fromString(
        jsonEncode({'error': message}),
        mimeType: MimeType.json,
      ),
    );
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static String _formatElapsed(Duration elapsed) {
    final totalSeconds = elapsed.inSeconds;
    if (totalSeconds < 60) {
      return '${totalSeconds}s';
    }
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (minutes < 60) {
      return '${minutes}m ${seconds}s';
    }
    final hours = minutes ~/ 60;
    final remMinutes = minutes % 60;
    return '${hours}h ${remMinutes}m';
  }
}
