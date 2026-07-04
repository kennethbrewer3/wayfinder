import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';

import '../core/endpoint_logging.dart';
import '../generated/protocol.dart';
import 'map_data_backup_archive.dart';
import 'map_data_service.dart';
import 'map_marker_change_broadcast.dart';
import '../layers/map_layer_change_broadcast.dart';

class MapDataEndpoint extends Endpoint with EndpointLogging {
  static const _tag = 'mapData';

  Future<String> exportMapData(Session session) {
    return loggedCall(
      session,
      _tag,
      'exportMapData',
      () async {
        final data = await exportMapDataBundle(session);
        return jsonEncode(data);
      },
      onSuccess: (json) => 'bytes=${json.length}',
    );
  }

  Future<MapDataRestoreSummary> restoreMapData(
    Session session,
    String backupJson,
  ) {
    return loggedCall(
      session,
      _tag,
      'restoreMapData',
      () async {
        final decoded = jsonDecode(backupJson);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Backup must be a JSON object');
        }
        final counts = await restoreMapDataBundle(session, decoded);
        await MapLayerChangeBroadcast.bulk(session);
        await MapMarkerChangeBroadcast.bulk(session);
        return MapDataRestoreSummary(
          layers: counts.layers,
          markers: counts.markers,
          zones: counts.zones,
          markerIconCategories: counts.markerIconCategories,
          markerIcons: counts.markerIcons,
        );
      },
      onSuccess: (summary) =>
          'layers=${summary.layers} markers=${summary.markers} zones=${summary.zones} '
          'markerIconCategories=${summary.markerIconCategories} markerIcons=${summary.markerIcons}',
    );
  }

  Future<ByteData> exportMapDataArchive(Session session) {
    return loggedCall(
      session,
      _tag,
      'exportMapDataArchive',
      () async {
        final bytes = await buildMapDataBackupArchive(session);
        return ByteData.sublistView(bytes);
      },
      onSuccess: (archive) => 'bytes=${archive.lengthInBytes}',
    );
  }

  Future<MapDataRestoreSummary> restoreMapDataArchive(
    Session session,
    ByteData archiveBytes,
  ) {
    return loggedCall(
      session,
      _tag,
      'restoreMapDataArchive',
      () async {
        final bytes = archiveBytes.buffer.asUint8List(
          archiveBytes.offsetInBytes,
          archiveBytes.lengthInBytes,
        );
        final counts = await restoreMapDataFromArchive(session, bytes);
        await MapLayerChangeBroadcast.bulk(session);
        await MapMarkerChangeBroadcast.bulk(session);
        return MapDataRestoreSummary(
          layers: counts.layers,
          markers: counts.markers,
          zones: counts.zones,
          markerIconCategories: counts.markerIconCategories,
          markerIcons: counts.markerIcons,
        );
      },
      onSuccess: (summary) =>
          'layers=${summary.layers} markers=${summary.markers} zones=${summary.zones} '
          'markerIconCategories=${summary.markerIconCategories} markerIcons=${summary.markerIcons}',
    );
  }
}
