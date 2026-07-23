import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../access/wayfinder_permissions.dart';
import '../core/endpoint_logging.dart';
import '../generated/protocol.dart';
import 'app_theme_definition_store.dart';

class AppThemeEndpoint extends Endpoint with EndpointLogging {
  static const _tag = 'appTheme';

  /// Any signed-in user (or open mode) may list themes to select them.
  Future<List<AppThemeDefinition>> listThemes(Session session) {
    return loggedCall(
      session,
      _tag,
      'listThemes',
      () => AppThemeDefinitionStore.list(session),
      onSuccess: (themes) => 'count=${themes.length}',
    );
  }

  Future<AppThemeDefinition?> getTheme(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'getTheme',
      () => AppThemeDefinitionStore.get(session, id),
      onSuccess: (theme) => theme == null ? 'not found id=$id' : 'found id=$id',
    );
  }

  Future<AppThemeDefinition> createTheme(
    Session session,
    String name,
    String brightness,
    String seedColor,
    String overridesJson,
  ) {
    return loggedCall(
      session,
      _tag,
      'createTheme',
      () => AppThemeDefinitionStore.create(
        session,
        name: name,
        brightness: brightness,
        seedColor: seedColor,
        overridesJson: overridesJson,
      ),
      onSuccess: (theme) => 'id=${theme.id} name="${theme.name}"',
      requiredPermission: WayfinderPermission.manageThemes,
    );
  }

  Future<AppThemeDefinition> updateTheme(
    Session session,
    UuidValue id,
    String name,
    String brightness,
    String seedColor,
    String overridesJson,
  ) {
    return loggedCall(
      session,
      _tag,
      'updateTheme',
      () => AppThemeDefinitionStore.update(
        session,
        id: id,
        name: name,
        brightness: brightness,
        seedColor: seedColor,
        overridesJson: overridesJson,
      ),
      onSuccess: (theme) => 'id=${theme.id} name="${theme.name}"',
      requiredPermission: WayfinderPermission.manageThemes,
    );
  }

  Future<bool> deleteTheme(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'deleteTheme',
      () => AppThemeDefinitionStore.delete(session, id),
      onSuccess: (deleted) => deleted ? 'deleted id=$id' : 'not found id=$id',
      requiredPermission: WayfinderPermission.manageThemes,
    );
  }

  /// Imports a theme from the export JSON payload (map or JSON string).
  Future<AppThemeDefinition> importTheme(
    Session session,
    String exportJson,
  ) {
    return loggedCall(
      session,
      _tag,
      'importTheme',
      () {
        late final Object? decoded;
        try {
          decoded = jsonDecode(exportJson);
        } catch (_) {
          throw const FormatException('Theme import JSON is invalid');
        }
        if (decoded is! Map) {
          throw const FormatException('Theme import JSON must be an object');
        }
        return AppThemeDefinitionStore.importDefinition(
          session,
          Map<String, dynamic>.from(decoded),
        );
      },
      onSuccess: (theme) => 'imported id=${theme.id} name="${theme.name}"',
      requiredPermission: WayfinderPermission.manageThemes,
    );
  }

  Future<String> exportTheme(Session session, UuidValue id) {
    return loggedCall(
      session,
      _tag,
      'exportTheme',
      () async {
        final theme = await AppThemeDefinitionStore.get(session, id);
        if (theme == null) {
          throw ArgumentError.value(id, 'id', 'Theme not found');
        }
        return jsonEncode(AppThemeDefinitionStore.toExportJson(theme));
      },
      onSuccess: (_) => 'exported id=$id',
      requiredPermission: WayfinderPermission.manageThemes,
    );
  }
}
