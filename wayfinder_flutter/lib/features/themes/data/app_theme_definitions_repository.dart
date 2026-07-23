import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/serverpod_client.dart';

final appThemeDefinitionsRepositoryProvider =
    Provider<AppThemeDefinitionsRepository>(
      (ref) => AppThemeDefinitionsRepository(
        client: ref.watch(serverClientProvider),
      ),
    );

class AppThemeDefinitionsRepository {
  AppThemeDefinitionsRepository({required Client client}) : _client = client;

  final Client _client;
  static final _log = AppLogger.logSettings;

  Future<List<AppThemeDefinition>> list() async {
    try {
      return await _client.appTheme.listThemes();
    } catch (error, _) {
      _log.warn('🎨 Failed to list custom themes', error: error);
      rethrow;
    }
  }

  Future<AppThemeDefinition> create({
    required String name,
    required String brightness,
    required String seedColor,
    required String overridesJson,
  }) {
    return _client.appTheme.createTheme(
      name,
      brightness,
      seedColor,
      overridesJson,
    );
  }

  Future<AppThemeDefinition> update({
    required UuidValue id,
    required String name,
    required String brightness,
    required String seedColor,
    required String overridesJson,
  }) {
    return _client.appTheme.updateTheme(
      id,
      name,
      brightness,
      seedColor,
      overridesJson,
    );
  }

  Future<bool> delete(UuidValue id) {
    return _client.appTheme.deleteTheme(id);
  }

  Future<AppThemeDefinition> importJson(String exportJson) {
    return _client.appTheme.importTheme(exportJson);
  }

  Future<String> exportJson(UuidValue id) {
    return _client.appTheme.exportTheme(id);
  }
}
