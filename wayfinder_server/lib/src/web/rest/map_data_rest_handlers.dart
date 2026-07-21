import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';

import '../../map/map_data_backup_archive.dart';
import '../../map/map_data_service.dart';
import '../../map/map_marker_change_broadcast.dart';
import '../../layers/map_layer_change_broadcast.dart';
import '../../seasonal_overlays/seasonal_overlay_change_broadcast.dart';
import '../../watch_log/watch_log_entry_change_broadcast.dart';
import '../../zones/map_zone_change_broadcast.dart';
import 'rest_json.dart';

abstract final class MapDataRestHandlers {
  static Future<Result> export(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final payload = await exportMapDataBundle(session);
      return RestJson.ok(payload);
    });
  }

  static Future<Result> exportArchive(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final bytes = await buildMapDataBackupArchive(session);
      return Response.ok(
        body: Body.fromData(
          bytes,
          mimeType: MimeType.parse('application/zip'),
        ),
      );
    });
  }

  static Future<Result> restore(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final body = await RestJson.readObject(request);
      final summary = await restoreMapDataBundle(session, body);
      await MapLayerChangeBroadcast.bulk(session);
      await MapMarkerChangeBroadcast.bulk(session);
      await MapZoneChangeBroadcast.bulk(session);
      await SeasonalOverlayChangeBroadcast.bulk(session);
      await WatchLogEntryChangeBroadcast.bulk(session);
      return RestJson.ok({
        'restored': summary.toJson(),
      });
    });
  }

  static Future<Result> restoreArchive(Request request) async {
    return RestJson.handleErrors(() async {
      final session = await request.session;
      final bytes = await _readRequestBytes(request);
      final summary = await restoreMapDataFromArchive(session, bytes);
      await MapLayerChangeBroadcast.bulk(session);
      await MapMarkerChangeBroadcast.bulk(session);
      await MapZoneChangeBroadcast.bulk(session);
      await SeasonalOverlayChangeBroadcast.bulk(session);
      await WatchLogEntryChangeBroadcast.bulk(session);
      return RestJson.ok({
        'restored': summary.toJson(),
      });
    });
  }

  static Future<Uint8List> _readRequestBytes(Request request) async {
    final chunks = await request.read().fold<List<int>>(
      <int>[],
      (previous, chunk) => previous..addAll(chunk),
    );
    return Uint8List.fromList(chunks);
  }
}
