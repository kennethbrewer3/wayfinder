import 'dart:io';

import 'package:path/path.dart' as p;

/// Runtime configuration from environment variables and CLI overrides.
class RoutingConfig {
  RoutingConfig({
    required this.port,
    required this.dataDir,
    required this.graphHopperUrl,
    required this.graphHopperJar,
    required this.javaBin,
    required this.javaXmx,
    required this.configYmlPath,
  });

  final int port;
  final String dataDir;
  final String graphHopperUrl;
  final String graphHopperJar;
  final String javaBin;
  final String javaXmx;
  final String configYmlPath;

  String get statusFilePath => p.join(dataDir, 'status.json');

  String get osmPbfPath => p.join(dataDir, 'osm.pbf');

  String get graphCachePath => p.join(dataDir, 'graph-cache');

  factory RoutingConfig.fromEnvironment({int? portOverride}) {
    final dataDir = Platform.environment['DATA_DIR'] ?? '/data';
    final configYml =
        Platform.environment['GRAPHHOPPER_CONFIG'] ??
        p.join(Directory.current.path, 'config', 'config.yml');

    return RoutingConfig(
      port: portOverride ?? int.parse(Platform.environment['PORT'] ?? '18382'),
      dataDir: dataDir,
      graphHopperUrl:
          Platform.environment['GRAPHHOPPER_URL'] ?? 'http://127.0.0.1:8989',
      graphHopperJar:
          Platform.environment['GRAPHHOPPER_JAR'] ?? '/app/graphhopper-web.jar',
      javaBin: Platform.environment['JAVA_BIN'] ?? 'java',
      javaXmx: Platform.environment['JAVA_XMX'] ?? '2g',
      configYmlPath: configYml,
    );
  }

  List<String> javaVmArgs() => ['-Xmx$javaXmx'];

  List<String> graphHopperSystemProperties() => [
    '-Ddw.graphhopper.datareader.file=$osmPbfPath',
    '-Ddw.graphhopper.graph.location=$graphCachePath',
  ];
}
