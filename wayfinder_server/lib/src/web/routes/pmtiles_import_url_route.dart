import 'package:serverpod/serverpod.dart';

import '../../pmtiles/pmtiles_url_import.dart';

/// Imports a remote `.pmtiles` URL into server storage.
class PmtilesImportUrlRoute extends Route {
  PmtilesImportUrlRoute() : super(methods: {Method.post, Method.options});

  @override
  Future<Result> handleCall(Session session, Request request) async {
    return PmtilesUrlImport.import(session, request);
  }
}
