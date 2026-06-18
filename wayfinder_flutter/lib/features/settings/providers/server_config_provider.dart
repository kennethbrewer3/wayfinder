import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/server_config.dart';
import '../../../core/server_config_storage.dart';

final serverConfigStorageProvider = Provider<ServerConfigStorage>(
  (ref) => ServerConfigStorage(),
);

final savedServerApiUrlProvider = FutureProvider<String?>((ref) async {
  return ref.watch(serverConfigStorageProvider).loadApiUrl();
});

class ServerUrlSettingsController {
  ServerUrlSettingsController(this._storage);

  final ServerConfigStorage _storage;

  Future<AppServerConfig> saveApiUrl(String input) async {
    final apiUrl = normalizeApiUrl(input);
    await _storage.saveApiUrl(apiUrl);
    return AppServerConfig(
      apiUrl: apiUrl,
      webUrl: defaultWebUrlForApi(apiUrl) ?? defaultWebUrl,
    );
  }

  Future<void> resetToDefault() => _storage.clearApiUrl();
}

final serverUrlSettingsControllerProvider = Provider<ServerUrlSettingsController>(
  (ref) => ServerUrlSettingsController(ref.watch(serverConfigStorageProvider)),
);
