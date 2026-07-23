import 'package:serverpod/serverpod.dart';

import '../../access/wayfinder_permissions.dart';
import '../../pmtiles/pmtiles_chunked_upload.dart';
import '../rest/rest_manage_auth.dart';

class PmtilesChunkedUploadInitRoute extends Route {
  PmtilesChunkedUploadInitRoute()
    : super(methods: {Method.post, Method.options});

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
    return PmtilesChunkedUpload.init(session, request);
  }
}

class PmtilesChunkedUploadChunkRoute extends Route {
  PmtilesChunkedUploadChunkRoute()
    : super(methods: {Method.post, Method.options});

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
    return PmtilesChunkedUpload.chunk(session, request);
  }
}

class PmtilesChunkedUploadCompleteRoute extends Route {
  PmtilesChunkedUploadCompleteRoute()
    : super(methods: {Method.post, Method.options});

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
    return PmtilesChunkedUpload.complete(session, request);
  }
}
