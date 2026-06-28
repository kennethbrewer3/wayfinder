import 'package:serverpod/serverpod.dart';

import '../../settings/rest_api_key_service.dart';

/// REST API credential extracted from [Request] headers.
abstract final class RestApiAuth {
  static const apiKeyHeader = 'X-API-Key';

  static bool isPublicRequest(Request request) {
    if (request.method == Method.options) {
      return true;
    }

    final path = _normalizedPath(request);
    return path == '/api' || path == '/api/' || path == '/api/health';
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

  static Future<bool> authorize(Request request, Session session) async {
    if (!await RestApiKeyService.isAuthEnabled(session)) {
      return true;
    }

    final credential = extractCredential(request);
    if (credential == null || credential.isEmpty) {
      return false;
    }

    if (credential.startsWith(RestApiKeyService.keyPrefix)) {
      final storedHash = await RestApiKeyService.storedKeyHash(session);
      return RestApiKeyService.matchesConfiguredKey(credential, storedHash);
    }

    final authInfo = await session.server.authenticationHandler(
      session,
      credential,
    );
    return authInfo != null;
  }

  static String _normalizedPath(Request request) {
    final path = request.url.path;
    if (path.endsWith('/') && path.length > 1) {
      return path.substring(0, path.length - 1);
    }
    return path;
  }
}
