import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:wayfinder_routing_server/src/config.dart';
import 'package:wayfinder_routing_server/src/routing_log.dart';

/// Manages the GraphHopper Java child process (import + server).
class GraphHopperProcess {
  GraphHopperProcess(this.config, {http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  final RoutingConfig config;
  final http.Client _http;

  Process? _serverProcess;
  Process? _importProcess;
  bool _ready = false;
  StreamSubscription<String>? _serverStdoutSub;
  StreamSubscription<String>? _serverStderrSub;
  StreamSubscription<String>? _importStdoutSub;
  StreamSubscription<String>? _importStderrSub;
  IOSink? _serverLogSink;

  bool get isReady => _ready;

  bool get isRunning => _serverProcess != null;

  String get importLogPath => p.join(config.dataDir, 'graphhopper-import.log');

  String get serverLogPath => p.join(config.dataDir, 'graphhopper-server.log');

  Future<bool> graphCacheExists() async {
    final dir = Directory(config.graphCachePath);
    if (!await dir.exists()) {
      return false;
    }
    await for (final _ in dir.list(followLinks: false)) {
      return true;
    }
    return false;
  }

  /// One-shot environment diagnostics for operators (`docker compose logs`).
  Future<void> logEnvironmentDiagnostics({String reason = 'startup'}) async {
    routingLog.info('── GraphHopper environment ($reason) ──');
    routingLog.info('javaBin=${config.javaBin}');
    routingLog.info('javaXmx=${config.javaXmx}');
    routingLog.info('jar=${config.graphHopperJar}');
    routingLog.info('config=${config.configYmlPath}');
    routingLog.info('dataDir=${config.dataDir}');
    routingLog.info('osmPbf=${config.osmPbfPath}');
    routingLog.info('graphCache=${config.graphCachePath}');
    routingLog.info('graphHopperUrl=${config.graphHopperUrl}');
    routingLog.info('importLog=$importLogPath');

    await _logJavaVersion();
    await _logPathDetails('jar', config.graphHopperJar);
    await _logPathDetails('config', config.configYmlPath);
    await _logPathDetails('dataDir', config.dataDir, isDirectory: true);
    await _logPathDetails('osmPbf', config.osmPbfPath);
    await _logPathDetails(
      'graphCache',
      config.graphCachePath,
      isDirectory: true,
    );
    await _logConfigSnippet();
    routingLog.info('── end environment ($reason) ──');
  }

  Future<void> start() async {
    if (_serverProcess != null) {
      routingLog.info('GraphHopper server already running');
      return;
    }
    if (!await File(config.osmPbfPath).exists()) {
      throw StateError('OSM PBF not found at ${config.osmPbfPath}');
    }
    if (!await graphCacheExists()) {
      throw StateError('Graph cache not found at ${config.graphCachePath}');
    }

    final workDir = Directory(config.configYmlPath).parent.path;
    final args = [
      ...config.javaVmArgs(),
      ...config.graphHopperSystemProperties(),
      '-jar',
      config.graphHopperJar,
      'server',
      config.configYmlPath,
    ];

    routingLog.info(
      'Starting GraphHopper server '
      '(cwd=$workDir): ${config.javaBin} ${args.join(' ')}',
    );
    final recentLines = <String>[];
    await _serverLogSink?.flush();
    await _serverLogSink?.close();
    _serverLogSink = await _openLogFile(serverLogPath);
    _serverProcess = await Process.start(
      config.javaBin,
      args,
      workingDirectory: workDir,
    );
    routingLog.info('GraphHopper server pid=${_serverProcess!.pid}');
    unawaited(
      _attachProcessLogs(
        label: 'graphhopper-server',
        process: _serverProcess!,
        recentLines: recentLines,
        logSink: _serverLogSink,
        onStdout: (sub) => _serverStdoutSub = sub,
        onStderr: (sub) => _serverStderrSub = sub,
      ),
    );

    routingLog.info('Waiting for GraphHopper /health…');
    _ready = await _waitForGraphHopperReady();
    if (!_ready) {
      routingLog.severe(
        'GraphHopper server failed to become ready. '
        'Recent output:\n${_formatTail(recentLines)}',
      );
      await stop();
      throw StateError(
        'GraphHopper server did not become ready. '
        'See $serverLogPath and container logs.',
      );
    }
    routingLog.info('GraphHopper /health OK');
  }

  Future<void> stop() async {
    _ready = false;
    final server = _serverProcess;
    _serverProcess = null;
    if (server != null) {
      routingLog.info('Stopping GraphHopper server (pid=${server.pid})…');
      await _cancelSubs([_serverStdoutSub, _serverStderrSub]);
      _serverStdoutSub = null;
      _serverStderrSub = null;
      server.kill(ProcessSignal.sigterm);
      final exitCode = await server.exitCode.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          routingLog.warning(
            'GraphHopper server did not exit; sending SIGKILL',
          );
          server.kill(ProcessSignal.sigkill);
          return server.exitCode;
        },
      );
      routingLog.info('GraphHopper server stopped (exitCode=$exitCode)');
    }
    await _serverLogSink?.flush();
    await _serverLogSink?.close();
    _serverLogSink = null;
    await _stopImport();
  }

  Future<void> rebuild() async {
    routingLog.info('Rebuilding GraphHopper graph…');
    await stop();
    await _clearGraphCache();
    await _runImport();
    await start();
    routingLog.info('GraphHopper rebuild complete');
  }

  Future<void> _clearGraphCache() async {
    final dir = Directory(config.graphCachePath);
    if (!await dir.exists()) {
      routingLog.info(
        'Graph cache not present at ${config.graphCachePath} (nothing to clear)',
      );
      return;
    }
    routingLog.info('Clearing graph cache at ${config.graphCachePath}');
    await dir.delete(recursive: true);
    routingLog.info('Graph cache cleared');
  }

  Future<void> _runImport() async {
    await _stopImport();
    await logEnvironmentDiagnostics(reason: 'pre-import');

    final pbf = File(config.osmPbfPath);
    if (!await pbf.exists()) {
      throw StateError('OSM PBF missing before import: ${config.osmPbfPath}');
    }
    final pbfBytes = await pbf.length();
    routingLog.info(
      'OSM PBF ready for import: ${config.osmPbfPath} '
      '(${formatByteSize(pbfBytes)})',
    );

    final jar = File(config.graphHopperJar);
    if (!await jar.exists()) {
      throw StateError('GraphHopper JAR missing: ${config.graphHopperJar}');
    }
    final configFile = File(config.configYmlPath);
    if (!await configFile.exists()) {
      throw StateError('GraphHopper config missing: ${config.configYmlPath}');
    }

    final workDir = Directory(config.configYmlPath).parent.path;
    final args = [
      ...config.javaVmArgs(),
      ...config.graphHopperSystemProperties(),
      '-jar',
      config.graphHopperJar,
      'import',
      config.configYmlPath,
    ];

    routingLog.info(
      'Running GraphHopper import (cwd=$workDir): '
      '${config.javaBin} ${args.join(' ')}',
    );

    final recentLines = <String>[];
    final logFile = await _openLogFile(importLogPath);
    final startedAt = DateTime.now();
    try {
      _importProcess = await Process.start(
        config.javaBin,
        args,
        workingDirectory: workDir,
      );
      routingLog.info('GraphHopper import pid=${_importProcess!.pid}');
      final streamsDone = _attachProcessLogs(
        label: 'graphhopper-import',
        process: _importProcess!,
        recentLines: recentLines,
        logSink: logFile,
        onStdout: (sub) => _importStdoutSub = sub,
        onStderr: (sub) => _importStderrSub = sub,
      );

      final exitCode = await _importProcess!.exitCode;
      await _awaitStreams(streamsDone);
      await _cancelSubs([_importStdoutSub, _importStderrSub]);
      _importStdoutSub = null;
      _importStderrSub = null;
      _importProcess = null;

      final elapsed = DateTime.now().difference(startedAt);
      routingLog.info(
        'GraphHopper import process exited '
        '(exitCode=$exitCode, elapsed=${elapsed.inSeconds}s, '
        'capturedLines=${recentLines.length})',
      );

      if (exitCode != 0) {
        final tail = _formatTail(recentLines, maxLines: 80);
        routingLog.severe(
          'GraphHopper import FAILED (exitCode=$exitCode). '
          'Full log: $importLogPath\n$tail',
        );
        throw StateError(
          'GraphHopper import failed with exit code $exitCode. '
          'See $importLogPath. Last output:\n$tail',
        );
      }
      if (recentLines.isEmpty) {
        routingLog.warning(
          'GraphHopper import exited 0 but produced no captured output '
          '(check $importLogPath)',
        );
      }
      routingLog.info(
        'GraphHopper import finished successfully '
        '(elapsed=${elapsed.inSeconds}s, log=$importLogPath)',
      );
    } finally {
      await logFile.flush();
      await logFile.close();
    }
  }

  Future<void> _stopImport() async {
    final import = _importProcess;
    _importProcess = null;
    if (import != null) {
      routingLog.info('Stopping GraphHopper import (pid=${import.pid})…');
      await _cancelSubs([_importStdoutSub, _importStderrSub]);
      _importStdoutSub = null;
      _importStderrSub = null;
      import.kill(ProcessSignal.sigterm);
      final exitCode = await import.exitCode.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          routingLog.warning(
            'GraphHopper import did not exit; sending SIGKILL',
          );
          import.kill(ProcessSignal.sigkill);
          return import.exitCode;
        },
      );
      routingLog.info('GraphHopper import stopped (exitCode=$exitCode)');
    }
  }

  /// Returns a future that completes when both stdout and stderr are done.
  Future<void> _attachProcessLogs({
    required String label,
    required Process process,
    required void Function(StreamSubscription<String>) onStdout,
    required void Function(StreamSubscription<String>) onStderr,
    List<String>? recentLines,
    IOSink? logSink,
  }) {
    final stdoutDone = Completer<void>();
    final stderrDone = Completer<void>();

    void handleLine(String line) {
      final trimmed = line.trimRight();
      if (trimmed.isEmpty) {
        return;
      }
      recentLines?.add(trimmed);
      const maxRecent = 200;
      if (recentLines != null && recentLines.length > maxRecent) {
        recentLines.removeRange(0, recentLines.length - maxRecent);
      }
      logSink?.writeln(trimmed);
      // GraphHopper writes almost everything through Dropwizard to stderr;
      // keep both streams visible at INFO so `docker compose logs` shows them.
      routingLog.info('[$label] $trimmed');
    }

    onStdout(
      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            handleLine,
            onDone: () {
              if (!stdoutDone.isCompleted) {
                stdoutDone.complete();
              }
            },
            onError: (Object error, StackTrace stackTrace) {
              routingLog.warning(
                '[$label] stdout stream error',
                error,
                stackTrace,
              );
              if (!stdoutDone.isCompleted) {
                stdoutDone.complete();
              }
            },
            cancelOnError: false,
          ),
    );
    onStderr(
      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            handleLine,
            onDone: () {
              if (!stderrDone.isCompleted) {
                stderrDone.complete();
              }
            },
            onError: (Object error, StackTrace stackTrace) {
              routingLog.warning(
                '[$label] stderr stream error',
                error,
                stackTrace,
              );
              if (!stderrDone.isCompleted) {
                stderrDone.complete();
              }
            },
            cancelOnError: false,
          ),
    );

    return Future.wait<void>([stdoutDone.future, stderrDone.future]);
  }

  Future<void> _awaitStreams(Future<void> streamsDone) async {
    try {
      await streamsDone.timeout(const Duration(seconds: 5));
    } on TimeoutException {
      routingLog.warning(
        'Timed out waiting for GraphHopper stdout/stderr to finish draining',
      );
    }
  }

  Future<void> _cancelSubs(List<StreamSubscription<String>?> subs) async {
    for (final sub in subs) {
      await sub?.cancel();
    }
  }

  Future<IOSink> _openLogFile(String path) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    final sink = file.openWrite(mode: FileMode.writeOnly);
    sink.writeln(
      '# GraphHopper log started ${DateTime.now().toUtc().toIso8601String()}',
    );
    return sink;
  }

  Future<void> _logJavaVersion() async {
    try {
      final result = await Process.run(config.javaBin, [
        '-version',
      ], runInShell: false);
      final combined = '${result.stdout}${result.stderr}'.trim();
      for (final line in const LineSplitter().convert(combined)) {
        if (line.trim().isNotEmpty) {
          routingLog.info('[java] $line');
        }
      }
      if (result.exitCode != 0) {
        routingLog.warning('java -version exited ${result.exitCode}');
      }
    } on Object catch (error, stackTrace) {
      routingLog.severe('Failed to run java -version', error, stackTrace);
    }
  }

  Future<void> _logPathDetails(
    String label,
    String path, {
    bool isDirectory = false,
  }) async {
    try {
      if (isDirectory) {
        final dir = Directory(path);
        if (!await dir.exists()) {
          routingLog.info('[$label] missing directory: $path');
          return;
        }
        var entries = 0;
        await for (final _ in dir.list(followLinks: false)) {
          entries++;
          if (entries >= 20) {
            break;
          }
        }
        routingLog.info(
          '[$label] directory exists: $path (sampleEntries=$entries)',
        );
        return;
      }
      final file = File(path);
      if (!await file.exists()) {
        routingLog.info('[$label] missing file: $path');
        return;
      }
      final bytes = await file.length();
      routingLog.info(
        '[$label] exists: $path (${formatByteSize(bytes)})',
      );
    } on Object catch (error) {
      routingLog.warning('[$label] could not stat $path: $error');
    }
  }

  Future<void> _logConfigSnippet() async {
    try {
      final file = File(config.configYmlPath);
      if (!await file.exists()) {
        return;
      }
      final lines = await file.readAsLines();
      routingLog.info(
        'Config ${config.configYmlPath} (${lines.length} lines):',
      );
      for (final line in lines.take(60)) {
        routingLog.info('  | $line');
      }
      if (lines.length > 60) {
        routingLog.info('  | … (${lines.length - 60} more lines)');
      }
    } on Object catch (error) {
      routingLog.warning('Could not read config snippet: $error');
    }
  }

  String _formatTail(List<String> lines, {int maxLines = 40}) {
    if (lines.isEmpty) {
      return '(no output captured)';
    }
    final start = lines.length > maxLines ? lines.length - maxLines : 0;
    return lines.sublist(start).join('\n');
  }

  Future<bool> checkHealth() async {
    try {
      final response = await _http
          .get(Uri.parse('${config.graphHopperUrl}/health'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } on Object {
      return false;
    }
  }

  Future<bool> _waitForGraphHopperReady({
    Duration timeout = const Duration(minutes: 30),
  }) async {
    final deadline = DateTime.now().add(timeout);
    var attempts = 0;
    while (DateTime.now().isBefore(deadline)) {
      attempts++;
      if (await checkHealth()) {
        routingLog.info(
          'GraphHopper health check succeeded after $attempts attempts',
        );
        return true;
      }
      if (attempts == 1 || attempts % 15 == 0) {
        routingLog.info(
          'Still waiting for GraphHopper health '
          '(attempt=$attempts, elapsed≈${attempts * 2}s)…',
        );
      }
      await Future<void>.delayed(const Duration(seconds: 2));
    }
    routingLog.severe(
      'GraphHopper health check timed out after ${timeout.inMinutes} minutes '
      '($attempts attempts)',
    );
    return false;
  }

  Future<void> dispose() async {
    await stop();
    _http.close();
  }
}
