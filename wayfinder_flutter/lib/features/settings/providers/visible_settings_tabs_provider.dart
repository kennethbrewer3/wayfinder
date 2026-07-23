import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../access/providers/access_session_provider.dart';
import '../settings_tab.dart';

/// Settings tabs the current role is allowed to open.
///
/// Always includes General, Backup, and About. Management tabs are omitted
/// when the matching permission (or map-edit role for trash) is missing.
final visibleSettingsTabsProvider = Provider<List<SettingsTab>>((ref) {
  final canManageUsers = ref.watch(canManageUsersProvider);
  final canManageRoles = ref.watch(canManageRolesProvider);
  final mapEditsLocked = ref.watch(mapEditsLockedByRoleProvider);

  return [
    SettingsTab.general,
    if (ref.watch(canManagePmtilesProvider)) SettingsTab.mapTiles,
    if (ref.watch(canManageMarkerIconsProvider)) SettingsTab.markerIcons,
    if (ref.watch(canManageThemesProvider)) SettingsTab.themes,
    if (ref.watch(canManageGeocodingProvider)) SettingsTab.geocoding,
    if (ref.watch(canManageTidesProvider)) SettingsTab.tides,
    if (ref.watch(canManageLayersProvider)) SettingsTab.seasonalOverlays,
    if (canManageUsers || canManageRoles) SettingsTab.users,
    if (!mapEditsLocked) SettingsTab.trash,
    SettingsTab.backup,
    SettingsTab.about,
  ];
});
