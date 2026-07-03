import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../../markers/marker_icon_key.dart';
import '../../markers/marker_icon_storage.dart';

/// Serves `{key}.svg` marker icon files from server storage.
class MarkerIconFileRoute extends Route {
  MarkerIconFileRoute() : super(methods: {Method.get, Method.head}, path: '/**');

  @override
  Future<Result> handleCall(Session session, Request request) async {
    final key = _readKeyParam(request);
    if (key == null || !MarkerIconStorage.isValidKey(key)) {
      return Response.notFound();
    }

    final entry = await MarkerIconCatalogEntry.db.findFirstRow(
      session,
      where: (t) => t.key.equals(key),
    );
    if (entry == null || !entry.hasCustomSvg) {
      return Response.notFound();
    }

    final storage = MarkerIconStorage();
    if (!storage.exists(key)) {
      return Response.notFound();
    }

    final file = storage.fileFor(key);
    final handler = StaticHandler.file(
      file,
      cacheControl: StaticRoute.publicImmutable(),
    ).asHandler;
    return handler(request);
  }

  String? _readKeyParam(Request request) {
    final segments = request.url.path.split('/');
    if (segments.isEmpty) {
      return null;
    }
    final filename = segments.last;
    if (!filename.toLowerCase().endsWith('.svg')) {
      return null;
    }
    final key = filename.substring(0, filename.length - 4);
    return MarkerIconKey.pattern.hasMatch(key) ? key : null;
  }
}
