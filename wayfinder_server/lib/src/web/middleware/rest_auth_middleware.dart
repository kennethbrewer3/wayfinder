import 'package:serverpod/serverpod.dart';

import '../../access/access_control.dart';
import '../../access/wayfinder_permissions.dart';
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
          'REST API authentication required. Send an API key in '
          'the X-API-Key header, or Authorization: Bearer <JWT>.',
        );
      }

      if (RestApiAuth.usedJwt(request) && !RestApiAuth.usedApiKey(request)) {
        final path = request.url.path;
        final permission = _permissionForPath(path);
        final isBackupPath =
            path.contains('/map-data') || path.contains('/field-pack');
        // Backup export is a GET but still requires manage_backups.
        if (_mutatingMethods.contains(request.method) || isBackupPath) {
          try {
            await AccessControl.assertPermission(session, permission);
          } on AccessDeniedException catch (error) {
            return RestJson.error(403, error.message);
          }
        }
      }

      return next(request);
    };
  }

  static String _permissionForPath(String path) {
    if (path.contains('/settings')) {
      return WayfinderPermission.manageSettings;
    }
    if (path.contains('/map-data') || path.contains('/field-pack')) {
      return WayfinderPermission.manageBackups;
    }
    if (path.contains('/pmtiles')) {
      return WayfinderPermission.managePmtiles;
    }
    if (path.contains('/marker-icons') ||
        path.contains('/marker-icon-categories')) {
      return WayfinderPermission.manageMarkerIcons;
    }
    if (path.contains('/layers') || path.contains('/seasonal-overlays')) {
      return WayfinderPermission.manageLayers;
    }
    return WayfinderPermission.editMapObjects;
  }
}
