import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/serverpod_client.dart';
import '../../layers/providers/layers_provider.dart';
import '../../lines/providers/zones_provider.dart';
import '../../markers/providers/markers_provider.dart';
import '../../settings/providers/pmtiles_providers.dart';
import '../../tracks/models/track_geometry.dart';
import '../../watch_log/providers/watch_log_provider.dart';
import '../data/offline_pack_store.dart';
import '../data/offline_sync.dart';
import '../data/offline_tile_cache.dart';
import '../data/prepare_offline_pack.dart';
import '../models/offline_outbox.dart';
import '../models/offline_pack.dart';
import '../models/offline_snapshot.dart';
import 'offline_snapshot_provider.dart';
import 'server_reachability_provider.dart';

final offlinePackControllerProvider = Provider<OfflinePackController>((ref) {
  return OfflinePackController(ref);
});

class OfflinePackController {
  OfflinePackController(this._ref);

  final Ref _ref;
  static const _minTrackMoveMeters = 5.0;
  static const _distance = Distance();

  Future<OfflinePackMeta> prepare({
    required String name,
    required List<UuidValue> layerIds,
    required OfflinePackRegion region,
    OfflinePrepareProgress? onProgress,
  }) {
    return prepareOfflinePack(
      client: _ref.read(serverClientProvider),
      pmtilesRepository: _ref.read(pmtilesRepositoryProvider),
      store: _ref.read(offlinePackStoreProvider),
      tileCache: _ref.read(offlineTileCacheProvider),
      name: name,
      layerIds: layerIds,
      region: region,
      onProgress: onProgress,
    ).then((meta) async {
      _ref.invalidate(offlinePackMetaProvider);
      _ref.invalidate(offlineSnapshotProvider);
      return meta;
    });
  }

  Future<void> clearPack() async {
    await _ref.read(offlinePackStoreProvider).clearAll();
    await _ref.read(offlineTileCacheProvider).clear();
    _ref.invalidate(offlinePackMetaProvider);
    _ref.invalidate(offlineSnapshotProvider);
    _ref.invalidate(offlineOutboxCountProvider);
  }

  Future<void> enqueueMarker(MapMarker marker) async {
    final store = _ref.read(offlinePackStoreProvider);
    await store.enqueue(OfflineOutboxOp.createMarker(marker));
    final snapshot = await store.loadSnapshot();
    if (snapshot != null) {
      await store.saveSnapshot(
        OfflineSnapshot(
          layers: snapshot.layers,
          markers: [...snapshot.markers, marker],
          zones: snapshot.zones,
          watchLogEntries: snapshot.watchLogEntries,
          capturedAt: snapshot.capturedAt,
        ),
      );
      _ref.invalidate(offlineSnapshotProvider);
      _ref.invalidate(markersProvider);
    }
    _ref.invalidate(offlineOutboxCountProvider);
  }

  Future<void> enqueueWatchLog(WatchLogEntry entry) async {
    final store = _ref.read(offlinePackStoreProvider);
    await store.enqueue(OfflineOutboxOp.createWatchLogEntry(entry));
    final snapshot = await store.loadSnapshot();
    if (snapshot != null) {
      await store.saveSnapshot(
        OfflineSnapshot(
          layers: snapshot.layers,
          markers: snapshot.markers,
          zones: snapshot.zones,
          watchLogEntries: [...snapshot.watchLogEntries, entry],
          capturedAt: snapshot.capturedAt,
        ),
      );
      _ref.invalidate(offlineSnapshotProvider);
      _ref.invalidate(watchLogEntriesProvider);
    }
    _ref.invalidate(offlineOutboxCountProvider);
  }

  Future<void> enqueueTrackZone(MapZone zone) async {
    final store = _ref.read(offlinePackStoreProvider);
    await store.enqueue(OfflineOutboxOp.upsertTrackZone(zone));
    final snapshot = await store.loadSnapshot();
    if (snapshot != null) {
      final zones = [
        for (final existing in snapshot.zones)
          if (existing.id != zone.id) existing,
        zone,
      ];
      await store.saveSnapshot(
        OfflineSnapshot(
          layers: snapshot.layers,
          markers: snapshot.markers,
          zones: zones,
          watchLogEntries: snapshot.watchLogEntries,
          capturedAt: snapshot.capturedAt,
        ),
      );
      _ref.invalidate(offlineSnapshotProvider);
      _ref.invalidate(zonesProvider);
    }
    _ref.invalidate(offlineOutboxCountProvider);
  }

  /// Creates a tracking marker + track zone entirely on the client.
  Future<MapMarker> createTrackingMarkerOffline({
    required MapMarker marker,
  }) async {
    final now = DateTime.now().toUtc();
    final zoneId = const Uuid().v4obj();
    final geometry = TrackGeometry(
      markerId: marker.id,
      points: [
        TrackPoint(
          point: LatLng(marker.latitude, marker.longitude),
          recordedAt: now,
        ),
      ],
    );
    final zone = MapZone(
      id: zoneId,
      name: '${marker.name} track',
      type: trackZoneType,
      color: marker.color,
      borderColor: marker.color,
      borderPattern: 'solid',
      fillColor: marker.color,
      visible: true,
      geometryJson: geometry.encode(),
      layerId: marker.layerId,
      createdAt: now,
      updatedAt: now,
    );
    final trackingMarker = marker.copyWith(
      isTracking: true,
      trackZoneId: zoneId,
      updatedAt: now,
    );
    await enqueueTrackZone(zone);
    await enqueueMarker(trackingMarker);
    return trackingMarker;
  }

  /// Appends GPS points to every offline tracking marker that has moved enough.
  Future<void> appendGpsToTrackingMarkers(LatLng position) async {
    final store = _ref.read(offlinePackStoreProvider);
    final snapshot = await store.loadSnapshot();
    if (snapshot == null) {
      return;
    }

    var markers = snapshot.markers;
    var zones = snapshot.zones;
    var changed = false;

    for (final marker in snapshot.markers) {
      if (!marker.isTracking || marker.trackZoneId == null) {
        continue;
      }
      final moved = _distance.as(
        LengthUnit.Meter,
        LatLng(marker.latitude, marker.longitude),
        position,
      );
      if (moved < _minTrackMoveMeters) {
        continue;
      }

      final zoneIndex = zones.indexWhere((z) => z.id == marker.trackZoneId);
      if (zoneIndex < 0) {
        continue;
      }
      final zone = zones[zoneIndex];
      final geometry = TrackGeometry.fromZone(zone);
      if (geometry == null) {
        continue;
      }

      final now = DateTime.now().toUtc();
      final updatedGeometry = geometry.copyWith(
        points: [
          ...geometry.points,
          TrackPoint(point: position, recordedAt: now),
        ],
      );
      final updatedZone = zone.copyWith(
        geometryJson: updatedGeometry.encode(),
        updatedAt: now,
      );
      final updatedMarker = marker.copyWith(
        latitude: position.latitude,
        longitude: position.longitude,
        updatedAt: now,
      );

      zones = [
        for (var i = 0; i < zones.length; i++)
          if (i == zoneIndex) updatedZone else zones[i],
      ];
      markers = [
        for (final existing in markers)
          if (existing.id == marker.id) updatedMarker else existing,
      ];
      await store.enqueue(OfflineOutboxOp.upsertTrackZone(updatedZone));
      await store.enqueue(OfflineOutboxOp.updateMarker(updatedMarker));
      changed = true;
    }

    if (!changed) {
      return;
    }
    await store.saveSnapshot(
      OfflineSnapshot(
        layers: snapshot.layers,
        markers: markers,
        zones: zones,
        watchLogEntries: snapshot.watchLogEntries,
        capturedAt: snapshot.capturedAt,
      ),
    );
    _ref.invalidate(offlineSnapshotProvider);
    _ref.invalidate(markersProvider);
    _ref.invalidate(zonesProvider);
    _ref.invalidate(offlineOutboxCountProvider);
  }

  /// Call when the server becomes reachable again.
  Future<int> syncIfNeeded() async {
    final flushed = await flushOfflineOutbox(
      client: _ref.read(serverClientProvider),
      store: _ref.read(offlinePackStoreProvider),
    );
    if (flushed > 0) {
      _ref.invalidate(markersProvider);
      _ref.invalidate(layersProvider);
      _ref.invalidate(watchLogEntriesProvider);
      await _ref.read(zonesProvider.notifier).reload();
      _ref.invalidate(offlineOutboxCountProvider);
      _ref.invalidate(offlineSnapshotProvider);
    }
    return flushed;
  }
}
