import 'package:serverpod/serverpod.dart';

import '../../access/access_control.dart';
import '../../settings/rest_api_key_service.dart';

/// REST API credential extracted from [Request] headers.
abstract final class RestApiAuth {
  static const apiKeyHeader = 'X-API-Key';
  static final _apiKeyAuthenticated = Expando<bool>();
  static final _jwtAuthenticated = Expando<bool>();

  static bool isPublicRequest(Request request) {
    if (request.method == Method.options) {
      return true;
    }

    final path = _normalizedPath(request);
    return path == '/api' ||
        path == '/api/' ||
        path == '/api/health' ||
        path == '/api/status';
  }

  static String? extractCredential(Request request) {
    final apiKeyValues = request.headers[apiKeyHeader];
    if (apiKeyValues != null) {
      for (final value in apiKeyValues) {
        final trimmed = value.trim();
        if (trimmed.isNotEmpty) {
          return trimmed;
        }
      }
    }

    final authorization = request.headers.authorization;
    if (authorization is BearerAuthorizationHeader) {
      return authorization.token.trim();
    }

    return null;
  }

  static bool usedApiKey(Request request) =>
      _apiKeyAuthenticated[request] == true;

  static bool usedJwt(Request request) => _jwtAuthenticated[request] == true;

  static Future<bool> authorize(Request request, Session session) async {
    final membershipAuthRequired = await AccessControl.isAuthRequired(session);
    final apiKeyAuthEnabled = await RestApiKeyService.isAuthEnabled(session);

    if (!membershipAuthRequired && !apiKeyAuthEnabled) {
      return true;
    }

    final credential = extractCredential(request);
    if (credential == null || credential.isEmpty) {
      return false;
    }

    if (credential.startsWith(RestApiKeyService.keyPrefix)) {
      final ok = await RestApiKeyService.matchesConfiguredKey(
        session,
        credential,
      );
      if (ok) {
        _apiKeyAuthenticated[request] = true;
      }
      return ok;
    }

    final authInfo = await session.server.authenticationHandler(
      session,
      credential,
    );
    if (authInfo != null) {
      session.updateAuthenticated(authInfo);
      _jwtAuthenticated[request] = true;
      return true;
    }
    return false;
  }

  static String _normalizedPath(Request request) {
    final path = request.url.path;
    if (path.endsWith('/') && path.length > 1) {
      return path.substring(0, path.length - 1);
    }
    return path;
  }
}
