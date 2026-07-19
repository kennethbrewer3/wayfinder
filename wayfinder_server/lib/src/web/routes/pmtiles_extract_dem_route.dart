import 'package:serverpod/serverpod.dart';

import '../../pmtiles/pmtiles_dem_extract.dart';

/// Extracts a regional DEM from an allowlisted remote PMTiles source.
class PmtilesExtractDemRoute extends Route {
  PmtilesExtractDemRoute() : super(methods: {Method.post, Method.options});

  @override
  Future<Result> handleCall(Session session, Request request) async {
    return PmtilesDemExtract.extract(session, request);
  }
}
