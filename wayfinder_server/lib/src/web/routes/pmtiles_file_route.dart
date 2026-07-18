import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../../pmtiles/pmtiles_storage.dart';

/// Serves a catalog [PmtilesFile] by database id, resolving either uploaded
/// `{uuid}` blobs or pre-existing `{name}.pmtiles` files on disk.
///
/// Pass `?download=1` to force a browser download with the catalog filename
/// (map tile clients omit this so responses stay cacheable inline bytes).
class PmtilesFileRoute extends Route {
  PmtilesFileRoute() : super(methods: {Method.get, Method.head}, path: '/**');

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
    final result = await handler(request);
    if (result is! Response || !_wantsDownload(request)) {
      return result;
    }

    final downloadName = _downloadFileName(entry.name);
    return result.copyWith(
      headers: result.headers.transform((headers) {
        headers.contentDisposition = ContentDispositionHeader.parse(
          'attachment; filename="$downloadName"',
        );
      }),
    );
  }

  bool _wantsDownload(Request request) {
    final raw = request.queryParameters.raw['download']?.trim().toLowerCase();
    return raw == '1' || raw == 'true' || raw == 'yes';
  }

  String _downloadFileName(String catalogName) {
    var name = catalogName.replaceAll('\\', '/').split('/').last.trim();
    if (name.isEmpty) {
      name = 'archive.pmtiles';
    }
    if (!name.toLowerCase().endsWith('.pmtiles')) {
      name = '$name.pmtiles';
    }
    return name.replaceAll(RegExp(r'["\\\r\n]'), '_');
  }

  String? _readIdParam(Request request) {
    final segments = request.url.path.split('/');
    if (segments.isEmpty) {
      return null;
    }
    return segments.last;
  }
}
