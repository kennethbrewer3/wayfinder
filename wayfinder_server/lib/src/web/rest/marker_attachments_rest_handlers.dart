import 'package:serverpod/serverpod.dart';

import '../../markers/marker_attachment_service.dart';
import 'rest_json.dart';

abstract final class MarkerAttachmentsRestHandlers {
  static final _idParam = PathParam<String>(#id, (value) => value);

  static Future<Result> listForMarker(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final markerId = RestJson.parseUuid(
        request.pathParameters.get(_idParam),
        label: 'id',
      );
      final entries = await MarkerAttachmentService.listForMarker(
        session,
        markerId,
      );
      return RestJson.ok(RestJson.encodeModels(entries));
    });
  }

  static Future<Result> delete(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final id = RestJson.parseUuid(
        request.pathParameters.get(_idParam),
        label: 'id',
      );
      final deleted = await MarkerAttachmentService.deleteAttachment(
        session,
        id,
      );
      if (!deleted) {
        return RestJson.error(404, 'Attachment not found');
      }
      return RestJson.noContent();
    });
  }
}
