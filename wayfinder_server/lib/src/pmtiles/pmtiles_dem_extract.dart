import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../core/wayfinder_log.dart';
import '../generated/protocol.dart';
import 'pmtiles_header_bounds.dart';
import 'pmtiles_storage.dart';
import 'pmtiles_url_import.dart';

/// Builds a regional Terrarium DEM via `pmtiles extract` from an allowlisted
/// remote archive (default: Mapterhorn planet) and catalogs the result.
abstract final class PmtilesDemExtract {
  static const _tag = 'pmtiles';

  static const defaultSourceUrl =
      'https://download.mapterhorn.com/planet.pmtiles';

  /// Reject extracts larger than a generous US-state / region size.
  static const maxLonSpanDegrees = 70.0;
  static const maxLatSpanDegrees = 40.0;

  static Completer<void>? _busy;

  static Future<Result> extract(Session session, Request request) async {
    if (request.method == Method.options) {
      return Response.ok(headers: Headers.empty());
    }

    if (_busy != null) {
      return Response(
        503,
        body: Body.fromString(
          jsonEncode({
            'error':
                'Another DEM extract is already running. Try again when it finishes.',
          }),
          mimeType: MimeType.json,
        ),
      );
    }

    Map<String, dynamic> body;
    try {
      final raw = await request.readAsString();
      body = jsonDecode(raw) as Map<String, dynamic>;
    } on Object {
      return _badRequest(
        'JSON body with "bbox" [minLon,minLat,maxLon,maxLat] and "name" is required',
      );
    }

    final bbox = _parseBbox(body['bbox']);
    if (bbox == null) {
      return _badRequest(
        'Field "bbox" must be [minLon, minLat, maxLon, maxLat] with a '
        'finite region (lon span ≤ $maxLonSpanDegrees°, '
        'lat span ≤ $maxLatSpanDegrees°)',
      );
    }

    var name = (body['name'] as String?)?.trim() ?? '';
    if (name.isEmpty) {
      return _badRequest('Field "name" is required');
    }
    name = name.replaceAll('\\', '/').split('/').last;
    if (!name.toLowerCase().endsWith('.pmtiles')) {
      name = '$name.pmtiles';
    }
    if (!_isSafeFileName(name)) {
      return _badRequest('Invalid archive name');
    }
    // Ensure Wayfinder DEM detection recognizes the archive.
    final lower = name.toLowerCase();
    if (!lower.contains('terrarium') &&
        !lower.contains('dem') &&
        !lower.contains('elevation') &&
        !lower.contains('terrain-rgb')) {
      name = name.replaceFirst(RegExp(r'\.pmtiles$', caseSensitive: false), '');
      name = '$name-terrarium.pmtiles';
    }

    var sourceUrlRaw = (body['sourceUrl'] as String?)?.trim();
    if (sourceUrlRaw == null || sourceUrlRaw.isEmpty) {
      sourceUrlRaw = defaultSourceUrl;
    }
    final sourceUri = Uri.tryParse(sourceUrlRaw);
    if (sourceUri == null ||
        (sourceUri.scheme != 'https' && sourceUri.scheme != 'http') ||
        sourceUri.host.isEmpty) {
      return _badRequest('Field "sourceUrl" must be an absolute http(s) URL');
    }
    if (!PmtilesUrlImport.allowedHosts.contains(sourceUri.host.toLowerCase())) {
      return _badRequest(
        'sourceUrl host is not allowed. Allowed: '
        '${PmtilesUrlImport.allowedHosts.join(', ')}',
      );
    }

    final cli = await resolvePmtilesCli();
    if (cli == null) {
      return Response.internalServerError(
        body: Body.fromString(
          jsonEncode({
            'error':
                'pmtiles CLI not found on the server. Install go-pmtiles or set '
                'WAYFINDER_PMTILES_CLI to the binary path.',
          }),
          mimeType: MimeType.json,
        ),
      );
    }

    final storage = PmtilesStorage();
    final existing = await PmtilesFile.db.findFirstRow(
      session,
      where: (t) => t.name.equals(name),
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
    final bboxFlag =
        '${bbox.minLon},${bbox.minLat},${bbox.maxLon},${bbox.maxLat}';

    _busy = Completer<void>();
    WfLog.info(
      session,
      _tag,
      '⛰️ DEM extract started "$name" | id=$storageId | bbox=$bboxFlag | '
      'source=$sourceUri | cli=$cli',
    );

    final heartbeat = Timer.periodic(const Duration(seconds: 15), (_) {
      final elapsed = DateTime.now().toUtc().difference(startedAt);
      WfLog.info(
        session,
        _tag,
        '⛰️ DEM extract still running "$name" | '
        'elapsed=${_formatElapsed(elapsed)}',
      );
    });

    try {
      await storage.ensureReady();
      final outFile = storage.fileForId(storageId);
      // Extract to a .pmtiles temp path (CLI expects a file name), then rename.
      final tempOut = File('${outFile.path}.pmtiles');
      if (tempOut.existsSync()) {
        await tempOut.delete();
      }

      final args = <String>[
        'extract',
        '--bbox=$bboxFlag',
        sourceUri.toString(),
        tempOut.path,
      ];
      final process = await Process.start(cli, args, runInShell: false);
      final stderrBuf = StringBuffer();
      final stdoutBuf = StringBuffer();
      process.stdout
          .transform(utf8.decoder)
          .listen((chunk) => stdoutBuf.write(chunk));
      process.stderr.transform(utf8.decoder).listen((chunk) {
        stderrBuf.write(chunk);
        final line = chunk.trim();
        if (line.isNotEmpty) {
          WfLog.info(session, _tag, '⛰️ pmtiles: $line');
        }
      });

      final exitCode = await process.exitCode;
      heartbeat.cancel();

      if (exitCode != 0) {
        final detail = stderrBuf.toString().trim();
        throw ProcessException(
          cli,
          args,
          detail.isEmpty
              ? 'pmtiles extract exited with code $exitCode'
              : detail,
          exitCode,
        );
      }

      if (!tempOut.existsSync() || await tempOut.length() < 127) {
        throw FormatException(
          'Extract produced an empty or invalid PMTiles file',
        );
      }
      if (outFile.existsSync()) {
        await outFile.delete();
      }
      await tempOut.rename(outFile.path);

      final bounds = await PmtilesHeaderBounds.readFromFile(outFile);
      final sizeBytes = await outFile.length();
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
        '⛰️ DEM extract complete "$name" | id=${id.uuid} | '
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
        '⛰️ DEM extract failed "$name" | bbox=$bboxFlag',
        error: error,
        stackTrace: stackTrace,
      );
      await storage.delete(storageId);
      try {
        final orphan = File('${storage.fileForId(storageId).path}.pmtiles');
        if (orphan.existsSync()) {
          await orphan.delete();
        }
      } on Object {
        // Best-effort cleanup.
      }
      return Response.internalServerError(
        body: Body.fromString(
          jsonEncode({'error': 'DEM extract failed: $error'}),
          mimeType: MimeType.json,
        ),
      );
    } finally {
      final gate = _busy;
      _busy = null;
      gate?.complete();
    }
  }

  /// Resolves the go-pmtiles binary path.
  static Future<String?> resolvePmtilesCli() async {
    final fromEnv = Platform.environment['WAYFINDER_PMTILES_CLI']?.trim();
    if (fromEnv != null && fromEnv.isNotEmpty && File(fromEnv).existsSync()) {
      return fromEnv;
    }
    for (final candidate in const [
      '/usr/local/bin/pmtiles',
      '/usr/bin/pmtiles',
    ]) {
      if (File(candidate).existsSync()) {
        return candidate;
      }
    }
    try {
      final which = await Process.run('which', ['pmtiles']);
      if (which.exitCode == 0) {
        final path = (which.stdout as String).trim().split('\n').first.trim();
        if (path.isNotEmpty && File(path).existsSync()) {
          return path;
        }
      }
    } on Object {
      // Ignore — binary not on PATH.
    }
    return null;
  }

  static _Bbox? _parseBbox(Object? raw) {
    if (raw is! List || raw.length != 4) {
      return null;
    }
    final nums = <double>[];
    for (final item in raw) {
      if (item is! num) {
        return null;
      }
      nums.add(item.toDouble());
    }
    final minLon = nums[0];
    final minLat = nums[1];
    final maxLon = nums[2];
    final maxLat = nums[3];
    if (![minLon, minLat, maxLon, maxLat].every((v) => v.isFinite)) {
      return null;
    }
    if (minLon >= maxLon || minLat >= maxLat) {
      return null;
    }
    if (minLon < -180 || maxLon > 180 || minLat < -90 || maxLat > 90) {
      return null;
    }
    final lonSpan = maxLon - minLon;
    final latSpan = maxLat - minLat;
    if (lonSpan > maxLonSpanDegrees || latSpan > maxLatSpanDegrees) {
      return null;
    }
    return _Bbox(
      minLon: minLon,
      minLat: minLat,
      maxLon: maxLon,
      maxLat: maxLat,
    );
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

class _Bbox {
  const _Bbox({
    required this.minLon,
    required this.minLat,
    required this.maxLon,
    required this.maxLat,
  });

  final double minLon;
  final double minLat;
  final double maxLon;
  final double maxLat;
}
