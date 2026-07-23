import 'package:serverpod/serverpod.dart';

import '../../access/wayfinder_permissions.dart';
import '../../pmtiles/pmtiles_upload_handler.dart';
import '../rest/rest_manage_auth.dart';

/// Streams a raw PMTiles upload into server storage and registers metadata.
class PmtilesUploadRoute extends Route {
  PmtilesUploadRoute() : super(methods: {Method.post, Method.options});

  @override
  Future<Result> handleCall(Session session, Request request) async {
    final denied = await RestManageAuth.denyUnlessPermission(
      session,
      request,
      WayfinderPermission.managePmtiles,
    );
    if (denied != null) {
      return denied;
    }
    return handlePmtilesUpload(session, request);
  }
}
