import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:wayfinder_routing_server/src/config.dart';
import 'package:wayfinder_routing_server/src/graphhopper_process.dart';
import 'package:wayfinder_routing_server/src/regions.dart';
import 'package:wayfinder_routing_server/src/routing_log.dart';
import 'package:wayfinder_routing_server/src/status_store.dart';

/// Downloads OSM PBF data and triggers a GraphHopper graph rebuild.
class ImportService {
  ImportService({
    required this.config,
    required this.statusStore,
    required this.graphHopperProcess,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final RoutingConfig config;
  final StatusStore statusStore;
  final GraphHopperProcess graphHopperProcess;
  final http.Client _http;

  bool _importInProgress = false;
  bool _cancelRequested = false;
  http.Client? _downloadClient;

  bool get isImporting => _importInProgress;

  Future<void> startImport({String? regionId, String? sourceUrl}) async {
    if (_importInProgress) {
      throw StateError('An import is already in progress');
    }

    final resolvedUrl = resolveSourceUrl(
      regionId: regionId,
      sourceUrl: sourceUrl,
    );
    if (resolvedUrl == null) {
      throw ArgumentError(
        'Provide regionId (not custom) or sourceUrl for import',
      );
    }

    routingLog.info(
      'Import requested (regionId=${regionId ?? 'none'}, '
      'sourceUrl=$resolvedUrl)',
    );
    _importInProgress = true;
    _cancelRequested = false;

    unawaited(_runImport(resolvedUrl));
  }

  Future<void> cancelImport() async {
    if (!_importInProgress) {
      routingLog.info('Cancel requested but no import is running');
      return;
    }
    routingLog.warning('Import cancel requested');
    _cancelRequested = true;
    _downloadClient?.close();
    await graphHopperProcess.stop();
    await statusStore.update(
      RoutingStatusSnapshot(
        status: RoutingStatus.cancelled,
        message: 'Import cancelled.',
        ready: false,
      ),
    );
  }

  Future<void> _runImport(String url) async {
    final startedAt = DateTime.now();
    routingLog.info('Import started for $url');
    try {
      await graphHopperProcess.stop();

      await statusStore.update(
        RoutingStatusSnapshot(
          status: RoutingStatus.downloading,
          message: 'Downloading OSM extract…',
          sourceUrl: url,
          progress: 0,
          ready: false,
        ),
      );

      await _downloadPbf(url);

      if (_cancelRequested) {
        routingLog.warning('Import cancelled after download');
        return;
      }

      await statusStore.update(
        RoutingStatusSnapshot(
          status: RoutingStatus.building,
          message: 'Building routing graph (this may take a while)…',
          sourceUrl: url,
          progress: null,
          ready: false,
        ),
      );

      routingLog.info('Download complete — building GraphHopper graph…');
      await graphHopperProcess.rebuild();

      if (_cancelRequested) {
        routingLog.warning('Import cancelled after graph build');
        return;
      }

      await statusStore.update(
        RoutingStatusSnapshot(
          status: RoutingStatus.ready,
          message: 'Routing graph is ready.',
          sourceUrl: url,
          progress: 1,
          ready: true,
        ),
      );
      final elapsed = DateTime.now().difference(startedAt);
      routingLog.info(
        'Import finished successfully in ${elapsed.inSeconds}s '
        '(sourceUrl=$url)',
      );
    } on Object catch (error, stackTrace) {
      if (_cancelRequested) {
        routingLog.warning('Import ended after cancel', error, stackTrace);
        return;
      }
      routingLog.severe('Import failed for $url', error, stackTrace);
      await statusStore.update(
        RoutingStatusSnapshot(
          status: RoutingStatus.failed,
          message: 'Import failed.',
          sourceUrl: url,
          ready: false,
          error: error.toString(),
        ),
      );
    } finally {
      _importInProgress = false;
      _cancelRequested = false;
      _downloadClient?.close();
      _downloadClient = null;
    }
  }

  Future<void> _downloadPbf(String url) async {
    final dir = Directory(config.dataDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
      routingLog.info('Created data directory ${config.dataDir}');
    }

    final target = File(config.osmPbfPath);
    final temp = File('${config.osmPbfPath}.partial');

    routingLog.info('Downloading OSM PBF from $url → ${temp.path}');
    _downloadClient = http.Client();
    final request = http.Request('GET', Uri.parse(url));
    final response = await _downloadClient!.send(request);

    if (response.statusCode != 200) {
      throw HttpException(
        'Download failed: HTTP ${response.statusCode}',
        uri: Uri.parse(url),
      );
    }

    final totalBytes = response.contentLength;
    if (totalBytes != null && totalBytes > 0) {
      routingLog.info(
        'Download Content-Length: ${formatByteSize(totalBytes)} '
        '($totalBytes bytes)',
      );
    } else {
      routingLog.info(
        'Download has no Content-Length; progress percent unavailable',
      );
    }

    var receivedBytes = 0;
    final sink = temp.openWrite();
    var lastReportedProgress = -1.0;
    var lastReportedAt = DateTime.fromMillisecondsSinceEpoch(0);
    var lastLoggedAt = DateTime.fromMillisecondsSinceEpoch(0);

    try {
      await for (final chunk in response.stream) {
        if (_cancelRequested) {
          throw StateError('Download cancelled');
        }
        receivedBytes += chunk.length;
        sink.add(chunk);

        final progress = totalBytes != null && totalBytes > 0
            ? (receivedBytes / totalBytes).clamp(0.0, 1.0)
            : null;

        final now = DateTime.now();
        final shouldReport = progress == null
            ? now.difference(lastReportedAt) >=
                  const Duration(milliseconds: 500)
            : progress >= 1.0 ||
                  progress - lastReportedProgress >= 0.01 ||
                  now.difference(lastReportedAt) >=
                      const Duration(milliseconds: 250);

        if (shouldReport) {
          lastReportedAt = now;
          if (progress != null) {
            lastReportedProgress = progress;
          }
          final percent = progress == null
              ? null
              : (progress * 100).round().clamp(0, 100);
          await statusStore.update(
            RoutingStatusSnapshot(
              status: RoutingStatus.downloading,
              message: percent == null
                  ? 'Downloading OSM extract…'
                  : 'Downloading OSM extract… $percent%',
              sourceUrl: url,
              progress: progress,
              ready: false,
            ),
          );

          final shouldLog = progress == null
              ? now.difference(lastLoggedAt) >= const Duration(seconds: 5)
              : percent == 0 ||
                    percent == 100 ||
                    (percent != null && percent % 5 == 0) ||
                    now.difference(lastLoggedAt) >= const Duration(seconds: 10);
          if (shouldLog) {
            lastLoggedAt = now;
            if (percent != null && totalBytes != null) {
              routingLog.info(
                'Download progress: $percent% '
                '(${formatByteSize(receivedBytes)} / '
                '${formatByteSize(totalBytes)})',
              );
            } else {
              routingLog.info(
                'Download progress: ${formatByteSize(receivedBytes)} received',
              );
            }
          }
        }
      }
    } finally {
      await sink.close();
    }

    if (_cancelRequested) {
      if (await temp.exists()) {
        await temp.delete();
      }
      return;
    }

    if (await target.exists()) {
      await target.delete();
    }
    await temp.rename(target.path);
    final size = await target.length();
    routingLog.info(
      'OSM PBF saved to ${target.path} (${formatByteSize(size)})',
    );
  }

  void dispose() {
    _http.close();
  }
}
