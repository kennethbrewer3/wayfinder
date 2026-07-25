import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_globals.dart';
import '../../../core/server_config.dart';
import '../../../core/serverpod_client.dart';
import '../../settings/providers/server_config_provider.dart';
import 'access_session_provider.dart';

/// UI flags for the server URL editor (not the URL strings themselves).
@immutable
class ApiServerUrlUiState {
  const ApiServerUrlUiState({this.saving = false, this.errorMessage});

  final bool saving;
  final String? errorMessage;

  ApiServerUrlUiState copyWith({
    bool? saving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ApiServerUrlUiState(
      saving: saving ?? this.saving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// ViewModel: persist / apply API + web server URLs.
///
/// Independent of Flutter UI objects — callers pass field text into [save].
class ApiServerUrlViewModel extends Notifier<ApiServerUrlUiState> {
  @override
  ApiServerUrlUiState build() => const ApiServerUrlUiState();

  /// Persists [apiUrl] and [webUrl], then rebinds the Serverpod client.
  Future<AppServerConfig?> save({
    required String apiUrl,
    required String webUrl,
  }) async {
    if (state.saving) {
      return null;
    }
    state = state.copyWith(saving: true, clearError: true);
    try {
      final config = await ref
          .read(serverUrlSettingsControllerProvider)
          .saveServerUrls(apiUrlInput: apiUrl, webUrlInput: webUrl);
      await applyAppServerConfig(config);
      ref.read(serverClientEpochProvider.notifier).state++;
      ref.invalidate(savedServerApiUrlProvider);
      ref.invalidate(savedServerWebUrlProvider);
      await ref.read(accessSessionProvider.notifier).refresh();
      state = state.copyWith(saving: false);
      return config;
    } on FormatException catch (error) {
      state = state.copyWith(saving: false, errorMessage: error.message);
      return null;
    } catch (error) {
      state = state.copyWith(
        saving: false,
        errorMessage: 'Failed to save server URLs: $error',
      );
      return null;
    }
  }
}

final apiServerUrlViewModelProvider =
    NotifierProvider<ApiServerUrlViewModel, ApiServerUrlUiState>(
      ApiServerUrlViewModel.new,
    );
