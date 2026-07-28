import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

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
    List<String>? regionIds,
    String? sourceUrl,
    bool useLocalPbf = false,
    bool forceRedownload = false,
  }) async {
    final response = await loggedHttpPost(
      Uri.parse('$baseUrl/api/routing/import'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (regionId != null && regionId.isNotEmpty) 'regionId': regionId,
        if (regionIds != null && regionIds.isNotEmpty) 'regionIds': regionIds,
        if (sourceUrl != null && sourceUrl.isNotEmpty) 'sourceUrl': sourceUrl,
        if (useLocalPbf) 'useLocalPbf': true,
        if (forceRedownload) 'forceRedownload': true,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'POST /api/routing/import returned ${response.statusCode}',
      );
    }
    return getStatus();
  }

  /// Stream a local `.osm.pbf` to the routing server and start the graph build.
  ///
  /// Prefer copying multi‑GB extracts onto the server data volume with
  /// `scp`/`rsync`, then [startImport] with `useLocalPbf: true`.
  Future<RoutingStatus> uploadOsmPbf({
    required Stream<List<int>> bytes,
    String? filename,
    bool startBuild = true,
    int? contentLength,
  }) async {
    final uri = Uri.parse('$baseUrl/api/routing/osm').replace(
      queryParameters: {'build': startBuild ? 'true' : 'false'},
    );
    final request = http.StreamedRequest('POST', uri);
    request.headers['Content-Type'] = 'application/octet-stream';
    if (filename != null && filename.trim().isNotEmpty) {
      request.headers['X-Wayfinder-Osm-Filename'] = filename.trim();
    }
    if (contentLength != null && contentLength > 0) {
      request.contentLength = contentLength;
    }

    final client = LoggingHttpClient(logger: _log);
    try {
      final responseFuture = client.send(request);
      await request.sink.addStream(bytes);
      await request.sink.close();
      final streamed = await responseFuture;
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode != 200) {
        throw Exception(
          'POST /api/routing/osm returned ${response.statusCode}: '
          '${response.body}',
        );
      }
      return getStatus();
    } finally {
      client.close();
    }
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
        'POST /api/routing/route returned ${response.statusCode}: '
        '${response.body}',
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
