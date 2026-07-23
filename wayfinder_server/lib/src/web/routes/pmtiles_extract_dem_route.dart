import 'package:serverpod/serverpod.dart';

import '../../access/wayfinder_permissions.dart';
import '../../pmtiles/pmtiles_dem_extract.dart';
import '../rest/rest_manage_auth.dart';

/// Extracts a regional DEM from an allowlisted remote PMTiles source.
class PmtilesExtractDemRoute extends Route {
  PmtilesExtractDemRoute() : super(methods: {Method.post, Method.options});

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
    return PmtilesDemExtract.extract(session, request);
  }
}
