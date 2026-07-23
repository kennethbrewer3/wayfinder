import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/app_globals.dart';
import '../../../core/serverpod_client.dart';

final accessSessionProvider =
    AsyncNotifierProvider<AccessSessionNotifier, AccessSessionInfo>(
      AccessSessionNotifier.new,
    );

class AccessSessionNotifier extends AsyncNotifier<AccessSessionInfo> {
  @override
  Future<AccessSessionInfo> build() async {
    final apiClient = ref.watch(serverClientProvider);
    client.auth.authInfoListenable.addListener(_onAuthChanged);
    ref.onDispose(() {
      client.auth.authInfoListenable.removeListener(_onAuthChanged);
    });
    return _fetch(apiClient);
  }

  void _onAuthChanged() {
    ref.invalidateSelf();
  }

  Future<AccessSessionInfo> _fetch(Client apiClient) {
    return apiClient.accessControl.getSessionInfo();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(ref.read(serverClientProvider)),
    );
  }

  Future<void> signOut() async {
    await client.auth.signOutDevice();
    await refresh();
  }
}

/// True when the UI should hide map/object mutations (viewer or unsigned).
final mapEditsLockedByRoleProvider = Provider<bool>((ref) {
  final session = ref.watch(accessSessionProvider).valueOrNull;
  if (session == null) {
    return false;
  }
  if (!session.authRequired) {
    return false;
  }
  if (!session.authenticated) {
    return true;
  }
  return !session.canEditMap;
});

/// Convenience: signed-in admin (or open mode).
final canManageUsersProvider = Provider<bool>((ref) {
  final session = ref.watch(accessSessionProvider).valueOrNull;
  if (session == null) {
    return false;
  }
  if (!session.authRequired) {
    return true;
  }
  return session.canManageUsers;
});

final canManageRolesProvider = Provider<bool>((ref) {
  final session = ref.watch(accessSessionProvider).valueOrNull;
  if (session == null) {
    return false;
  }
  if (!session.authRequired) {
    return true;
  }
  return session.canManageRoles;
});

final canManageApiKeysProvider = Provider<bool>((ref) {
  final session = ref.watch(accessSessionProvider).valueOrNull;
  if (session == null) {
    return false;
  }
  if (!session.authRequired) {
    return true;
  }
  return session.canManageApiKeys;
});

final canManageBackupsProvider = Provider<bool>((ref) {
  final session = ref.watch(accessSessionProvider).valueOrNull;
  if (session == null) {
    return false;
  }
  if (!session.authRequired) {
    return true;
  }
  return session.canManageBackups;
});

final canManageLayersProvider = Provider<bool>((ref) {
  final session = ref.watch(accessSessionProvider).valueOrNull;
  if (session == null) {
    return false;
  }
  if (!session.authRequired) {
    return true;
  }
  return session.canManageLayers;
});

final canManageTidesProvider = Provider<bool>((ref) {
  final session = ref.watch(accessSessionProvider).valueOrNull;
  if (session == null) {
    return false;
  }
  if (!session.authRequired) {
    return true;
  }
  return session.canManageTides;
});

final canManageGeocodingProvider = Provider<bool>((ref) {
  final session = ref.watch(accessSessionProvider).valueOrNull;
  if (session == null) {
    return false;
  }
  if (!session.authRequired) {
    return true;
  }
  return session.canManageGeocoding;
});

final canManageMarkerIconsProvider = Provider<bool>((ref) {
  final session = ref.watch(accessSessionProvider).valueOrNull;
  if (session == null) {
    return false;
  }
  if (!session.authRequired) {
    return true;
  }
  return session.canManageMarkerIcons;
});

final canManagePmtilesProvider = Provider<bool>((ref) {
  final session = ref.watch(accessSessionProvider).valueOrNull;
  if (session == null) {
    return false;
  }
  if (!session.authRequired) {
    return true;
  }
  return session.canManagePmtiles;
});

final canManageMapHomeProvider = Provider<bool>((ref) {
  final session = ref.watch(accessSessionProvider).valueOrNull;
  if (session == null) {
    return false;
  }
  if (!session.authRequired) {
    return true;
  }
  return session.canManageMapHome;
});

final canManageMapZoomProvider = Provider<bool>((ref) {
  final session = ref.watch(accessSessionProvider).valueOrNull;
  if (session == null) {
    return false;
  }
  if (!session.authRequired) {
    return true;
  }
  return session.canManageMapZoom;
});

/// True when the signed-in role may change this device's Wayfinder server URL.
/// Viewers are locked out; editors and open mode may still re-point the client.
final canEditServerConnectionProvider = Provider<bool>((ref) {
  final session = ref.watch(accessSessionProvider).valueOrNull;
  if (session == null) {
    return true;
  }
  if (!session.authRequired) {
    return true;
  }
  if (!session.authenticated) {
    return false;
  }
  return session.canEditMap ||
      session.isAdmin ||
      session.canManageSettings ||
      session.canManageMapHome ||
      session.canManagePmtiles;
});

@visibleForTesting
AccessSessionInfo openAccessSessionForTests() {
  return AccessSessionInfo(
    authRequired: false,
    authenticated: false,
    isAdmin: false,
    permissions: const [],
    canEditMap: true,
    canManageUsers: true,
    canManageRoles: true,
    canManageSettings: true,
    canManageBackups: true,
    canManageApiKeys: true,
    canManageLayers: true,
    canManageTides: true,
    canManageGeocoding: true,
    canManageMarkerIcons: true,
    canManagePmtiles: true,
    canManageMapHome: true,
    canManageMapZoom: true,
  );
}
