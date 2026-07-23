import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

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
  Future<List<AppThemeDefinition>> build() {
    return ref.read(appThemeDefinitionsRepositoryProvider).list();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(appThemeDefinitionsRepositoryProvider).list(),
    );
  }
}
