import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:wayfinder_routing_server/src/config.dart';

/// Manages the GraphHopper Java child process (import + server).
class GraphHopperProcess {
  GraphHopperProcess(this.config, {http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  final RoutingConfig config;
  final http.Client _http;

  Process? _serverProcess;
  Process? _importProcess;
  bool _ready = false;

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

    _serverProcess = await Process.start(config.javaBin, args);
    _ready = await _waitForGraphHopperReady();
    if (!_ready) {
      await stop();
      throw StateError('GraphHopper server did not become ready');
    }
  }

  Future<void> stop() async {
    _ready = false;
    final server = _serverProcess;
    _serverProcess = null;
    if (server != null) {
      server.kill(ProcessSignal.sigterm);
      await server.exitCode.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          server.kill(ProcessSignal.sigkill);
          return server.exitCode;
        },
      );
    }
    await _stopImport();
  }

  Future<void> rebuild() async {
    await stop();
    await _runImport();
    await start();
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

    _importProcess = await Process.start(config.javaBin, args);
    final exitCode = await _importProcess!.exitCode;
    _importProcess = null;
    if (exitCode != 0) {
      throw StateError('GraphHopper import failed with exit code $exitCode');
    }
  }

  Future<void> _stopImport() async {
    final import = _importProcess;
    _importProcess = null;
    if (import != null) {
      import.kill(ProcessSignal.sigterm);
      await import.exitCode.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          import.kill(ProcessSignal.sigkill);
          return import.exitCode;
        },
      );
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
    while (DateTime.now().isBefore(deadline)) {
      if (await checkHealth()) {
        return true;
      }
      await Future<void>.delayed(const Duration(seconds: 2));
    }
    return false;
  }

  Future<void> dispose() async {
    await stop();
    _http.close();
  }
}
