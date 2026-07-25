import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/server_config.dart';
import '../../../core/server_config_storage.dart';

final serverConfigStorageProvider = Provider<ServerConfigStorage>(
  (ref) => ServerConfigStorage(),
);

final savedServerApiUrlProvider = FutureProvider<String?>((ref) async {
  return ref.watch(serverConfigStorageProvider).loadApiUrl();
});

final savedServerWebUrlProvider = FutureProvider<String?>((ref) async {
  return ref.watch(serverConfigStorageProvider).loadWebUrl();
});

class ServerUrlSettingsController {
  ServerUrlSettingsController(this._storage);

  final ServerConfigStorage _storage;

  /// Persists API + web URLs. Both are required and stored independently.
  Future<AppServerConfig> saveServerUrls({
    required String apiUrlInput,
    required String webUrlInput,
  }) async {
    final apiUrl = normalizeApiUrl(apiUrlInput);
    final webUrl = normalizeWebUrl(webUrlInput);
    await _storage.saveApiUrl(apiUrl);
    await _storage.saveWebUrl(webUrl);
    return AppServerConfig(apiUrl: apiUrl, webUrl: webUrl);
  }

  Future<void> resetToDefault() => _storage.clearServerUrls();
}

final serverUrlSettingsControllerProvider =
    Provider<ServerUrlSettingsController>(
      (ref) =>
          ServerUrlSettingsController(ref.watch(serverConfigStorageProvider)),
    );
