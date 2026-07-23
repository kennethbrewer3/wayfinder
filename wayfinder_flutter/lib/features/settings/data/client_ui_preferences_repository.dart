import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/serverpod_client.dart';
import '../../access/providers/access_session_provider.dart';
import '../models/client_preferences.dart';
import 'client_ui_preferences_storage.dart';

/// Loads and saves personal UI preferences.
///
/// - Signed in: per-user row on the Wayfinder server (follows the account).
/// - Open / bootstrap (no TOC users): shared AppSettings defaults via my-prefs.
/// - Auth required but unsigned: device cache only until sign-in.
class ClientUiPreferencesRepository {
  ClientUiPreferencesRepository(this._ref);

  final Ref _ref;
  static final _log = AppLogger.logSettings;

  Client get _client => _ref.read(serverClientProvider);

  AccessSessionInfo? get _session =>
      _ref.read(accessSessionProvider).valueOrNull;

  Future<ClientPreferences> get() async {
    final session = _session;
    final authUserId = session?.authUserId?.uuid;

    if (session != null && session.authRequired && !session.authenticated) {
      final local = await ClientUiPreferencesStorage.read();
      return local ?? ClientPreferences.defaults;
    }

    try {
      final remote = await _client.appSettings.getMyClientPreferences();
      final mapped = ClientPreferences.fromUserClientPreferences(remote);
      await ClientUiPreferencesStorage.write(
        mapped,
        authUserId: authUserId,
      );
      return mapped;
    } catch (error, _) {
      _log.warn(
        '⚙️ Failed to load UI preferences from server; using device cache',
        error: error,
      );
      final local = await ClientUiPreferencesStorage.read(
        authUserId: authUserId,
      );
      return local ?? ClientPreferences.defaults;
    }
  }

  Future<ClientPreferences> patch(
    ClientPreferences Function(ClientPreferences current) update,
  ) async {
    final session = _session;
    final authUserId = session?.authUserId?.uuid;
    final current = await get();
    final next = update(current);

    if (session != null && session.authRequired && !session.authenticated) {
      await ClientUiPreferencesStorage.write(next);
      return next;
    }

    try {
      final payload = next.toLocalJson();
      final remote = await _client.appSettings.updateMyClientPreferences(
        payload['measurementUnits'] as String,
        payload['angleDisplayFormat'] as String,
        payload['bearingReference'] as String,
        payload['circleSizeDisplay'] as String,
        payload['appTheme'] as String,
        payload['appLocale'] as String,
        payload['mapMarkerSizeScale'] as double,
        payload['mapViewportDebugBorder'] as bool,
        payload['mapTileBorderDebug'] as bool,
        payload['mapCompassRoseEnabled'] as bool,
        payload['mapMgrsGridEnabled'] as bool,
        payload['darkMapTilesInDarkMode'] as bool,
        payload['polygonSnapRightAngles'] as bool,
        payload['polygonSnap45Angles'] as bool,
      );
      final mapped = ClientPreferences.fromUserClientPreferences(remote);
      await ClientUiPreferencesStorage.write(
        mapped,
        authUserId: authUserId,
      );
      return mapped;
    } catch (error, _) {
      _log.warn(
        '⚙️ Failed to save UI preferences to server; keeping device cache',
        error: error,
      );
      await ClientUiPreferencesStorage.write(
        next,
        authUserId: authUserId,
      );
      return next;
    }
  }
}

final clientUiPreferencesRepositoryProvider =
    Provider<ClientUiPreferencesRepository>(
      (ref) => ClientUiPreferencesRepository(ref),
    );

/// Watched from [WayfinderApp] so personal prefs reload after sign-in/out.
final clientUiPreferencesAuthListenerProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<AccessSessionInfo>>(accessSessionProvider, (
    previous,
    next,
  ) {
    final prevUser = previous?.valueOrNull?.authUserId?.uuid;
    final nextUser = next.valueOrNull?.authUserId?.uuid;
    final prevAuth = previous?.valueOrNull?.authenticated;
    final nextAuth = next.valueOrNull?.authenticated;
    if (previous == null) {
      return;
    }
    if (prevUser == nextUser && prevAuth == nextAuth) {
      return;
    }
    // Recreate preference notifiers so they load the signed-in user's server row.
    ref.invalidate(clientUiPreferencesRepositoryProvider);
  });
});
