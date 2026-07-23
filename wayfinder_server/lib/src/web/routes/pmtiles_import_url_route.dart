import 'package:serverpod/serverpod.dart';

import '../../access/wayfinder_permissions.dart';
import '../../pmtiles/pmtiles_url_import.dart';
import '../rest/rest_manage_auth.dart';

/// Imports a remote `.pmtiles` URL into server storage.
class PmtilesImportUrlRoute extends Route {
  PmtilesImportUrlRoute() : super(methods: {Method.post, Method.options});

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
    return PmtilesUrlImport.import(session, request);
  }
}
