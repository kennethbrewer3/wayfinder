import 'dart:convert';

import 'package:serverpod/serverpod.dart';

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

    try {
      await storage.writeStream(storageId, request.read());
      final storedFile = storage.fileFor(storageId);
      final sizeBytes = await storedFile.length();
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

    final json = Map<String, dynamic>.from(entry.toJson());
    json.remove('__className__');

    return Response.ok(
      body: Body.fromString(jsonEncode(json), mimeType: MimeType.json),
    );
  } catch (error, stackTrace) {
    session.log(
      'PMTiles upload failed for "$name": $error',
      stackTrace: stackTrace,
      level: LogLevel.error,
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
