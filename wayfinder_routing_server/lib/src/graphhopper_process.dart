import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
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

  bool get isReady => _ready;

  bool get isRunning => _serverProcess != null;

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

    final args = [
      ...config.javaVmArgs(),
      ...config.graphHopperSystemProperties(),
      '-jar',
      config.graphHopperJar,
      'server',
      config.configYmlPath,
    ];

    routingLog.info(
      'Starting GraphHopper server: ${config.javaBin} ${args.join(' ')}',
    );
    _serverProcess = await Process.start(config.javaBin, args);
    _attachProcessLogs(
      label: 'graphhopper-server',
      process: _serverProcess!,
      onStdout: (sub) => _serverStdoutSub = sub,
      onStderr: (sub) => _serverStderrSub = sub,
    );

    routingLog.info('Waiting for GraphHopper /health…');
    _ready = await _waitForGraphHopperReady();
    if (!_ready) {
      await stop();
      throw StateError('GraphHopper server did not become ready');
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
    await _stopImport();
  }

  Future<void> rebuild() async {
    routingLog.info('Rebuilding GraphHopper graph…');
    await stop();
    await _runImport();
    await start();
    routingLog.info('GraphHopper rebuild complete');
  }

  Future<void> _runImport() async {
    await _stopImport();

    final args = [
      ...config.javaVmArgs(),
      ...config.graphHopperSystemProperties(),
      '-jar',
      config.graphHopperJar,
      'import',
      config.configYmlPath,
    ];

    routingLog.info(
      'Running GraphHopper import: ${config.javaBin} ${args.join(' ')}',
    );
    _importProcess = await Process.start(config.javaBin, args);
    _attachProcessLogs(
      label: 'graphhopper-import',
      process: _importProcess!,
      onStdout: (sub) => _importStdoutSub = sub,
      onStderr: (sub) => _importStderrSub = sub,
    );
    final exitCode = await _importProcess!.exitCode;
    await _cancelSubs([_importStdoutSub, _importStderrSub]);
    _importStdoutSub = null;
    _importStderrSub = null;
    _importProcess = null;
    if (exitCode != 0) {
      throw StateError('GraphHopper import failed with exit code $exitCode');
    }
    routingLog.info('GraphHopper import finished successfully');
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

  void _attachProcessLogs({
    required String label,
    required Process process,
    required void Function(StreamSubscription<String>) onStdout,
    required void Function(StreamSubscription<String>) onStderr,
  }) {
    onStdout(
      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            if (line.trim().isEmpty) {
              return;
            }
            routingLog.info('[$label] $line');
          }),
    );
    onStderr(
      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            if (line.trim().isEmpty) {
              return;
            }
            routingLog.warning('[$label] $line');
          }),
    );
  }

  Future<void> _cancelSubs(List<StreamSubscription<String>?> subs) async {
    for (final sub in subs) {
      await sub?.cancel();
    }
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
        routingLog.fine(
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
