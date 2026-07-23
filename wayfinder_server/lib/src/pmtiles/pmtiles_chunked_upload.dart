import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../core/read_only_mode.dart';
import '../core/wayfinder_log.dart';
import '../generated/protocol.dart';
import '../web/rest/rest_json.dart';
import 'pmtiles_header_bounds.dart';
import 'pmtiles_storage.dart';

/// In-memory sessions for chunked PMTiles uploads (used by Flutter web).
///
/// Browser HTTP clients buffer entire request bodies before sending, so large
/// archives must be uploaded as many smaller POSTs that append to a partial
/// file. Each chunk produces a server log line so long uploads are visible.
abstract final class PmtilesChunkedUpload {
  static final Map<String, _Session> _sessions = {};

  static Future<Result> init(Session session, Request request) async {
    if (request.method == Method.options) {
      return Response.ok(headers: Headers.empty());
    }
    final denied = _rejectIfReadOnly();
    if (denied != null) {
      return denied;
    }

    final name = _readName(request);
    if (name == null) {
      return _badRequest('Query parameter "name" must end with .pmtiles');
    }

    final expectedBytes = _readIntQuery(request, 'size');
    final uploadId = const Uuid().v4obj().uuid;
    final storageId = const Uuid().v4obj().uuid;
    final storage = PmtilesStorage();
    await storage.ensureReady();

    final partial = storage.fileForId(storageId);
    await partial.writeAsBytes(const <int>[], flush: true);

    _sessions[uploadId] = _Session(
      uploadId: uploadId,
      storageId: storageId,
      name: name,
      expectedBytes: expectedBytes,
      startedAt: DateTime.now().toUtc(),
    );

    WfLog.info(
      session,
      'pmtiles',
      '📤 Chunked upload init "$name" | uploadId=$uploadId | '
          'storageId=$storageId | expected=${_formatBytesOrUnknown(expectedBytes)}',
    );

    return Response.ok(
      body: Body.fromString(
        jsonEncode({
          'uploadId': uploadId,
          'storageId': storageId,
          'name': name,
        }),
        mimeType: MimeType.json,
      ),
    );
  }

  static Future<Result> chunk(Session session, Request request) async {
    if (request.method == Method.options) {
      return Response.ok(headers: Headers.empty());
    }
    final denied = _rejectIfReadOnly();
    if (denied != null) {
      return denied;
    }

    final uploadId = request.queryParameters.raw['uploadId']?.trim();
    if (uploadId == null || uploadId.isEmpty) {
      return _badRequest('Query parameter "uploadId" is required');
    }

    final active = _sessions[uploadId];
    if (active == null) {
      return Response.notFound(
        body: Body.fromString(
          jsonEncode({'error': 'Unknown or expired uploadId'}),
          mimeType: MimeType.json,
        ),
      );
    }

    final offset = _readIntQuery(request, 'offset');
    if (offset != null && offset != active.receivedBytes) {
      return _badRequest(
        'Unexpected chunk offset $offset '
        '(expected ${active.receivedBytes})',
      );
    }

    final storage = PmtilesStorage();
    final file = storage.fileForId(active.storageId);
    final sink = file.openWrite(mode: FileMode.append);
    var chunkBytes = 0;
    try {
      await for (final part in request.read()) {
        sink.add(part);
        chunkBytes += part.length;
      }
    } catch (error, stackTrace) {
      await sink.close();
      WfLog.error(
        session,
        'pmtiles',
        '📤 Chunked upload chunk failed "${active.name}" | '
            'uploadId=$uploadId | offset=${active.receivedBytes}',
        error: error,
        stackTrace: stackTrace,
      );
      await _abort(uploadId);
      return Response.internalServerError(
        body: Body.fromString(
          jsonEncode({'error': 'Chunk upload failed'}),
          mimeType: MimeType.json,
        ),
      );
    }
    await sink.close();

    active.receivedBytes += chunkBytes;
    final elapsed = DateTime.now().toUtc().difference(active.startedAt);
    WfLog.info(
      session,
      'pmtiles',
      '📤 Chunked upload progress "${active.name}" | '
          'uploadId=$uploadId | '
          '+${_formatBytes(chunkBytes)} → '
          'received=${_formatBytes(active.receivedBytes)}'
          '${active.expectedBytes == null ? '' : ' / ${_formatBytes(active.expectedBytes!)}'} | '
          'elapsed=${_formatElapsed(elapsed)}'
          '${_rateSuffix(active.receivedBytes, elapsed)}',
    );

    return Response.ok(
      body: Body.fromString(
        jsonEncode({
          'uploadId': uploadId,
          'receivedBytes': active.receivedBytes,
        }),
        mimeType: MimeType.json,
      ),
    );
  }

  static Future<Result> complete(Session session, Request request) async {
    if (request.method == Method.options) {
      return Response.ok(headers: Headers.empty());
    }
    final denied = _rejectIfReadOnly();
    if (denied != null) {
      return denied;
    }

    final uploadId = request.queryParameters.raw['uploadId']?.trim();
    if (uploadId == null || uploadId.isEmpty) {
      return _badRequest('Query parameter "uploadId" is required');
    }

    final active = _sessions.remove(uploadId);
    if (active == null) {
      return Response.notFound(
        body: Body.fromString(
          jsonEncode({'error': 'Unknown or expired uploadId'}),
          mimeType: MimeType.json,
        ),
      );
    }

    final storage = PmtilesStorage();
    final storedFile = storage.fileForId(active.storageId);
    if (!storedFile.existsSync()) {
      return Response.internalServerError(
        body: Body.fromString(
          jsonEncode({'error': 'Partial upload missing on disk'}),
          mimeType: MimeType.json,
        ),
      );
    }

    try {
      final sizeBytes = await storedFile.length();
      WfLog.info(
        session,
        'pmtiles',
        '🧭 Reading PMTiles header/bounds for "${active.name}" '
            '(chunked complete)',
      );
      final bounds = await PmtilesHeaderBounds.readFromFile(storedFile);
      final id = UuidValue.fromString(active.storageId);
      final entry = PmtilesFile(
        id: id,
        name: active.name,
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

      final elapsed = DateTime.now().toUtc().difference(active.startedAt);
      WfLog.success(
        session,
        'pmtiles',
        '📤 Chunked upload complete "${active.name}" | '
            'id=${id.uuid} | size=${_formatBytes(sizeBytes)} | '
            'elapsed=${_formatElapsed(elapsed)}',
      );

      final json = Map<String, dynamic>.from(entry.toJson());
      json.remove('__className__');
      return Response.ok(
        body: Body.fromString(jsonEncode(json), mimeType: MimeType.json),
      );
    } catch (error, stackTrace) {
      WfLog.error(
        session,
        'pmtiles',
        '📤 Chunked upload complete failed "${active.name}"',
        error: error,
        stackTrace: stackTrace,
      );
      await storage.delete(active.storageId);
      return Response.internalServerError(
        body: Body.fromString(
          jsonEncode({'error': 'Upload finalize failed'}),
          mimeType: MimeType.json,
        ),
      );
    }
  }

  static Future<void> _abort(String uploadId) async {
    final active = _sessions.remove(uploadId);
    if (active == null) {
      return;
    }
    await PmtilesStorage().delete(active.storageId);
  }

  static Result? _rejectIfReadOnly() {
    if (!ReadOnlyMode.enabled) {
      return null;
    }
    return RestJson.error(
      403,
      'Server is in read-only / kiosk mode. '
      'Unset WAYFINDER_READ_ONLY to allow writes.',
    );
  }

  static String? _readName(Request request) {
    final name = request.queryParameters.raw['name']?.trim();
    if (name == null ||
        name.isEmpty ||
        !name.toLowerCase().endsWith('.pmtiles')) {
      return null;
    }
    return name;
  }

  static int? _readIntQuery(Request request, String key) {
    final raw = request.queryParameters.raw[key]?.trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return int.tryParse(raw);
  }

  static Response _badRequest(String error) {
    return Response.badRequest(
      body: Body.fromString(
        jsonEncode({'error': error}),
        mimeType: MimeType.json,
      ),
    );
  }
}

class _Session {
  _Session({
    required this.uploadId,
    required this.storageId,
    required this.name,
    required this.expectedBytes,
    required this.startedAt,
  });

  final String uploadId;
  final String storageId;
  final String name;
  final int? expectedBytes;
  final DateTime startedAt;
  int receivedBytes = 0;
}

String _formatBytesOrUnknown(int? bytes) {
  if (bytes == null || bytes <= 0) {
    return 'unknown';
  }
  return _formatBytes(bytes);
}

String _formatBytes(int bytes) {
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

String _formatElapsed(Duration elapsed) {
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

String _rateSuffix(int bytes, Duration elapsed) {
  final seconds = elapsed.inMilliseconds / 1000.0;
  if (bytes <= 0 || seconds < 1) {
    return '';
  }
  final bytesPerSecond = bytes / seconds;
  return ' | ~${_formatBytes(bytesPerSecond.round())}/s';
}
