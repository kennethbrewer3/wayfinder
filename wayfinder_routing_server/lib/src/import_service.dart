import 'dart:async';
import 'dart:convert';
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

  /// Marker URL written when the PBF came from upload or a host volume copy.
  static const localSourceUrl = 'local://osm.pbf';

  final RoutingConfig config;
  final StatusStore statusStore;
  final GraphHopperProcess graphHopperProcess;
  final http.Client _http;

  bool _importInProgress = false;
  bool _cancelRequested = false;
  bool _forceRedownload = false;
  http.Client? _downloadClient;
  String? _activeRegionId;
  String? _activeRegionName;
  String? _activeSourceUrl;

  bool get isImporting => _importInProgress;

  Future<void> startImport({
    String? regionId,
    List<String>? regionIds,
    String? sourceUrl,
    bool forceRedownload = false,
    bool useLocalPbf = false,
  }) async {
    if (_importInProgress) {
      throw StateError('An import is already in progress');
    }

    final multiIds = <String>[
      ...?regionIds?.map((id) => id.trim()).where((id) => id.isNotEmpty),
    ];
    if (regionId != null &&
        regionId.trim().isNotEmpty &&
        regionId != 'custom' &&
        !multiIds.contains(regionId.trim())) {
      multiIds.add(regionId.trim());
    }
    // Deduplicate while preserving order.
    final uniqueIds = <String>[];
    for (final id in multiIds) {
      if (!uniqueIds.contains(id)) {
        uniqueIds.add(id);
      }
    }

    if (uniqueIds.length > 1) {
      for (final id in uniqueIds) {
        final region = regionById(id);
        if (region?.sourceUrl == null) {
          throw ArgumentError(
            'Unknown or non-downloadable regionId for merge: $id',
          );
        }
      }
      final displayName = combinedDisplayName(uniqueIds);
      final mergeUrl = mergeSourceUrl(uniqueIds);
      final combinedId = combinedRegionId(uniqueIds);
      routingLog.info(
        'Import requested (multi-region=$combinedId, '
        'regionName=$displayName, sourceUrl=$mergeUrl, '
        'forceRedownload=$forceRedownload)',
      );
      routingConsole(
        'IMPORT REQUESTED multi-region=$displayName ids=$combinedId',
      );
      _importInProgress = true;
      _cancelRequested = false;
      _forceRedownload = forceRedownload;
      _activeRegionId = combinedId;
      _activeRegionName = displayName;
      _activeSourceUrl = mergeUrl;
      unawaited(_runMultiRegionImport(uniqueIds, mergeUrl));
      return;
    }

    late final String resolvedUrl;
    String? matchedId = uniqueIds.isEmpty ? regionId : uniqueIds.first;
    String displayName;

    if (useLocalPbf) {
      final inventory = await localOsmInventory();
      if (!inventory.present) {
        throw ArgumentError(
          'No OSM PBF on the routing server data volume '
          '(${config.osmPbfPath}). Copy a .osm.pbf there or upload one first.',
        );
      }
      final cached = (await readCachedSourceUrl())?.trim();
      resolvedUrl = (cached != null && cached.isNotEmpty)
          ? cached
          : localSourceUrl;
      displayName = extractDisplayName(
        regionId: matchedId,
        sourceUrl: resolvedUrl,
      );
      if (displayName == 'custom region' ||
          resolvedUrl.startsWith('local://')) {
        displayName = 'local OSM file';
      }
      matchedId = matchedId ?? 'local';
      forceRedownload = false;
    } else {
      final url = resolveSourceUrl(
        regionId: matchedId,
        sourceUrl: sourceUrl,
      );
      if (url == null) {
        throw ArgumentError(
          'Provide regionId / regionIds, sourceUrl, or useLocalPbf',
        );
      }
      resolvedUrl = url;
      final matched = (matchedId != null && matchedId != 'custom')
          ? regionById(matchedId)
          : regionBySourceUrl(resolvedUrl);
      matchedId = matched?.id ?? matchedId;
      displayName = extractDisplayName(
        regionId: matchedId,
        sourceUrl: resolvedUrl,
      );
    }

    routingLog.info(
      'Import requested (regionId=${matchedId ?? 'custom'}, '
      'regionName=$displayName, sourceUrl=$resolvedUrl, '
      'forceRedownload=$forceRedownload, useLocalPbf=$useLocalPbf)',
    );
    routingConsole(
      'IMPORT REQUESTED region=$displayName '
      'regionId=${matchedId ?? 'custom'} url=$resolvedUrl',
    );
    _importInProgress = true;
    _cancelRequested = false;
    _forceRedownload = forceRedownload;
    _activeRegionId = matchedId;
    _activeRegionName = displayName;
    _activeSourceUrl = resolvedUrl;

    unawaited(_runImport(resolvedUrl));
  }

  /// After OOM / failed build: if a complete OSM PBF is already on disk but the
  /// graph cache is missing, continue from the GraphHopper build phase.
  ///
  /// Typical flow: raise `JAVA_XMX`, recreate the container, and the server
  /// resumes without re-downloading the extract.
  Future<bool> tryResumeBuildFromCachedPbf() async {
    if (_importInProgress) {
      return false;
    }
    if (await graphHopperProcess.graphCacheExists()) {
      return false;
    }

    final inventory = await localOsmInventory();
    if (!inventory.present) {
      return false;
    }

    final url = (await readCachedSourceUrl())?.trim();
    final statusUrl = statusStore.current.sourceUrl?.trim();
    final resolvedUrl = (url != null && url.isNotEmpty)
        ? url
        : (statusUrl != null && statusUrl.isNotEmpty
              ? statusUrl
              : localSourceUrl);

    final regionId = statusStore.current.regionId;
    routingLog.info(
      'Resuming graph build from cached OSM PBF '
      '(${formatByteSize(inventory.bytes)}, url=$resolvedUrl, '
      'regionId=${regionId ?? 'custom'})',
    );
    routingConsole(
      'RESUME BUILD from cached OSM extract '
      '(${formatByteSize(inventory.bytes)}) url=$resolvedUrl',
    );

    await startImport(
      regionId: regionId,
      sourceUrl: resolvedUrl.startsWith('local://') ? null : resolvedUrl,
      forceRedownload: false,
      useLocalPbf: true,
    );
    return true;
  }

  /// Stream an OSM PBF onto the data volume, then optionally start a graph build.
  Future<LocalOsmInstallResult> installLocalPbf({
    required Stream<List<int>> bytes,
    String? filename,
    bool startBuild = true,
  }) async {
    if (_importInProgress) {
      throw StateError('An import is already in progress');
    }
    _importInProgress = true;
    _cancelRequested = false;
    var buildHandedOff = false;

    try {
      final dir = Directory(config.dataDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final target = File(config.osmPbfPath);
      final temp = File('${config.osmPbfPath}.partial');
      if (await temp.exists()) {
        await temp.delete();
      }

      final label = (filename != null && filename.trim().isNotEmpty)
          ? filename.trim()
          : 'osm.pbf';
      routingLog.info('Installing local OSM PBF ($label) → ${temp.path}');
      routingConsole('OSM UPLOAD/INSTALL started filename=$label');

      await statusStore.update(
        RoutingStatusSnapshot(
          status: RoutingStatus.downloading,
          message: 'Receiving OSM file: $label…',
          sourceUrl: 'local://$label',
          regionId: 'local',
          regionName: 'local OSM file',
          progress: null,
          ready: false,
        ),
      );

      var receivedBytes = 0;
      final sink = temp.openWrite();
      var lastLoggedAt = DateTime.fromMillisecondsSinceEpoch(0);
      try {
        await for (final chunk in bytes) {
          if (_cancelRequested) {
            throw StateError('OSM install cancelled');
          }
          receivedBytes += chunk.length;
          sink.add(chunk);
          final now = DateTime.now();
          if (now.difference(lastLoggedAt) >= const Duration(seconds: 5)) {
            lastLoggedAt = now;
            routingLog.info(
              'OSM install progress ($label): ${formatByteSize(receivedBytes)}',
            );
            await statusStore.update(
              RoutingStatusSnapshot(
                status: RoutingStatus.downloading,
                message:
                    'Receiving OSM file: $label… '
                    '${formatByteSize(receivedBytes)}',
                sourceUrl: 'local://$label',
                regionId: 'local',
                regionName: 'local OSM file',
                progress: null,
                ready: false,
              ),
            );
          }
        }
      } catch (error) {
        await sink.close();
        if (await temp.exists()) {
          await temp.delete();
        }
        rethrow;
      }
      await sink.close();

      if (receivedBytes <= 0) {
        if (await temp.exists()) {
          await temp.delete();
        }
        throw ArgumentError('Uploaded OSM file was empty');
      }

      if (await target.exists()) {
        await target.delete();
      }
      await temp.rename(target.path);
      final sourceMarker = 'local://$label';
      await writeCachedSourceUrl(sourceMarker);
      routingLog.info(
        'OSM PBF installed at ${target.path} '
        '(${formatByteSize(receivedBytes)})',
      );

      final result = LocalOsmInstallResult(
        bytes: receivedBytes,
        path: target.path,
        sourceUrl: sourceMarker,
        buildStarted: startBuild,
      );

      if (startBuild) {
        // Release the receive lock so startImport can take ownership.
        _importInProgress = false;
        buildHandedOff = true;
        await startImport(useLocalPbf: true);
      } else {
        await statusStore.update(
          RoutingStatusSnapshot(
            status: RoutingStatus.idle,
            message:
                'OSM file ready on server '
                '(${formatByteSize(receivedBytes)}). '
                'Start a local build when ready.',
            sourceUrl: sourceMarker,
            regionId: 'local',
            regionName: 'local OSM file',
            ready: false,
          ),
        );
      }
      return result;
    } on Object catch (error, stackTrace) {
      if (!_cancelRequested) {
        routingLog.severe('Local OSM install failed', error, stackTrace);
        await statusStore.update(
          RoutingStatusSnapshot(
            status: RoutingStatus.failed,
            message: 'OSM file install failed.',
            regionId: 'local',
            regionName: 'local OSM file',
            ready: false,
            error: error.toString(),
          ),
        );
      }
      rethrow;
    } finally {
      if (!buildHandedOff) {
        _importInProgress = false;
        _cancelRequested = false;
      }
    }
  }

  Future<LocalOsmInventory> localOsmInventory() async {
    final file = File(config.osmPbfPath);
    if (!await file.exists()) {
      return const LocalOsmInventory(present: false, bytes: 0);
    }
    final bytes = await file.length();
    if (bytes <= 0) {
      return const LocalOsmInventory(present: false, bytes: 0);
    }
    return LocalOsmInventory(present: true, bytes: bytes);
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
        sourceUrl: _activeSourceUrl,
        regionId: _activeRegionId,
        regionName: _activeRegionName,
        ready: false,
      ),
    );
  }

  Future<void> _runImport(String url) async {
    final startedAt = DateTime.now();
    final regionId = _activeRegionId;
    final regionName = _activeRegionName ?? 'custom region';
    routingLog.info(
      '── Import pipeline start ── region=$regionName '
      'regionId=${regionId ?? 'custom'} url=$url',
    );
    try {
      routingLog.info('Phase: stop any running GraphHopper processes');
      await graphHopperProcess.stop();

      final reusePbf = !_forceRedownload && await hasReusablePbf(url);
      if (reusePbf) {
        final size = await File(config.osmPbfPath).length();
        routingLog.info(
          'Phase: skip download — reusing cached OSM PBF '
          '(${formatByteSize(size)}) for $url',
        );
        await statusStore.update(
          RoutingStatusSnapshot(
            status: RoutingStatus.building,
            message:
                'Using cached OSM extract for $regionName — '
                'building routing graph…',
            sourceUrl: url,
            regionId: regionId,
            regionName: regionName,
            progress: null,
            ready: false,
          ),
        );
        // Ensure sidecar exists for older volumes that only had status.json.
        await writeCachedSourceUrl(url);
      } else {
        await statusStore.update(
          RoutingStatusSnapshot(
            status: RoutingStatus.downloading,
            message: _downloadMessage(regionName),
            sourceUrl: url,
            regionId: regionId,
            regionName: regionName,
            progress: 0,
            ready: false,
          ),
        );

        routingLog.info('Phase: download OSM extract');
        final downloadStarted = DateTime.now();
        await _downloadPbf(url, regionName: regionName, regionId: regionId);
        routingLog.info(
          'Phase: download complete '
          '(${DateTime.now().difference(downloadStarted).inSeconds}s)',
        );
      }

      if (_cancelRequested) {
        routingLog.warning('Import cancelled after download');
        return;
      }

      if (!reusePbf) {
        await statusStore.update(
          RoutingStatusSnapshot(
            status: RoutingStatus.building,
            message: 'Building routing graph for $regionName…',
            sourceUrl: url,
            regionId: regionId,
            regionName: regionName,
            progress: null,
            ready: false,
          ),
        );
      }

      routingLog.info(
        'Phase: GraphHopper rebuild (clear cache + import + start)',
      );
      final buildStarted = DateTime.now();
      await graphHopperProcess.rebuild();
      routingLog.info(
        'Phase: GraphHopper rebuild complete '
        '(${DateTime.now().difference(buildStarted).inSeconds}s)',
      );

      if (_cancelRequested) {
        routingLog.warning('Import cancelled after graph build');
        return;
      }

      await statusStore.update(
        RoutingStatusSnapshot(
          status: RoutingStatus.ready,
          message: 'Routing graph is ready ($regionName).',
          sourceUrl: url,
          regionId: regionId,
          regionName: regionName,
          progress: 1,
          ready: true,
        ),
      );
      final elapsed = DateTime.now().difference(startedAt);
      routingLog.info(
        '── Import pipeline success ── region=$regionName '
        'elapsed=${elapsed.inSeconds}s sourceUrl=$url',
      );
    } on Object catch (error, stackTrace) {
      if (_cancelRequested) {
        routingLog.warning('Import ended after cancel', error, stackTrace);
        return;
      }
      routingLog.severe(
        '── Import pipeline FAILED ── region=$regionName url=$url',
        error,
        stackTrace,
      );
      await statusStore.update(
        RoutingStatusSnapshot(
          status: RoutingStatus.failed,
          message: 'Import failed ($regionName).',
          sourceUrl: url,
          regionId: regionId,
          regionName: regionName,
          ready: false,
          error: _friendlyImportError(error),
        ),
      );
    } finally {
      _importInProgress = false;
      _cancelRequested = false;
      _forceRedownload = false;
      _downloadClient?.close();
      _downloadClient = null;
      routingLog.info('Import pipeline finished (importInProgress=false)');
    }
  }

  Future<void> _runMultiRegionImport(
    List<String> regionIds,
    String mergeUrl,
  ) async {
    final startedAt = DateTime.now();
    final regionId = _activeRegionId;
    final regionName = _activeRegionName ?? combinedDisplayName(regionIds);
    routingLog.info(
      '── Multi-region import start ── region=$regionName '
      'regionId=$regionId url=$mergeUrl parts=${regionIds.length}',
    );
    try {
      routingLog.info('Phase: stop any running GraphHopper processes');
      await graphHopperProcess.stop();

      final reusePbf = !_forceRedownload && await hasReusablePbf(mergeUrl);
      if (reusePbf) {
        final size = await File(config.osmPbfPath).length();
        routingLog.info(
          'Phase: skip download/merge — reusing cached OSM PBF '
          '(${formatByteSize(size)}) for $mergeUrl',
        );
        await statusStore.update(
          RoutingStatusSnapshot(
            status: RoutingStatus.building,
            message:
                'Using cached merged extract for $regionName — '
                'building routing graph…',
            sourceUrl: mergeUrl,
            regionId: regionId,
            regionName: regionName,
            progress: null,
            ready: false,
          ),
        );
        await writeCachedSourceUrl(mergeUrl);
      } else {
        final partPaths = <String>[];
        for (var i = 0; i < regionIds.length; i++) {
          if (_cancelRequested) {
            return;
          }
          final id = regionIds[i];
          final region = regionById(id)!;
          final url = region.sourceUrl!;
          final partPath = '${config.osmPartsDir}/$id.osm.pbf';
          partPaths.add(partPath);

          await statusStore.update(
            RoutingStatusSnapshot(
              status: RoutingStatus.downloading,
              message:
                  'Downloading ${region.name} '
                  '(${i + 1}/${regionIds.length})…',
              sourceUrl: mergeUrl,
              regionId: regionId,
              regionName: regionName,
              progress: i / regionIds.length,
              ready: false,
            ),
          );
          routingLog.info(
            'Phase: download part ${i + 1}/${regionIds.length} '
            '${region.name} → $partPath',
          );
          await _downloadPbf(
            url,
            regionName: region.name,
            regionId: regionId,
            targetPath: partPath,
            writeSourceSidecar: false,
          );
        }

        if (_cancelRequested) {
          return;
        }

        await statusStore.update(
          RoutingStatusSnapshot(
            status: RoutingStatus.downloading,
            message: 'Merging ${regionIds.length} OSM extracts…',
            sourceUrl: mergeUrl,
            regionId: regionId,
            regionName: regionName,
            progress: 0.95,
            ready: false,
          ),
        );
        await _mergePbfsWithOsmium(partPaths, config.osmPbfPath);
        await writeCachedSourceUrl(mergeUrl);
      }

      if (_cancelRequested) {
        return;
      }

      await statusStore.update(
        RoutingStatusSnapshot(
          status: RoutingStatus.building,
          message: 'Building routing graph for $regionName…',
          sourceUrl: mergeUrl,
          regionId: regionId,
          regionName: regionName,
          progress: null,
          ready: false,
        ),
      );

      routingLog.info(
        'Phase: GraphHopper rebuild (clear cache + import + start)',
      );
      final buildStarted = DateTime.now();
      await graphHopperProcess.rebuild();
      routingLog.info(
        'Phase: GraphHopper rebuild complete '
        '(${DateTime.now().difference(buildStarted).inSeconds}s)',
      );

      if (_cancelRequested) {
        return;
      }

      await statusStore.update(
        RoutingStatusSnapshot(
          status: RoutingStatus.ready,
          message: 'Routing graph is ready ($regionName).',
          sourceUrl: mergeUrl,
          regionId: regionId,
          regionName: regionName,
          progress: 1,
          ready: true,
        ),
      );
      final elapsed = DateTime.now().difference(startedAt);
      routingLog.info(
        '── Multi-region import success ── region=$regionName '
        'elapsed=${elapsed.inSeconds}s sourceUrl=$mergeUrl',
      );
    } on Object catch (error, stackTrace) {
      if (_cancelRequested) {
        routingLog.warning(
          'Multi-region import ended after cancel',
          error,
          stackTrace,
        );
        return;
      }
      routingLog.severe(
        '── Multi-region import FAILED ── region=$regionName url=$mergeUrl',
        error,
        stackTrace,
      );
      await statusStore.update(
        RoutingStatusSnapshot(
          status: RoutingStatus.failed,
          message: 'Import failed ($regionName).',
          sourceUrl: mergeUrl,
          regionId: regionId,
          regionName: regionName,
          ready: false,
          error: _friendlyImportError(error),
        ),
      );
    } finally {
      _importInProgress = false;
      _cancelRequested = false;
      _forceRedownload = false;
      _downloadClient?.close();
      _downloadClient = null;
      routingLog.info(
        'Multi-region import pipeline finished (importInProgress=false)',
      );
    }
  }

  Future<void> _mergePbfsWithOsmium(
    List<String> partPaths,
    String outputPath,
  ) async {
    if (partPaths.length < 2) {
      throw ArgumentError('Need at least two PBF parts to merge');
    }
    for (final path in partPaths) {
      final file = File(path);
      if (!await file.exists() || await file.length() <= 0) {
        throw StateError('Missing OSM part for merge: $path');
      }
    }

    final out = File(outputPath);
    final temp = File('$outputPath.merge-partial');
    if (await temp.exists()) {
      await temp.delete();
    }

    final args = <String>[
      'merge',
      ...partPaths,
      '-o',
      temp.path,
      '--overwrite',
    ];
    routingLog.info(
      'Running Osmium merge: ${config.osmiumBin} ${args.join(' ')}',
    );
    final result = await Process.run(config.osmiumBin, args, runInShell: false);
    final combined = '${result.stdout}${result.stderr}'.trim();
    if (combined.isNotEmpty) {
      for (final line in const LineSplitter().convert(combined)) {
        if (line.trim().isNotEmpty) {
          routingLog.info('[osmium] $line');
        }
      }
    }
    if (result.exitCode != 0) {
      throw StateError(
        'Osmium merge failed with exit code ${result.exitCode}. '
        'Is osmium-tool installed? Output: $combined',
      );
    }
    if (!await temp.exists() || await temp.length() <= 0) {
      throw StateError('Osmium merge produced an empty output');
    }
    if (await out.exists()) {
      await out.delete();
    }
    await temp.rename(out.path);
    final size = await out.length();
    routingLog.info(
      'Merged OSM PBF written to ${out.path} (${formatByteSize(size)})',
    );
  }

  Future<void> _downloadPbf(
    String url, {
    required String regionName,
    String? regionId,
    String? targetPath,
    bool writeSourceSidecar = true,
  }) async {
    final dir = Directory(config.dataDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
      routingLog.info('Created data directory ${config.dataDir}');
    }

    final target = File(targetPath ?? config.osmPbfPath);
    await target.parent.create(recursive: true);
    final temp = File('${target.path}.partial');

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
              message: _downloadMessage(regionName, percent: percent),
              sourceUrl: url,
              regionId: regionId,
              regionName: regionName,
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
                'Download progress ($regionName): $percent% '
                '(${formatByteSize(receivedBytes)} / '
                '${formatByteSize(totalBytes)})',
              );
            } else {
              routingLog.info(
                'Download progress ($regionName): '
                '${formatByteSize(receivedBytes)} received',
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
    if (writeSourceSidecar) {
      await writeCachedSourceUrl(url);
    }
    final size = await target.length();
    routingLog.info(
      'OSM PBF saved to ${target.path} (${formatByteSize(size)})',
    );
  }

  /// Whether [url] already has a complete on-disk PBF we can rebuild from.
  Future<bool> hasReusablePbf(String url) async {
    final target = File(config.osmPbfPath);
    if (!await target.exists()) {
      return false;
    }
    if (await target.length() <= 0) {
      return false;
    }

    final normalized = url.trim();
    if (normalized.startsWith('local://') ||
        normalized.startsWith('merge://')) {
      return true;
    }

    final recorded = await readCachedSourceUrl();
    if (recorded != null && recorded.trim() == normalized) {
      return true;
    }

    // Volumes created before the sidecar: trust status.json if URL matches.
    final statusUrl = statusStore.current.sourceUrl?.trim();
    if (statusUrl != null && statusUrl == normalized) {
      return true;
    }
    return false;
  }

  Future<String?> readCachedSourceUrl() async {
    final file = File(config.osmSourceUrlPath);
    if (!await file.exists()) {
      return null;
    }
    try {
      final value = (await file.readAsString()).trim();
      return value.isEmpty ? null : value;
    } on Object {
      return null;
    }
  }

  Future<void> writeCachedSourceUrl(String url) async {
    final file = File(config.osmSourceUrlPath);
    await file.parent.create(recursive: true);
    await file.writeAsString('${url.trim()}\n');
  }

  String _downloadMessage(String regionName, {int? percent}) {
    if (percent == null) {
      return 'Downloading OSM extract: $regionName…';
    }
    return 'Downloading OSM extract: $regionName… $percent%';
  }

  String _friendlyImportError(Object error) {
    final raw = error.toString();
    final lower = raw.toLowerCase();
    if (lower.contains('outofmemoryerror') ||
        lower.contains('java heap space')) {
      return '$raw\n\n'
          'Java ran out of heap while building the graph. '
          'The OSM extract is already on disk — raise JAVA_XMX in the '
          'routing-server .env (e.g. 8g→16g for the entire United States; '
          'graph storage uses MMAP so the full graph need not fit in heap), '
          'then docker compose up -d --force-recreate. '
          'The server will resume building without re-downloading.';
    }
    if (_isSigkillExit(raw)) {
      return '$raw\n\n'
          'GraphHopper was killed by the OS (SIGKILL / exit -9 or 137). '
          'This is usually the Linux or Docker out-of-memory killer when '
          'JAVA_XMX is larger than free host RAM, or the container memory '
          'limit is too low. '
          'Check free memory on the host (`free -h` / Docker Desktop Resources), '
          'set JAVA_XMX below ~50% of host RAM (e.g. 8g on a 16–32 GB host), '
          'recreate the container, and re-run the build. '
          'The OSM extract on disk is reused; no re-download is needed.';
    }
    return raw;
  }

  /// Dart reports SIGKILL as exit code -9; some environments use 128+9 = 137.
  bool _isSigkillExit(String raw) {
    final lower = raw.toLowerCase();
    if (!lower.contains('exit code')) {
      return false;
    }
    return RegExp(r'exit code (-9|137)\b').hasMatch(lower);
  }

  void dispose() {
    _http.close();
  }
}

class LocalOsmInventory {
  const LocalOsmInventory({required this.present, required this.bytes});

  final bool present;
  final int bytes;
}

class LocalOsmInstallResult {
  const LocalOsmInstallResult({
    required this.bytes,
    required this.path,
    required this.sourceUrl,
    required this.buildStarted,
  });

  final int bytes;
  final String path;
  final String sourceUrl;
  final bool buildStarted;
}
