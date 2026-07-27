import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_globals.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/logging/logging_http_client.dart';
import '../models/routing_models.dart';

class RoutingRepository {
  RoutingRepository({String? routingWebServerUrl})
    : _webServerUrl = _normalizeOptionalBaseUrl(routingWebServerUrl);

  final String? _webServerUrl;
  static final _log = AppLogger.logSettings;

  bool get isConfigured =>
      _webServerUrl != null && _webServerUrl.trim().isNotEmpty;

  String get baseUrl {
    final url = _webServerUrl;
    if (url == null || url.isEmpty) {
      throw StateError('Routing server URL is not configured.');
    }
    return url;
  }

  Future<bool> isServerReachable() async {
    if (!isConfigured) {
      return false;
    }
    try {
      final response = await loggedHttpGet(
        Uri.parse('$baseUrl/api/health'),
        timeout: const Duration(seconds: 5),
      );
      return response.statusCode == 200;
    } catch (error, _) {
      _log.warn('🧭 Routing server health check failed', error: error);
      return false;
    }
  }

  Future<RoutingStatus> getStatus() async {
    final response = await loggedHttpGet(
      Uri.parse('$baseUrl/api/routing/status'),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'GET /api/routing/status returned ${response.statusCode}',
      );
    }
    return RoutingStatus.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<List<RoutingRegion>> getRegions() async {
    if (!isConfigured) {
      return const [];
    }
    final response = await loggedHttpGet(
      Uri.parse('$baseUrl/api/routing/regions'),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'GET /api/routing/regions returned ${response.statusCode}',
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      return const [];
    }
    final regions = decoded['regions'];
    if (regions is! List) {
      return const [];
    }
    return [
      for (final item in regions)
        if (item is Map<String, dynamic>) RoutingRegion.fromJson(item),
    ];
  }

  Future<RoutingStatus> startImport({
    String? regionId,
    String? sourceUrl,
  }) async {
    final response = await loggedHttpPost(
      Uri.parse('$baseUrl/api/routing/import'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (regionId != null && regionId.isNotEmpty) 'regionId': regionId,
        if (sourceUrl != null && sourceUrl.isNotEmpty) 'sourceUrl': sourceUrl,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'POST /api/routing/import returned ${response.statusCode}',
      );
    }
    return getStatus();
  }

  Future<RoutingStatus> cancelImport() async {
    final response = await loggedHttpPost(
      Uri.parse('$baseUrl/api/routing/import/cancel'),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'POST /api/routing/import/cancel returned ${response.statusCode}',
      );
    }
    return getStatus();
  }

  Future<RoutingResult> route({
    required RoutingPoint from,
    required RoutingPoint to,
    RoutingProfile profile = RoutingProfile.foot,
  }) async {
    final response = await loggedHttpPost(
      Uri.parse('$baseUrl/api/routing/route'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'from': from.toJson(),
        'to': to.toJson(),
        'profile': profile.apiValue,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'POST /api/routing/route returned ${response.statusCode}',
      );
    }
    return RoutingResult.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  static String? _normalizeOptionalBaseUrl(String? input) {
    if (input == null) {
      return null;
    }
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed.replaceAll(RegExp(r'/+$'), '');
  }
}

/// Current routing web URL; updated when the user saves Settings → Routing.
final routingWebUrlProvider = StateProvider<String?>(
  (ref) => appServerConfig.routingWebUrl,
);

final routingRepositoryProvider = Provider<RoutingRepository>((ref) {
  final url = ref.watch(routingWebUrlProvider);
  return RoutingRepository(routingWebServerUrl: url);
});

final routingServerReachableProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(routingRepositoryProvider);
  if (!repository.isConfigured) {
    return false;
  }
  return repository.isServerReachable();
});

/// Polls `/api/routing/status` every few seconds while an import is running.
final routingStatusProvider =
    AsyncNotifierProvider<RoutingStatusNotifier, RoutingStatus>(
      RoutingStatusNotifier.new,
    );

class RoutingStatusNotifier extends AsyncNotifier<RoutingStatus> {
  Timer? _pollTimer;

  @override
  Future<RoutingStatus> build() async {
    ref.onDispose(() => _pollTimer?.cancel());
    final repository = ref.read(routingRepositoryProvider);
    if (!repository.isConfigured) {
      return RoutingStatus.unconfigured;
    }
    if (!await repository.isServerReachable()) {
      return const RoutingStatus(
        status: RoutingImportStatus.unknown,
        ready: false,
        graphhopperUp: false,
        importInProgress: false,
        error: 'unreachable',
      );
    }
    final status = await repository.getStatus();
    _schedulePolling(status);
    return status;
  }

  void _schedulePolling(RoutingStatus status) {
    _pollTimer?.cancel();
    if (!status.importInProgress) {
      return;
    }
    _pollTimer = Timer(const Duration(seconds: 2), () {
      ref.invalidateSelf();
    });
  }
}

final routingRegionsProvider = FutureProvider<List<RoutingRegion>>((
  ref,
) async {
  final repository = ref.watch(routingRepositoryProvider);
  if (!repository.isConfigured) {
    return const [];
  }
  return repository.getRegions();
});

void refreshRouting(WidgetRef ref) {
  ref.invalidate(routingStatusProvider);
  ref.invalidate(routingServerReachableProvider);
  ref.invalidate(routingRegionsProvider);
}
