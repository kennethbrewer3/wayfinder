import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/app_globals.dart';

bool isLayersEndpointUnavailable(Object error) {
  final text = error.toString().toLowerCase();
  return text.contains('serverpodclientnotfound') ||
      text.contains('statuscode = 404') ||
      text.contains('method not found') ||
      text.contains('endpoint not found') ||
      text.contains('relation "map_layer" does not exist') ||
      text.contains('no such table: map_layer') ||
      text.contains('get /api/layers returned 404') ||
      (text.contains('not found') && text.contains('layer'));
}

/// Loads layers from the server (RPC, with REST fallback).
Future<List<MapLayer>> fetchMapLayers(Client client) async {
  try {
    return await client.mapLayer.listLayers();
  } on Object catch (rpcError) {
    if (!isLayersEndpointUnavailable(rpcError)) {
      rethrow;
    }
  }

  return _fetchLayersViaRest();
}

Future<List<MapLayer>> _fetchLayersViaRest() async {
  final base = appServerConfig.webUrl.replaceAll(RegExp(r'/$'), '');
  final response = await http.get(Uri.parse('$base/api/layers'));
  if (response.statusCode == 404) {
    throw Exception('GET /api/layers returned 404');
  }
  if (response.statusCode != 200) {
    throw Exception(
      'GET /api/layers failed: ${response.statusCode} ${response.body}',
    );
  }

  final decoded = jsonDecode(response.body);
  if (decoded is! List) {
    throw FormatException('Expected JSON array from /api/layers');
  }

  return [
    for (final entry in decoded)
      if (entry is Map<String, dynamic>) MapLayer.fromJson(entry),
  ];
}

String layersLoadErrorMessage(Object error) {
  final text = error.toString();

  if (text.contains('relation "map_layer" does not exist') ||
      text.contains('no such table: map_layer')) {
    return 'The map layers database table is missing. '
        'Restart the Wayfinder server with migrations applied:\n'
        'cd wayfinder_server && dart run bin/main.dart --apply-migrations';
  }

  if (isLayersEndpointUnavailable(error)) {
    return 'Restart the Wayfinder server from the latest code, then run:\n'
        'cd wayfinder_server && dart run bin/main.dart --apply-migrations';
  }

  return 'Something went wrong while loading layers. Please try again.';
}
