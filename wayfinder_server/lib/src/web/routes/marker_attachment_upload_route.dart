import 'package:serverpod/serverpod.dart';

import '../../markers/marker_attachment_upload_handler.dart';

/// Streams a raw image upload for a marker (`?markerId=&fileName=`).
class MarkerAttachmentUploadRoute extends Route {
  MarkerAttachmentUploadRoute() : super(methods: {Method.post, Method.options});

  @override
  Future<Result> handleCall(Session session, Request request) {
    return handleMarkerAttachmentUpload(session, request);
  }
}
