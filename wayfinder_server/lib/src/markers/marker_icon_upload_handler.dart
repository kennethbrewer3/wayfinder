import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'marker_icon_key.dart';
import 'marker_icon_storage.dart';

const _maxSvgBytes = 5 * 1024 * 1024;

/// Handles a raw SVG upload for a marker icon key.
Future<Result> handleMarkerIconSvgUpload(
  Session session,
  Request request,
  String key,
) async {
  if (request.method == Method.options) {
    return Response.ok(headers: Headers.empty());
  }

  try {
    key = MarkerIconKey.normalize(key);
  } on FormatException catch (error) {
    return Response.badRequest(
      body: Body.fromString(
        jsonEncode({'error': error.message}),
        mimeType: MimeType.json,
      ),
    );
  }

  final storage = MarkerIconStorage();
  if (!await storage.ensureReady()) {
    return Response.internalServerError(
      body: Body.fromString(
        jsonEncode({'error': 'Marker icon storage is unavailable'}),
        mimeType: MimeType.json,
      ),
    );
  }

  final bytes = await request.read().fold<List<int>>(
    <int>[],
    (previous, chunk) => previous..addAll(chunk),
  );
  if (bytes.isEmpty) {
    return Response.badRequest(
      body: Body.fromString(
        jsonEncode({'error': 'SVG body is empty'}),
        mimeType: MimeType.json,
      ),
    );
  }
  if (bytes.length > _maxSvgBytes) {
    return Response.badRequest(
      body: Body.fromString(
        jsonEncode({'error': 'SVG exceeds 5 MB limit'}),
        mimeType: MimeType.json,
      ),
    );
  }

  final content = utf8.decode(bytes, allowMalformed: true).trim();
  if (!content.contains('<svg')) {
    return Response.badRequest(
      body: Body.fromString(
        jsonEncode({'error': 'Body does not look like SVG content'}),
        mimeType: MimeType.json,
      ),
    );
  }

  try {
    await storage.writeBytes(key, Uint8List.fromList(bytes));
    final now = DateTime.now().toUtc();
    final existing = await MarkerIconCatalogEntry.db.findFirstRow(
      session,
      where: (t) => t.key.equals(key),
    );

    final entry = existing == null
        ? MarkerIconCatalogEntry(
            key: key,
            label: _labelFromKey(key),
            materialIcon: 'place',
            coloredAsset: false,
            glyphScale: 1.0,
            hasCustomSvg: true,
            sortOrder: await _nextSortOrder(session),
            createdAt: now,
            updatedAt: now,
          )
        : existing.copyWith(hasCustomSvg: true, updatedAt: now);

    final saved = existing == null
        ? await MarkerIconCatalogEntry.db.insertRow(session, entry)
        : await MarkerIconCatalogEntry.db.updateRow(session, entry);

    final json = Map<String, dynamic>.from(saved.toJson());
    json.remove('__className__');
    json['svgUrl'] = '/marker-icons/files/$key.svg';

    return Response.ok(
      body: Body.fromString(jsonEncode(json), mimeType: MimeType.json),
    );
  } catch (error, stackTrace) {
    session.log(
      'Marker icon SVG upload failed for "$key": $error',
      stackTrace: stackTrace,
      level: LogLevel.error,
    );
    await storage.delete(key);
    return Response.internalServerError(
      body: Body.fromString(
        jsonEncode({'error': 'Upload failed'}),
        mimeType: MimeType.json,
      ),
    );
  }
}

Future<int> _nextSortOrder(Session session) async {
  final rows = await MarkerIconCatalogEntry.db.find(
    session,
    orderBy: (t) => t.sortOrder,
    orderDescending: true,
    limit: 1,
  );
  if (rows.isEmpty) {
    return 0;
  }
  return rows.first.sortOrder + 1;
}

String _labelFromKey(String key) {
  return key
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
