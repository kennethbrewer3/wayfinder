import 'package:serverpod/serverpod.dart';

import '../../pmtiles/pmtiles_chunked_upload.dart';

class PmtilesChunkedUploadInitRoute extends Route {
  PmtilesChunkedUploadInitRoute()
    : super(methods: {Method.post, Method.options});

  @override
  Future<Result> handleCall(Session session, Request request) {
    return PmtilesChunkedUpload.init(session, request);
  }
}

class PmtilesChunkedUploadChunkRoute extends Route {
  PmtilesChunkedUploadChunkRoute()
    : super(methods: {Method.post, Method.options});

  @override
  Future<Result> handleCall(Session session, Request request) {
    return PmtilesChunkedUpload.chunk(session, request);
  }
}

class PmtilesChunkedUploadCompleteRoute extends Route {
  PmtilesChunkedUploadCompleteRoute()
    : super(methods: {Method.post, Method.options});

  @override
  Future<Result> handleCall(Session session, Request request) {
    return PmtilesChunkedUpload.complete(session, request);
  }
}
