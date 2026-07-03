import 'package:serverpod/serverpod.dart';

import '../../markers/marker_icon_key.dart';
import '../../markers/marker_icon_upload_handler.dart';

/// Streams a raw SVG upload for a marker icon key (`?key=<icon_key>`).
class MarkerIconUploadRoute extends Route {
  MarkerIconUploadRoute() : super(methods: {Method.post, Method.options});

  @override
  Future<Result> handleCall(Session session, Request request) async {
    if (request.method == Method.options) {
      return Response.ok(headers: Headers.empty());
    }

    final rawKey = request.queryParameters.raw['key']?.trim();
    if (rawKey == null || rawKey.isEmpty) {
      return Response.badRequest(
        body: Body.fromString(
          '{"error":"Query parameter \\"key\\" is required"}',
          mimeType: MimeType.json,
        ),
      );
    }

    try {
      final key = MarkerIconKey.normalize(rawKey);
      return handleMarkerIconSvgUpload(session, request, key);
    } on FormatException catch (error) {
      return Response.badRequest(
        body: Body.fromString(
          '{"error":"${error.message}"}',
          mimeType: MimeType.json,
        ),
      );
    }
  }
}
