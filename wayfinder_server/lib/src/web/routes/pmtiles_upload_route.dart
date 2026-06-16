import 'package:serverpod/serverpod.dart';

import '../../pmtiles/pmtiles_upload_handler.dart';

/// Streams a raw PMTiles upload into server storage and registers metadata.
class PmtilesUploadRoute extends Route {
  PmtilesUploadRoute() : super(methods: {Method.post, Method.options});

  @override
  Future<Result> handleCall(Session session, Request request) async {
    return handlePmtilesUpload(session, request);
  }
}
