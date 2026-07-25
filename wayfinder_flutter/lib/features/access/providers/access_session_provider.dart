import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/serverpod_client.dart';

final accessSessionProvider =
    AsyncNotifierProvider<AccessSessionNotifier, AccessSessionInfo>(
      AccessSessionNotifier.new,
    );

class AccessSessionNotifier extends AsyncNotifier<AccessSessionInfo> {
  Client? _boundClient;

  @override
  Future<AccessSessionInfo> build() async {
    // Prefer read + epoch listen over watch(serverClientProvider). Watching the
    // client rebuilds this notifier into a bare AsyncLoading (no previous
    // session), which unmounts SignInScreen and scrambles text fields.
    ref.listen<int>(serverClientEpochProvider, (previous, next) {
      if (previous == null || previous == next) {
        return;
      }
      unawaited(_rebindClientAndRefresh());
    });

    final apiClient = ref.read(serverClientProvider);
    _bindAuthListener(apiClient);
    ref.onDispose(_unbindAuthListener);
    return _fetch(apiClient);
  }

  void _bindAuthListener(Client apiClient) {
    _unbindAuthListener();
    _boundClient = apiClient;
    apiClient.auth.authInfoListenable.addListener(_onAuthChanged);
  }

  void _unbindAuthListener() {
    final bound = _boundClient;
    if (bound == null) {
      return;
    }
    bound.auth.authInfoListenable.removeListener(_onAuthChanged);
    _boundClient = null;
  }

  void _onAuthChanged() {
    // No session yet (connection / first load): ignore auth listenable noise so
    // we do not refresh-storm while the user types the server URL.
    if (!state.hasValue) {
      return;
    }
    unawaited(refresh());
  }

  Future<void> _rebindClientAndRefresh() async {
    _bindAuthListener(ref.read(serverClientProvider));
    await refresh();
  }

  Future<AccessSessionInfo> _fetch(Client apiClient) {
    return apiClient.accessControl.getSessionInfo();
  }

  Future<void> refresh() async {
    final previous = state;
    // Keep the prior session visible (isRefreshing) so AuthGate does not swap
    // screens and dispose text fields mid-edit.
    state = const AsyncLoading<AccessSessionInfo>().copyWithPrevious(previous);
    final next = await AsyncValue.guard(
      () => _fetch(ref.read(serverClientProvider)),
    );
    // Failed refresh must not drop a known session — that flipped AuthGate from
    // sign-in → connection and destroyed focused TextFields.
    if (next.hasError && previous.hasValue) {
      state = AsyncError<AccessSessionInfo>(
        next.error!,
        next.stackTrace ?? StackTrace.current,
      ).copyWithPrevious(previous);
      return;
    }
    state = next;
  }

  Future<void> signOut() async {
    await ref.read(serverClientProvider).auth.signOutDevice();
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

final canManageThemesProvider = Provider<bool>((ref) {
  final session = ref.watch(accessSessionProvider).valueOrNull;
  if (session == null) {
    return false;
  }
  if (!session.authRequired) {
    return true;
  }
  return session.canManageThemes;
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

final canViewWatchLogProvider = Provider<bool>((ref) {
  final session = ref.watch(accessSessionProvider).valueOrNull;
  if (session == null) {
    return false;
  }
  if (!session.authRequired) {
    return true;
  }
  return session.canViewWatchLog;
});

final canAddWatchLogProvider = Provider<bool>((ref) {
  final session = ref.watch(accessSessionProvider).valueOrNull;
  if (session == null) {
    return false;
  }
  if (!session.authRequired) {
    return true;
  }
  return session.canAddWatchLog;
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
    canManageThemes: true,
    canManagePmtiles: true,
    canManageMapHome: true,
    canManageMapZoom: true,
    canViewWatchLog: true,
    canAddWatchLog: true,
  );
}
