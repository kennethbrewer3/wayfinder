import 'package:serverpod/serverpod.dart';

import '../../core/read_only_mode.dart';
import '../rest/rest_api_auth.dart';
import '../rest/rest_json.dart';

/// Requires a REST API key (or signed-in JWT) when authentication is configured.
class RestAuthMiddleware extends MiddlewareObject {
  const RestAuthMiddleware();

  static const _mutatingMethods = {
    Method.post,
    Method.put,
    Method.patch,
    Method.delete,
  };

  @override
  Handler call(Handler next) {
    return (Request request) async {
      if (RestApiAuth.isPublicRequest(request)) {
        return next(request);
      }

      if (ReadOnlyMode.enabled && _mutatingMethods.contains(request.method)) {
        return RestJson.error(
          403,
          'Server is in read-only / kiosk mode. '
          'Unset WAYFINDER_READ_ONLY to allow writes.',
        );
      }

      final session = await request.session;
      if (!await RestApiAuth.authorize(request, session)) {
        return RestJson.error(
          401,
          'REST API authentication required. Send the configured API key in '
          'the X-API-Key header or as Authorization: Bearer <key>.',
        );
      }

      return next(request);
    };
  }
}
