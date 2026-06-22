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
      final ready = await storage.ensureReady();
      final discovered = storage.discoverNamedArchives().length;
      final catalog = await PmtilesFile.db.count(session);
      checks['pmtilesStorage'] = {
        'ok': ready,
        'path': storage.root.path,
        'discoveredFiles': discovered,
        'catalogEntries': catalog,
      };
      if (!ready) {
        healthy = false;
      }
    } catch (error) {
      healthy = false;
      checks['pmtilesStorage'] = {
        'ok': false,
        'error': error.toString(),
      };
    }

    final includeDetails =
        request.url.queryParameters['details'] == '1' ||
        request.url.queryParameters['verbose'] == '1';

    if (healthy && !includeDetails) {
      return RestJson.ok(true);
    }

    if (healthy) {
      return RestJson.ok({
        'healthy': true,
        'checks': checks,
      });
    }

    return RestJson.serviceUnavailable({
      'healthy': false,
      'checks': checks,
    });
  }
}
