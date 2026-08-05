import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wayfinder_client/wayfinder_client.dart';

import '../models/offline_outbox.dart';
import '../models/offline_pack.dart';
import '../models/offline_snapshot.dart';

const _legacyMetaKey = 'wayfinder.offline_pack.meta';
const _legacySnapshotKey = 'wayfinder.offline_pack.snapshot';
const _legacyOutboxKey = 'wayfinder.offline_pack.outbox';
const _indexKey = 'wayfinder.offline_packs.index';
const _legacyTilesPendingKey = 'wayfinder.offline_packs.legacyTilesPending';

String _metaKey(String packId) => 'wayfinder.offline_pack.$packId.meta';
String _snapshotKey(String packId) => 'wayfinder.offline_pack.$packId.snapshot';
String _outboxKey(String packId) => 'wayfinder.offline_pack.$packId.outbox';

/// Lightweight row in the multi-pack registry (not full meta).
class OfflinePackIndexEntry {
  const OfflinePackIndexEntry({
    required this.id,
    required this.name,
    required this.preparedAt,
    this.layerNames = const [],
    this.tileCount = 0,
    this.markerCount = 0,
    this.zoneCount = 0,
    this.seasonalOverlayCount = 0,
    this.routeCount = 0,
  });

  final String id;
  final String name;
  final DateTime preparedAt;
  final List<String> layerNames;
  final int tileCount;
  final int markerCount;
  final int zoneCount;
  final int seasonalOverlayCount;
  final int routeCount;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'preparedAt': preparedAt.toIso8601String(),
    'layerNames': layerNames,
    'tileCount': tileCount,
    'markerCount': markerCount,
    'zoneCount': zoneCount,
    'seasonalOverlayCount': seasonalOverlayCount,
    'routeCount': routeCount,
  };

  factory OfflinePackIndexEntry.fromJson(Map<String, dynamic> json) {
    return OfflinePackIndexEntry(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Offline pack',
      preparedAt: DateTime.parse(
        json['preparedAt'] as String? ??
            DateTime.now().toUtc().toIso8601String(),
      ),
      layerNames: [
        for (final raw in json['layerNames'] as List? ?? const [])
          raw as String,
      ],
      tileCount: (json['tileCount'] as num?)?.toInt() ?? 0,
      markerCount: (json['markerCount'] as num?)?.toInt() ?? 0,
      zoneCount: (json['zoneCount'] as num?)?.toInt() ?? 0,
      seasonalOverlayCount:
          (json['seasonalOverlayCount'] as num?)?.toInt() ?? 0,
      routeCount: (json['routeCount'] as num?)?.toInt() ?? 0,
    );
  }

  factory OfflinePackIndexEntry.fromMeta(OfflinePackMeta meta) {
    return OfflinePackIndexEntry(
      id: meta.id,
      name: meta.name,
      preparedAt: meta.preparedAt,
      layerNames: meta.layerNames,
      tileCount: meta.tileCount,
      markerCount: meta.markerCount,
      zoneCount: meta.zoneCount,
      seasonalOverlayCount: meta.seasonalOverlayCount,
      routeCount: meta.routeCount,
    );
  }

  OfflinePackIndexEntry copyWith({
    String? id,
    String? name,
    DateTime? preparedAt,
    List<String>? layerNames,
    int? tileCount,
    int? markerCount,
    int? zoneCount,
    int? seasonalOverlayCount,
    int? routeCount,
  }) {
    return OfflinePackIndexEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      preparedAt: preparedAt ?? this.preparedAt,
      layerNames: layerNames ?? this.layerNames,
      tileCount: tileCount ?? this.tileCount,
      markerCount: markerCount ?? this.markerCount,
      zoneCount: zoneCount ?? this.zoneCount,
      seasonalOverlayCount: seasonalOverlayCount ?? this.seasonalOverlayCount,
      routeCount: routeCount ?? this.routeCount,
    );
  }
}

class OfflinePackIndex {
  const OfflinePackIndex({
    this.activePackId,
    this.packs = const [],
  });

  final String? activePackId;
  final List<OfflinePackIndexEntry> packs;

  bool get isEmpty => packs.isEmpty;

  OfflinePackIndexEntry? get activeEntry {
    final id = activePackId;
    if (id == null) {
      return null;
    }
    for (final pack in packs) {
      if (pack.id == id) {
        return pack;
      }
    }
    return packs.isEmpty ? null : packs.first;
  }

  Map<String, dynamic> toJson() => {
    'activePackId': activePackId,
    'packs': [for (final pack in packs) pack.toJson()],
  };

  factory OfflinePackIndex.fromJson(Map<String, dynamic> json) {
    return OfflinePackIndex(
      activePackId: json['activePackId'] as String?,
      packs: [
        for (final raw in json['packs'] as List? ?? const [])
          OfflinePackIndexEntry.fromJson(raw as Map<String, dynamic>),
      ],
    );
  }

  OfflinePackIndex copyWith({
    String? activePackId,
    List<OfflinePackIndexEntry>? packs,
    bool clearActivePackId = false,
  }) {
    return OfflinePackIndex(
      activePackId: clearActivePackId
          ? null
          : (activePackId ?? this.activePackId),
      packs: packs ?? this.packs,
    );
  }
}

/// Persists one or more offline packs (meta / snapshot / outbox) and the
/// active-pack pointer. Migrates the legacy singleton keys on first use.
class OfflinePackStore {
  var _migrated = false;

  /// Ensures multi-pack index exists. Returns a pack id whose legacy tiles
  /// still need prefixing, or null.
  Future<String?> ensureMigrated() async {
    if (_migrated) {
      return null;
    }
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_indexKey)) {
      _migrated = true;
      return prefs.getString(_legacyTilesPendingKey);
    }

    final legacyMetaRaw = prefs.getString(_legacyMetaKey);
    if (legacyMetaRaw == null || legacyMetaRaw.isEmpty) {
      await prefs.setString(
        _indexKey,
        jsonEncode(const OfflinePackIndex().toJson()),
      );
      _migrated = true;
      return null;
    }

    final packId = const Uuid().v4();
    final metaJson = jsonDecode(legacyMetaRaw) as Map<String, dynamic>;
    metaJson['id'] = packId;
    final meta = OfflinePackMeta.fromJson(metaJson);

    await prefs.setString(_metaKey(packId), jsonEncode(meta.toJson()));
    final snapshot = prefs.getString(_legacySnapshotKey);
    if (snapshot != null && snapshot.isNotEmpty) {
      await prefs.setString(_snapshotKey(packId), snapshot);
    }
    final outbox = prefs.getString(_legacyOutboxKey);
    if (outbox != null && outbox.isNotEmpty) {
      await prefs.setString(_outboxKey(packId), outbox);
    }

    final index = OfflinePackIndex(
      activePackId: packId,
      packs: [OfflinePackIndexEntry.fromMeta(meta)],
    );
    await prefs.setString(_indexKey, jsonEncode(index.toJson()));
    await prefs.setString(_legacyTilesPendingKey, packId);
    await prefs.remove(_legacyMetaKey);
    await prefs.remove(_legacySnapshotKey);
    await prefs.remove(_legacyOutboxKey);
    _migrated = true;
    return packId;
  }

  Future<void> clearLegacyTilesPending() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_legacyTilesPendingKey);
  }

  Future<OfflinePackIndex> loadIndex() async {
    await ensureMigrated();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_indexKey);
    if (raw == null || raw.isEmpty) {
      return const OfflinePackIndex();
    }
    return OfflinePackIndex.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  Future<void> saveIndex(OfflinePackIndex index) async {
    await ensureMigrated();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_indexKey, jsonEncode(index.toJson()));
  }

  /// Syncs index rows from pack meta, and backfills layer names from snapshots.
  ///
  /// Older packs only stored id/name/preparedAt in the index; this keeps the
  /// list/rename UI useful without requiring a re-prepare.
  Future<OfflinePackIndex> enrichIndexSummaries() async {
    final index = await loadIndex();
    if (index.packs.isEmpty) {
      return index;
    }

    var indexChanged = false;
    final packs = <OfflinePackIndexEntry>[];
    final prefs = await SharedPreferences.getInstance();
    for (final entry in index.packs) {
      var meta = await loadMeta(entry.id);
      if (meta == null) {
        packs.add(entry);
        continue;
      }

      if (meta.layerNames.isEmpty) {
        final snapshot = await loadSnapshot(entry.id);
        final layers = snapshot?.layers ?? const <MapLayer>[];
        final layerNames = <String>[
          for (final layer in layers) layer.name,
        ];
        if (layerNames.isNotEmpty) {
          meta = meta.copyWith(layerNames: layerNames);
          await prefs.setString(_metaKey(meta.id), jsonEncode(meta.toJson()));
        }
      }

      final enriched = OfflinePackIndexEntry.fromMeta(meta);
      packs.add(enriched);
      if (!_indexEntrySummaryEquals(entry, enriched)) {
        indexChanged = true;
      }
    }

    if (!indexChanged) {
      return index;
    }
    final enrichedIndex = OfflinePackIndex(
      activePackId: index.activePackId,
      packs: packs,
    );
    await saveIndex(enrichedIndex);
    return enrichedIndex;
  }

  bool _indexEntrySummaryEquals(
    OfflinePackIndexEntry a,
    OfflinePackIndexEntry b,
  ) {
    if (a.id != b.id ||
        a.name != b.name ||
        a.preparedAt != b.preparedAt ||
        a.tileCount != b.tileCount ||
        a.markerCount != b.markerCount ||
        a.zoneCount != b.zoneCount ||
        a.seasonalOverlayCount != b.seasonalOverlayCount ||
        a.routeCount != b.routeCount ||
        a.layerNames.length != b.layerNames.length) {
      return false;
    }
    for (var i = 0; i < a.layerNames.length; i++) {
      if (a.layerNames[i] != b.layerNames[i]) {
        return false;
      }
    }
    return true;
  }

  Future<String?> activePackId() async {
    return (await loadIndex()).activePackId;
  }

  Future<void> setActivePackId(String? packId) async {
    final index = await loadIndex();
    await saveIndex(
      index.copyWith(
        activePackId: packId,
        clearActivePackId: packId == null,
      ),
    );
  }

  Future<void> upsertIndexEntry(
    OfflinePackMeta meta, {
    bool activate = true,
  }) async {
    final index = await loadIndex();
    final entry = OfflinePackIndexEntry.fromMeta(meta);
    final packs = [
      for (final existing in index.packs)
        if (existing.id != meta.id) existing,
      entry,
    ]..sort((a, b) => b.preparedAt.compareTo(a.preparedAt));
    await saveIndex(
      OfflinePackIndex(
        activePackId: activate ? meta.id : (index.activePackId ?? meta.id),
        packs: packs,
      ),
    );
  }

  Future<OfflinePackMeta?> loadMeta([String? packId]) async {
    await ensureMigrated();
    final id = packId ?? await activePackId();
    if (id == null) {
      return null;
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_metaKey(id));
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return OfflinePackMeta.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  Future<void> saveMeta(OfflinePackMeta meta, {bool activate = true}) async {
    await ensureMigrated();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_metaKey(meta.id), jsonEncode(meta.toJson()));
    await upsertIndexEntry(meta, activate: activate);
  }

  Future<OfflineSnapshot?> loadSnapshot([String? packId]) async {
    await ensureMigrated();
    final id = packId ?? await activePackId();
    if (id == null) {
      return null;
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_snapshotKey(id));
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return OfflineSnapshot.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  Future<void> saveSnapshot(OfflineSnapshot snapshot, {String? packId}) async {
    await ensureMigrated();
    final id = packId ?? await activePackId();
    if (id == null) {
      throw StateError('No active offline pack to save snapshot into.');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_snapshotKey(id), jsonEncode(snapshot.toJson()));
  }

  Future<List<OfflineOutboxOp>> loadOutbox([String? packId]) async {
    await ensureMigrated();
    final id = packId ?? await activePackId();
    if (id == null) {
      return const [];
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_outboxKey(id));
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    final list = jsonDecode(raw) as List;
    return [
      for (final item in list)
        OfflineOutboxOp.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<void> saveOutbox(List<OfflineOutboxOp> ops, {String? packId}) async {
    await ensureMigrated();
    final id = packId ?? await activePackId();
    if (id == null) {
      throw StateError('No active offline pack to save outbox into.');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _outboxKey(id),
      jsonEncode([for (final op in ops) op.toJson()]),
    );
  }

  /// Appends [op], coalescing later updates of the same marker/track zone.
  Future<void> enqueue(OfflineOutboxOp op, {String? packId}) async {
    final ops = [...await loadOutbox(packId)];
    switch (op.type) {
      case OfflineOutboxOpType.updateMarker:
        final markerId = op.payload['id'];
        ops.removeWhere(
          (existing) =>
              existing.type == OfflineOutboxOpType.updateMarker &&
              existing.payload['id'] == markerId,
        );
      case OfflineOutboxOpType.upsertTrackZone:
        final zoneId = op.payload['id'];
        ops.removeWhere(
          (existing) =>
              existing.type == OfflineOutboxOpType.upsertTrackZone &&
              existing.payload['id'] == zoneId,
        );
      case OfflineOutboxOpType.createMarker:
      case OfflineOutboxOpType.createWatchLogEntry:
        break;
    }
    ops.add(op);
    await saveOutbox(ops, packId: packId);
  }

  Future<void> clearOutbox([String? packId]) async {
    await ensureMigrated();
    final id = packId ?? await activePackId();
    if (id == null) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_outboxKey(id));
  }

  /// Removes one pack's prefs entries and updates the index.
  ///
  /// Returns the next active pack id (may be null). Caller should clear tiles.
  Future<String?> deletePack(String packId) async {
    await ensureMigrated();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_metaKey(packId));
    await prefs.remove(_snapshotKey(packId));
    await prefs.remove(_outboxKey(packId));

    final index = await loadIndex();
    final remaining = [
      for (final pack in index.packs)
        if (pack.id != packId) pack,
    ];
    final nextActive = index.activePackId == packId
        ? (remaining.isEmpty ? null : remaining.first.id)
        : index.activePackId;
    await saveIndex(
      OfflinePackIndex(activePackId: nextActive, packs: remaining),
    );
    return nextActive;
  }

  /// Deletes every pack (prefs only). Caller clears the tile cache.
  Future<void> clearAll() async {
    await ensureMigrated();
    final index = await loadIndex();
    final prefs = await SharedPreferences.getInstance();
    for (final pack in index.packs) {
      await prefs.remove(_metaKey(pack.id));
      await prefs.remove(_snapshotKey(pack.id));
      await prefs.remove(_outboxKey(pack.id));
    }
    await prefs.setString(
      _indexKey,
      jsonEncode(const OfflinePackIndex().toJson()),
    );
  }
}

final offlinePackStoreProvider = Provider<OfflinePackStore>(
  (ref) => OfflinePackStore(),
);
