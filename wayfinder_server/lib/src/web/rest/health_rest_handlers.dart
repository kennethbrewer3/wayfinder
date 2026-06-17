import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../../pmtiles/pmtiles_storage.dart';
import 'rest_json.dart';

abstract final class HealthRestHandlers {
  static Future<Result> check(Request request) async {
    final session = await request.session;
    final checks = <String, dynamic>{};
    var healthy = true;

    try {
      await MapLayer.db.find(session, limit: 1);
      checks['database'] = {'ok': true};
    } catch (error) {
      healthy = false;
      checks['database'] = {
        'ok': false,
        'error': error.toString(),
      };
    }

    try {
      final storage = PmtilesStorage();
      await storage.ensureReady();
      checks['pmtilesStorage'] = {
        'ok': true,
        'path': storage.root.path,
      };
    } catch (error) {
      healthy = false;
      checks['pmtilesStorage'] = {
        'ok': false,
        'error': error.toString(),
      };
    }

    if (healthy) {
      return RestJson.ok(true);
    }

    return RestJson.serviceUnavailable({
      'healthy': false,
      'checks': checks,
    });
  }
}
