import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../../pmtiles/pmtiles_storage.dart';

/// Serves a catalog [PmtilesFile] by database id, resolving either uploaded
/// `{uuid}` blobs or pre-existing `{name}.pmtiles` files on disk.
class PmtilesFileRoute extends Route {
  PmtilesFileRoute()
      : super(methods: {Method.get, Method.head}, path: '/**');

  @override
  Future<Result> handleCall(Session session, Request request) async {
    final idParam = _readIdParam(request);
    if (idParam == null || idParam.isEmpty) {
      return Response.notFound();
    }

    UuidValue id;
    try {
      id = UuidValue.fromString(idParam);
    } on Object {
      return Response.notFound();
    }

    final entry = await PmtilesFile.db.findById(session, id);
    if (entry == null) {
      return Response.notFound();
    }

    final storage = PmtilesStorage();
    if (!storage.existsForEntry(id: id.uuid, name: entry.name)) {
      return Response.notFound();
    }

    final file = storage.resolveFileForEntry(id: id.uuid, name: entry.name);
    final handler = StaticHandler.file(
      file,
      cacheControl: StaticRoute.publicImmutable(),
    ).asHandler;
    return handler(request);
  }

  String? _readIdParam(Request request) {
    final segments = request.url.path.split('/');
    if (segments.isEmpty) {
      return null;
    }
    return segments.last;
  }
}
