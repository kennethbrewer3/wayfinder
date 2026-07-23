import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';

import '../core/read_only_mode.dart';
import '../web/rest/rest_json.dart';
import 'marker_attachment_service.dart';

/// Handles a raw image upload for a marker attachment.
Future<Result> handleMarkerAttachmentUpload(
  Session session,
  Request request,
) async {
  if (request.method == Method.options) {
    return Response.ok(headers: Headers.empty());
  }

  if (ReadOnlyMode.enabled) {
    return RestJson.error(
      403,
      'Server is in read-only / kiosk mode. '
      'Unset WAYFINDER_READ_ONLY to allow writes.',
    );
  }

  final markerIdRaw = request.queryParameters.raw['markerId']?.trim();
  if (markerIdRaw == null || markerIdRaw.isEmpty) {
    return RestJson.error(400, 'Query parameter "markerId" is required');
  }

  UuidValue markerId;
  try {
    markerId = UuidValue.fromString(markerIdRaw);
  } on FormatException {
    return RestJson.error(400, 'Invalid markerId UUID');
  }

  final fileName = request.queryParameters.raw['fileName']?.trim();
  final headerValues = request.headers[Headers.contentTypeHeader];
  final headerType = headerValues == null || headerValues.isEmpty
      ? null
      : headerValues.first;
  final contentType =
      request.queryParameters.raw['contentType']?.trim() ??
      headerType?.trim() ??
      '';

  final bytes = await request.read().fold<List<int>>(
    <int>[],
    (previous, chunk) => previous..addAll(chunk),
  );

  try {
    final entry = await MarkerAttachmentService.createFromBytes(
      session,
      markerId: markerId,
      fileName: fileName ?? '',
      contentType: contentType,
      bytes: Uint8List.fromList(bytes),
    );
    final json = Map<String, dynamic>.from(entry.toJson())
      ..remove('__className__');
    return Response.ok(
      body: Body.fromString(jsonEncode(json), mimeType: MimeType.json),
    );
  } on FormatException catch (error) {
    return RestJson.error(400, error.message);
  } on StateError catch (error) {
    return RestJson.error(400, error.message);
  }
}
