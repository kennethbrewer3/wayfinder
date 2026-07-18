import 'dart:async';
import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../core/wayfinder_log.dart';
import '../generated/protocol.dart';
import 'pmtiles_header_bounds.dart';
import 'pmtiles_storage.dart';

/// Handles a raw PMTiles upload request and registers catalog metadata.
Future<Result> handlePmtilesUpload(Session session, Request request) async {
  if (request.method == Method.options) {
    return Response.ok(headers: Headers.empty());
  }

  final name = request.queryParameters.raw['name']?.trim();
  if (name == null ||
      name.isEmpty ||
      !name.toLowerCase().endsWith('.pmtiles')) {
    return Response.badRequest(
      body: Body.fromString(
        jsonEncode({
          'error': 'Query parameter "name" must end with .pmtiles',
        }),
        mimeType: MimeType.json,
      ),
    );
  }

  final storage = PmtilesStorage();
  final id = const Uuid().v4obj();
  final storageId = id.uuid;
  final expectedBytes =
      request.headers.contentLength ?? request.body.contentLength;
  final startedAt = DateTime.now().toUtc();
  var receivedBytes = 0;
  var lastByteLogAt = 0;

  WfLog.info(
    session,
    'pmtiles',
    '📤 Upload started "$name" | id=$storageId | '
    'expected=${_formatBytesOrUnknown(expectedBytes)}',
  );

  // Heartbeat so long transfers still appear active in server logs even when
  // chunks are infrequent (slow links) or the next chunk is delayed.
  final heartbeat = Timer.periodic(const Duration(seconds: 15), (_) {
    final elapsed = DateTime.now().toUtc().difference(startedAt);
    WfLog.info(
      session,
      'pmtiles',
      '📤 Upload still receiving "$name" | '
      'received=${_formatBytes(receivedBytes)}'
      '${expectedBytes == null ? '' : ' / ${_formatBytes(expectedBytes)}'} | '
      'elapsed=${_formatElapsed(elapsed)}'
      '${_rateSuffix(receivedBytes, elapsed)}',
    );
  });

  try {
    final body = request.read().map((chunk) {
      receivedBytes += chunk.length;
      // Extra byte-threshold logs between heartbeats for large transfers.
      if (receivedBytes - lastByteLogAt >= 32 * 1024 * 1024) {
        lastByteLogAt = receivedBytes;
        final elapsed = DateTime.now().toUtc().difference(startedAt);
        WfLog.info(
          session,
          'pmtiles',
          '📤 Upload progress "$name" | '
          'received=${_formatBytes(receivedBytes)}'
          '${expectedBytes == null ? '' : ' / ${_formatBytes(expectedBytes)}'} | '
          'elapsed=${_formatElapsed(elapsed)}'
          '${_rateSuffix(receivedBytes, elapsed)}',
        );
      }
      return chunk;
    });

    await storage.writeStream(storageId, body);
    heartbeat.cancel();

    final receiveElapsed = DateTime.now().toUtc().difference(startedAt);
    WfLog.info(
      session,
      'pmtiles',
      '📤 Upload bytes received "$name" | '
      'size=${_formatBytes(receivedBytes)} | '
      'elapsed=${_formatElapsed(receiveElapsed)}'
      '${_rateSuffix(receivedBytes, receiveElapsed)}',
    );

    final storedFile = storage.fileFor(storageId);
    final sizeBytes = await storedFile.length();
    WfLog.info(
      session,
      'pmtiles',
      '🧭 Reading PMTiles header/bounds for "$name"',
    );
    final bounds = await PmtilesHeaderBounds.readFromFile(storedFile);

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

    final totalElapsed = DateTime.now().toUtc().difference(startedAt);
    WfLog.success(
      session,
      'pmtiles',
      '📤 Upload complete "$name" | id=${id.uuid} | '
      'size=${_formatBytes(sizeBytes)} | '
      'elapsed=${_formatElapsed(totalElapsed)}',
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
      'pmtiles',
      '📤 Upload failed "$name" after '
      '${_formatElapsed(DateTime.now().toUtc().difference(startedAt))} | '
      'received=${_formatBytes(receivedBytes)}',
      error: error,
      stackTrace: stackTrace,
    );
    await storage.delete(storageId);
    return Response.internalServerError(
      body: Body.fromString(
        jsonEncode({'error': 'Upload failed'}),
        mimeType: MimeType.json,
      ),
    );
  }
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
