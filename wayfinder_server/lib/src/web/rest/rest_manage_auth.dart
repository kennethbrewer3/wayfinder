import 'package:serverpod/serverpod.dart';

import '../../access/access_control.dart';
import '../../settings/rest_api_key_service.dart';
import 'rest_api_auth.dart';
import 'rest_json.dart';

/// Auth + role checks for legacy `/pmtiles/*` and similar non-`/api` write routes.
abstract final class RestManageAuth {
  /// Returns an error response when the caller may not use [permission],
  /// otherwise `null` (caller should proceed).
  static Future<Result?> denyUnlessPermission(
    Session session,
    Request request,
    String permission,
  ) async {
    if (request.method == Method.options) {
      return null;
    }

    final membershipAuthRequired = await AccessControl.isAuthRequired(session);
    final apiKeyAuthEnabled = await RestApiKeyService.isAuthEnabled(session);
    if (!membershipAuthRequired && !apiKeyAuthEnabled) {
      return null;
    }

    final credential = RestApiAuth.extractCredential(request);
    if (credential != null && credential.isNotEmpty) {
      if (!await RestApiAuth.authorize(request, session)) {
        return RestJson.error(
          401,
          'REST API authentication required. Send an API key in '
          'the X-API-Key header, or Authorization: Bearer <JWT>.',
        );
      }
      if (RestApiAuth.usedApiKey(request)) {
        return null;
      }
      try {
        await AccessControl.assertPermission(session, permission);
        return null;
      } on AccessDeniedException catch (error) {
        return RestJson.error(403, error.message);
      }
    }

    if (session.authenticated != null) {
      try {
        await AccessControl.assertPermission(session, permission);
        return null;
      } on AccessDeniedException catch (error) {
        return RestJson.error(403, error.message);
      }
    }

    return RestJson.error(
      401,
      'REST API authentication required. Send an API key in '
      'the X-API-Key header, or Authorization: Bearer <JWT>.',
    );
  }
}
