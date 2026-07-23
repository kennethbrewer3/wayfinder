/// Coarse permissions granted to TOC roles.
abstract final class WayfinderPermission {
  static const viewMap = 'view_map';
  static const editMapObjects = 'edit_map_objects';
  static const manageLayers = 'manage_layers';
  static const manageSettings = 'manage_settings';
  static const manageUsers = 'manage_users';
  static const manageRoles = 'manage_roles';
  static const manageBackups = 'manage_backups';
  static const managePmtiles = 'manage_pmtiles';
  static const manageApiKeys = 'manage_api_keys';

  static const all = <String>{
    viewMap,
    editMapObjects,
    manageLayers,
    manageSettings,
    manageUsers,
    manageRoles,
    manageBackups,
    managePmtiles,
    manageApiKeys,
  };

  static const editorDefaults = <String>{
    viewMap,
    editMapObjects,
    manageLayers,
    manageBackups,
  };

  static const viewerDefaults = <String>{viewMap};

  static bool isKnown(String permission) => all.contains(permission);

  /// Maps endpoint tag + write/read to a required permission.
  static String? forEndpoint({
    required String tag,
    required bool isWrite,
  }) {
    if (!isWrite) {
      return viewMap;
    }

    return switch (tag) {
      'accessControl' => manageUsers,
      'appSettings' => manageSettings,
      'mapData' || 'fieldPack' => manageBackups,
      'pmtiles' || 'markerIcon' => managePmtiles,
      'mapLayer' || 'seasonalOverlay' => manageLayers,
      'mapMarker' ||
      'mapZone' ||
      'watchLog' ||
      'category' ||
      'markerAttachment' => editMapObjects,
      _ => editMapObjects,
    };
  }
}

abstract final class BuiltInAccessRole {
  static const admin = 'admin';
  static const editor = 'editor';
  static const viewer = 'viewer';

  static const all = <String>{admin, editor, viewer};
}
