import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/offline_outbox.dart';
import '../models/offline_pack.dart';
import '../models/offline_snapshot.dart';

const _metaKey = 'wayfinder.offline_pack.meta';
const _snapshotKey = 'wayfinder.offline_pack.snapshot';
const _outboxKey = 'wayfinder.offline_pack.outbox';

class OfflinePackStore {
  Future<OfflinePackMeta?> loadMeta() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_metaKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return OfflinePackMeta.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  Future<void> saveMeta(OfflinePackMeta meta) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_metaKey, jsonEncode(meta.toJson()));
  }

  Future<void> clearMeta() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_metaKey);
  }

  Future<OfflineSnapshot?> loadSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_snapshotKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return OfflineSnapshot.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  Future<void> saveSnapshot(OfflineSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_snapshotKey, jsonEncode(snapshot.toJson()));
  }

  Future<void> clearSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_snapshotKey);
  }

  Future<List<OfflineOutboxOp>> loadOutbox() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_outboxKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    final list = jsonDecode(raw) as List;
    return [
      for (final item in list)
        OfflineOutboxOp.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<void> saveOutbox(List<OfflineOutboxOp> ops) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _outboxKey,
      jsonEncode([for (final op in ops) op.toJson()]),
    );
  }

  /// Appends [op], coalescing later updates of the same marker/track zone.
  Future<void> enqueue(OfflineOutboxOp op) async {
    final ops = [...await loadOutbox()];
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
    await saveOutbox(ops);
  }

  Future<void> clearOutbox() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_outboxKey);
  }

  Future<void> clearAll() async {
    await clearMeta();
    await clearSnapshot();
    await clearOutbox();
  }
}

final offlinePackStoreProvider = Provider<OfflinePackStore>(
  (ref) => OfflinePackStore(),
);
