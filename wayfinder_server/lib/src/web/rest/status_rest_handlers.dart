import 'package:serverpod/serverpod.dart';

import '../../core/read_only_mode.dart';
import 'rest_json.dart';

/// Lightweight public status for clients (kiosk / read-only detection).
abstract final class StatusRestHandlers {
  static Future<Result> get(Request request) async {
    return RestJson.ok({
      'healthy': true,
      'readOnly': ReadOnlyMode.enabled,
    });
  }
}
