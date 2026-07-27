import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:wayfinder_routing_server/routing_server.dart';

Future<void> main(List<String> arguments) async {
  configureRoutingLogging();

  final parser = ArgParser()..addOption('port', defaultsTo: '18382');
  final results = parser.parse(arguments);
  final port = int.parse(results['port'] as String);

  final config = RoutingConfig.fromEnvironment(portOverride: port);
  routingLog.info(
    'Starting routing server '
    '(port=${config.port}, dataDir=${config.dataDir}, '
    'javaXmx=${config.javaXmx}, graphHopperUrl=${config.graphHopperUrl}, '
    'jar=${config.graphHopperJar}, config=${config.configYmlPath})',
  );

  final statusStore = StatusStore(config);
  await statusStore.load();
  final loaded = statusStore.current;
  routingLog.info(
    'Loaded status: ${loaded.status.name} '
    '(ready=${loaded.ready}, sourceUrl=${loaded.sourceUrl ?? 'none'})',
  );

  final graphHopperProcess = GraphHopperProcess(config);
  final importService = ImportService(
    config: config,
    statusStore: statusStore,
    graphHopperProcess: graphHopperProcess,
  );
  final graphHopperClient = GraphHopperClient(config);

  final cacheExists = await graphHopperProcess.graphCacheExists();
  final pbfExists = await File(config.osmPbfPath).exists();
  routingLog.info(
    'Data check: osmPbf=$pbfExists graphCache=$cacheExists',
  );

  if (loaded.ready && cacheExists) {
    try {
      routingLog.info('Graph marked ready — starting GraphHopper…');
      await graphHopperProcess.start();
      routingLog.info('GraphHopper is up');
    } on Object catch (error, stackTrace) {
      routingLog.severe(
        'Failed to start GraphHopper on startup',
        error,
        stackTrace,
      );
    }
  } else if (loaded.ready && !cacheExists) {
    routingLog.warning(
      'Status says ready but graph cache is missing; '
      're-import required before routing works',
    );
  } else {
    routingLog.info(
      'No ready graph yet — import a region before routing requests succeed',
    );
  }

  final handler = Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(
        logRequests(
          logger: (message, isError) {
            if (isError) {
              routingLog.warning(message);
            } else {
              routingLog.fine(message);
            }
          },
        ),
      )
      .addHandler(
        createRestHandler(
          statusStore: statusStore,
          importService: importService,
          graphHopperProcess: graphHopperProcess,
          graphHopperClient: graphHopperClient,
        ),
      );

  final server = await io.serve(handler, InternetAddress.anyIPv4, config.port);
  routingLog.info(
    'Listening on http://${server.address.host}:${server.port} '
    '(LOG_LEVEL=${Logger.root.level.name})',
  );
}
