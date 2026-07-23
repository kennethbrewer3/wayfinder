import 'package:serverpod/serverpod.dart';

import '../../access/access_control.dart';
import '../../core/read_only_mode.dart';
import 'rest_json.dart';

/// Lightweight public status for clients (kiosk / read-only detection).
abstract final class StatusRestHandlers {
  static Future<Result> get(Request request) async {
    final session = await request.session;
    final authRequired = await AccessControl.isAuthRequired(session);
    return RestJson.ok({
      'healthy': true,
      'readOnly': ReadOnlyMode.enabled,
      'authRequired': authRequired,
    });
  }
}
