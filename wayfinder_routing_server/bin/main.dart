import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:wayfinder_routing_server/routing_server.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()..addOption('port', defaultsTo: '18382');
  final results = parser.parse(arguments);
  final port = int.parse(results['port'] as String);

  final config = RoutingConfig.fromEnvironment(portOverride: port);
  final statusStore = StatusStore(config);
  await statusStore.load();

  final graphHopperProcess = GraphHopperProcess(config);
  final importService = ImportService(
    config: config,
    statusStore: statusStore,
    graphHopperProcess: graphHopperProcess,
  );
  final graphHopperClient = GraphHopperClient(config);

  if (statusStore.current.ready &&
      await graphHopperProcess.graphCacheExists()) {
    try {
      await graphHopperProcess.start();
    } on Object catch (error) {
      stderr.writeln('Warning: failed to start GraphHopper on startup: $error');
    }
  }

  final handler = Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(logRequests())
      .addHandler(
        createRestHandler(
          statusStore: statusStore,
          importService: importService,
          graphHopperProcess: graphHopperProcess,
          graphHopperClient: graphHopperClient,
        ),
      );

  final server = await io.serve(handler, InternetAddress.anyIPv4, config.port);
  stdout.writeln(
    'Wayfinder routing server listening on http://${server.address.host}:${server.port}',
  );
}
