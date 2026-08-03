import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../../../core/serverpod_client.dart';
import '../../layers/providers/layers_provider.dart';
import '../../lines/providers/zones_provider.dart';
import '../../markers/providers/markers_provider.dart';
import '../../seasonal_overlays/providers/seasonal_overlays_provider.dart';
import '../../settings/providers/pmtiles_providers.dart';
import '../../tracks/models/track_geometry.dart';
import '../../tracks/models/track_transportation_mode.dart';
import '../../watch_log/providers/watch_log_provider.dart';
import '../data/offline_pack_store.dart';
import '../data/offline_sync.dart';
import '../data/offline_tile_cache.dart';
import '../data/prepare_offline_pack.dart';
import '../models/offline_outbox.dart';
import '../models/offline_pack.dart';
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
    String? packId,
    bool includeSeasonalOverlays = false,
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
      packId: packId,
      includeSeasonalOverlays: includeSeasonalOverlays,
      onProgress: onProgress,
    ).then((meta) async {
      _ref.invalidate(offlinePackIndexProvider);
      _ref.invalidate(offlinePackMetaProvider);
      _ref.invalidate(offlineSnapshotProvider);
      _ref.invalidate(seasonalOverlaysProvider);
      return meta;
    });
  }

  /// Switch the active AOI pack without rebuilding tiles.
  Future<void> activatePack(String packId) async {
    final store = _ref.read(offlinePackStoreProvider);
    final meta = await store.loadMeta(packId);
    if (meta == null) {
      throw StateError('Offline pack not found: $packId');
    }
    await store.setActivePackId(packId);
    _ref.read(offlineTileCacheProvider).setActivePackId(packId);
    _ref.invalidate(offlinePackIndexProvider);
    _ref.invalidate(offlinePackMetaProvider);
    _ref.invalidate(offlineSnapshotProvider);
    _ref.invalidate(offlineOutboxCountProvider);
    _ref.invalidate(seasonalOverlaysProvider);
    _ref.invalidate(markersProvider);
    _ref.invalidate(layersProvider);
    _ref.invalidate(zonesProvider);
    _ref.invalidate(watchLogEntriesProvider);
  }

  Future<void> renamePack({
    required String packId,
    required String name,
  }) async {
    final store = _ref.read(offlinePackStoreProvider);
    final meta = await store.loadMeta(packId);
    if (meta == null) {
      return;
    }
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed == meta.name) {
      return;
    }
    final index = await store.loadIndex();
    final duplicate = index.packs.any(
      (pack) =>
          pack.id != packId &&
          pack.name.trim().toLowerCase() == trimmed.toLowerCase(),
    );
    if (duplicate) {
      throw StateError('An offline pack with that name already exists.');
    }
    await store.saveMeta(meta.copyWith(name: trimmed), activate: false);
    _ref.invalidate(offlinePackIndexProvider);
    _ref.invalidate(offlinePackMetaProvider);
  }

  /// Deletes one pack (defaults to the active pack). Sibling packs remain.
  Future<void> clearPack({String? packId}) async {
    final store = _ref.read(offlinePackStoreProvider);
    final tileCache = _ref.read(offlineTileCacheProvider);
    final id = packId ?? await store.activePackId();
    if (id == null) {
      return;
    }
    final nextActive = await store.deletePack(id);
    await tileCache.clearPack(id);
    tileCache.setActivePackId(nextActive);
    _ref.invalidate(offlinePackIndexProvider);
    _ref.invalidate(offlinePackMetaProvider);
    _ref.invalidate(offlineSnapshotProvider);
    _ref.invalidate(offlineOutboxCountProvider);
    _ref.invalidate(seasonalOverlaysProvider);
  }

  /// Removes every offline pack and all cached tiles.
  Future<void> clearAllPacks() async {
    await _ref.read(offlinePackStoreProvider).clearAll();
    await _ref.read(offlineTileCacheProvider).clear();
    _ref.read(offlineTileCacheProvider).setActivePackId(null);
    _ref.invalidate(offlinePackIndexProvider);
    _ref.invalidate(offlinePackMetaProvider);
    _ref.invalidate(offlineSnapshotProvider);
    _ref.invalidate(offlineOutboxCountProvider);
    _ref.invalidate(seasonalOverlaysProvider);
  }

  Future<void> enqueueMarker(MapMarker marker) async {
    final store = _ref.read(offlinePackStoreProvider);
    await store.enqueue(OfflineOutboxOp.createMarker(marker));
    final snapshot = await store.loadSnapshot();
    if (snapshot != null) {
      await store.saveSnapshot(
        snapshot.copyWith(markers: [...snapshot.markers, marker]),
      );
      _ref.invalidate(offlineSnapshotProvider);
      _ref.invalidate(markersProvider);
    }
    _ref.invalidate(offlineOutboxCountProvider);
  }

  Future<bool> isPendingCreateMarker(UuidValue markerId) async {
    final ops = await _ref.read(offlinePackStoreProvider).loadOutbox();
    return ops.any(
      (op) =>
          op.type == OfflineOutboxOpType.createMarker &&
          offlinePayloadEntityId(op.payload) == markerId.uuid,
    );
  }

  /// Updates a marker in the offline snapshot and outbox (layer changes, etc.).
  Future<void> updateMarkerOffline(MapMarker marker) async {
    final store = _ref.read(offlinePackStoreProvider);
    final ops = [...await store.loadOutbox()];
    final createIndex = ops.indexWhere(
      (op) =>
          op.type == OfflineOutboxOpType.createMarker &&
          offlinePayloadEntityId(op.payload) == marker.id.uuid,
    );
    if (createIndex >= 0) {
      ops[createIndex] = OfflineOutboxOp(
        id: ops[createIndex].id,
        type: OfflineOutboxOpType.createMarker,
        payload: marker.toJson(),
        createdAt: ops[createIndex].createdAt,
      );
      await store.saveOutbox(ops);
    } else {
      await store.enqueue(OfflineOutboxOp.updateMarker(marker));
    }

    final snapshot = await store.loadSnapshot();
    if (snapshot != null) {
      var zones = snapshot.zones;
      final trackZoneId = marker.trackZoneId;
      if (trackZoneId != null) {
        final zoneIndex = zones.indexWhere((zone) => zone.id == trackZoneId);
        if (zoneIndex >= 0) {
          final updatedZone = zones[zoneIndex].copyWith(
            layerId: marker.layerId,
            updatedAt: marker.updatedAt,
          );
          zones = [
            for (var i = 0; i < zones.length; i++)
              if (i == zoneIndex) updatedZone else zones[i],
          ];
          await store.enqueue(OfflineOutboxOp.upsertTrackZone(updatedZone));
        }
      }
      await store.saveSnapshot(
        snapshot.copyWith(
          markers: [
            for (final existing in snapshot.markers)
              if (existing.id == marker.id) marker else existing,
          ],
          zones: zones,
        ),
      );
      _ref.invalidate(offlineSnapshotProvider);
      _ref.invalidate(markersProvider);
      _ref.invalidate(zonesProvider);
    }
    _ref.invalidate(offlineOutboxCountProvider);
  }

  /// Drops a marker that was created offline and has not been synced yet.
  ///
  /// Returns false if the marker is not a pending create (server-origin markers
  /// cannot be deleted while offline).
  Future<bool> deleteUnsyncedMarker(UuidValue markerId) async {
    final store = _ref.read(offlinePackStoreProvider);
    final ops = await store.loadOutbox();
    final hasCreate = ops.any(
      (op) =>
          op.type == OfflineOutboxOpType.createMarker &&
          offlinePayloadEntityId(op.payload) == markerId.uuid,
    );
    if (!hasCreate) {
      return false;
    }

    final snapshot = await store.loadSnapshot();
    MapMarker? marker;
    if (snapshot != null) {
      for (final candidate in snapshot.markers) {
        if (candidate.id == markerId) {
          marker = candidate;
          break;
        }
      }
    }
    final trackZoneId = marker?.trackZoneId;

    final remaining = [
      for (final op in ops)
        if (!offlineOpTargetsMarker(op, markerId) &&
            !(op.type == OfflineOutboxOpType.upsertTrackZone &&
                trackZoneId != null &&
                offlinePayloadEntityId(op.payload) == trackZoneId.uuid))
          op,
    ];
    await store.saveOutbox(remaining);

    if (snapshot != null) {
      await store.saveSnapshot(
        snapshot.copyWith(
          markers: [
            for (final existing in snapshot.markers)
              if (existing.id != markerId) existing,
          ],
          zones: [
            for (final zone in snapshot.zones)
              if (trackZoneId == null || zone.id != trackZoneId) zone,
          ],
          watchLogEntries: [
            for (final entry in snapshot.watchLogEntries)
              if (entry.markerId != markerId) entry,
          ],
        ),
      );
      _ref.invalidate(offlineSnapshotProvider);
      _ref.invalidate(markersProvider);
      _ref.invalidate(zonesProvider);
      _ref.invalidate(watchLogEntriesProvider);
    }
    _ref.invalidate(offlineOutboxCountProvider);
    return true;
  }

  Future<void> enqueueWatchLog(WatchLogEntry entry) async {
    final store = _ref.read(offlinePackStoreProvider);
    await store.enqueue(OfflineOutboxOp.createWatchLogEntry(entry));
    final snapshot = await store.loadSnapshot();
    if (snapshot != null) {
      await store.saveSnapshot(
        snapshot.copyWith(
          watchLogEntries: [...snapshot.watchLogEntries, entry],
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
      await store.saveSnapshot(
        snapshot.copyWith(
          zones: [
            for (final existing in snapshot.zones)
              if (existing.id != zone.id) existing,
            zone,
          ],
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
    TrackTransportationMode transportationMode = TrackTransportationMode.onFoot,
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
      transportationMode: transportationMode,
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

  /// Appends GPS points to offline tracking markers that have moved enough.
  ///
  /// When [onlyMarkerId] is set, only that marker is updated (used when the
  /// device GPS is bound to a specific tracking marker).
  Future<void> appendGpsToTrackingMarkers(
    LatLng position, {
    UuidValue? onlyMarkerId,
  }) async {
    final store = _ref.read(offlinePackStoreProvider);
    final snapshot = await store.loadSnapshot();
    if (snapshot == null) {
      return;
    }

    var markers = snapshot.markers;
    var zones = snapshot.zones;
    var changed = false;

    for (final marker in snapshot.markers) {
      if (onlyMarkerId != null && marker.id != onlyMarkerId) {
        continue;
      }
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
      snapshot.copyWith(markers: markers, zones: zones),
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
