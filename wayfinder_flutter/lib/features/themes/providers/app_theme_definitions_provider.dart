import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/serverpod_client.dart';
import '../data/app_theme_definitions_repository.dart';

export '../data/app_theme_definitions_repository.dart';

final appThemeDefinitionsProvider =
    AsyncNotifierProvider<
      AppThemeDefinitionsNotifier,
      List<AppThemeDefinition>
    >(AppThemeDefinitionsNotifier.new);

class AppThemeDefinitionsNotifier
    extends AsyncNotifier<List<AppThemeDefinition>> {
  @override
  Future<List<AppThemeDefinition>> build() async {
    // App watches this at startup for theme resolution. Wait for the session
    // restore so mobile Secure Storage finishes before listThemes is called.
    final apiClient = ref.watch(serverClientProvider);
    await apiClient.auth.initialize();
    return ref.read(appThemeDefinitionsRepositoryProvider).list();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final apiClient = ref.read(serverClientProvider);
      await apiClient.auth.initialize();
      return ref.read(appThemeDefinitionsRepositoryProvider).list();
    });
  }
}
