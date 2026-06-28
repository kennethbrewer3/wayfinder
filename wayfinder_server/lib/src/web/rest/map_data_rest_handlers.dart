import 'package:serverpod/serverpod.dart';

import '../../map/map_data_service.dart';
import '../../map/map_marker_change_broadcast.dart';
import 'rest_json.dart';

abstract final class MapDataRestHandlers {
  static Future<Result> export(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final payload = await exportMapDataBundle(session);
      return RestJson.ok(payload);
    });
  }

  static Future<Result> restore(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final body = await RestJson.readObject(request);
      final summary = await restoreMapDataBundle(session, body);
      await MapMarkerChangeBroadcast.bulk(session);
      return RestJson.ok({
        'restored': summary.toJson(),
      });
    });
  }
}
