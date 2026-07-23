import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../../markers/marker_attachment_storage.dart';

/// Serves marker attachment bytes by storage id.
class MarkerAttachmentFileRoute extends Route {
  MarkerAttachmentFileRoute()
    : super(methods: {Method.get, Method.head}, path: '/**');

  @override
  Future<Result> handleCall(Session session, Request request) async {
    final storageId = _readStorageId(request);
    if (storageId == null ||
        !MarkerAttachmentStorage.isValidStorageId(storageId)) {
      return Response.notFound();
    }

    final entry = await MarkerAttachment.db.findFirstRow(
      session,
      where: (t) => t.storageId.equals(storageId),
    );
    if (entry == null) {
      return Response.notFound();
    }

    final storage = MarkerAttachmentStorage();
    if (!storage.exists(storageId)) {
      return Response.notFound();
    }

    final file = storage.fileFor(storageId);
    final handler = StaticHandler.file(
      file,
      cacheControl: StaticRoute.publicImmutable(),
    ).asHandler;
    final result = await handler(request);
    if (result is! Response) {
      return result;
    }

    return result.copyWith(
      headers: result.headers.transform((headers) {
        headers[Headers.contentTypeHeader] = [entry.contentType];
        headers.contentDisposition = ContentDispositionHeader.parse(
          'inline; filename="${_safeFileName(entry.fileName)}"',
        );
      }),
    );
  }

  String? _readStorageId(Request request) {
    final segments = request.url.path.split('/');
    if (segments.isEmpty) {
      return null;
    }
    return segments.last.trim();
  }

  String _safeFileName(String raw) {
    return raw.replaceAll(RegExp(r'["\\\r\n]'), '_');
  }
}
