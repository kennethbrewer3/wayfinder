import 'package:wayfinder_client/wayfinder_client.dart';

/// Deterministic [AccessSessionInfo] values for widget / golden tests.
abstract final class AccessSessionFixtures {
  /// Server requires auth; user not signed in → AuthGate sign-in chrome.
  static AccessSessionInfo signInRequired() {
    return AccessSessionInfo(
      authRequired: true,
      authenticated: false,
      isAdmin: false,
      permissions: const [],
      canEditMap: false,
      canManageUsers: false,
      canManageRoles: false,
      canManageSettings: false,
      canManageBackups: false,
      canManageApiKeys: false,
      canManageLayers: false,
      canManageTides: false,
      canManageGeocoding: false,
      canManageMarkerIcons: false,
      canManageThemes: false,
      canManagePmtiles: false,
      canManageMapHome: false,
      canManageMapZoom: false,
      canViewWatchLog: false,
      canAddWatchLog: false,
    );
  }

  static AccessSessionInfo signedInEditor({
    String email = 'ranger@example.com',
    String roleName = 'Editor',
  }) {
    return AccessSessionInfo(
      authRequired: true,
      authenticated: true,
      email: email,
      displayName: 'Ranger',
      roleKey: 'editor',
      roleName: roleName,
      isAdmin: false,
      permissions: const ['view_map', 'edit_map_objects'],
      canEditMap: true,
      canManageUsers: false,
      canManageRoles: false,
      canManageSettings: false,
      canManageBackups: true,
      canManageApiKeys: false,
      canManageLayers: true,
      canManageTides: true,
      canManageGeocoding: true,
      canManageMarkerIcons: true,
      canManageThemes: false,
      canManagePmtiles: true,
      canManageMapHome: true,
      canManageMapZoom: false,
      canViewWatchLog: true,
      canAddWatchLog: true,
    );
  }
}
