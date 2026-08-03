import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idb_shim/idb.dart';

import 'offline_tile_cache_stub.dart'
    if (dart.library.html) 'offline_tile_cache_web.dart'
    if (dart.library.io) 'offline_tile_cache_io.dart';

const _dbName = 'wayfinder_offline_tiles';
const _storeName = 'tiles';
const _dbVersion = 1;

/// Stores basemap tile bytes for prepared offline AOI packs.
///
/// Keys are `{packId}/{catalogId}/{z}/{x}/{y}`. Legacy singleton keys
/// `{catalogId}/{z}/{x}/{y}` are migrated once via [migrateLegacyTilesToPack].
class OfflineTileCache {
  Database? _db;
  String? _activePackId;

  /// Pack whose tiles [getTile]/[putTile] read/write. Required for multi-pack.
  void setActivePackId(String? packId) {
    _activePackId = packId;
  }

  String? get activePackId => _activePackId;

  Future<Database> _open() async {
    final existing = _db;
    if (existing != null) {
      return existing;
    }
    final factory = await openOfflineTileIdbFactory();
    final db = await factory.open(
      _dbName,
      version: _dbVersion,
      onUpgradeNeeded: (event) {
        final database = event.database;
        if (!database.objectStoreNames.contains(_storeName)) {
          database.createObjectStore(_storeName);
        }
      },
    );
    _db = db;
    return db;
  }

  static String tileKey({
    required String packId,
    required String catalogId,
    required int z,
    required int x,
    required int y,
  }) => '$packId/$catalogId/$z/$x/$y';

  String _requireActiveKey({
    required String catalogId,
    required int z,
    required int x,
    required int y,
  }) {
    final packId = _activePackId;
    if (packId == null || packId.isEmpty) {
      throw StateError('Offline tile cache has no active pack id.');
    }
    return tileKey(
      packId: packId,
      catalogId: catalogId,
      z: z,
      x: x,
      y: y,
    );
  }

  Future<void> putTile({
    required String catalogId,
    required int z,
    required int x,
    required int y,
    required Uint8List bytes,
    String? packId,
  }) async {
    final key = packId == null
        ? _requireActiveKey(catalogId: catalogId, z: z, x: x, y: y)
        : tileKey(
            packId: packId,
            catalogId: catalogId,
            z: z,
            x: x,
            y: y,
          );
    final db = await _open();
    final txn = db.transaction(_storeName, idbModeReadWrite);
    final store = txn.objectStore(_storeName);
    await store.put(base64Encode(bytes), key);
    await txn.completed;
  }

  Future<Uint8List?> getTile({
    required String catalogId,
    required int z,
    required int x,
    required int y,
    String? packId,
  }) async {
    final key = packId == null
        ? _requireActiveKey(catalogId: catalogId, z: z, x: x, y: y)
        : tileKey(
            packId: packId,
            catalogId: catalogId,
            z: z,
            x: x,
            y: y,
          );
    final db = await _open();
    final txn = db.transaction(_storeName, idbModeReadOnly);
    final store = txn.objectStore(_storeName);
    final raw = await store.getObject(key);
    await txn.completed;
    if (raw is! String || raw.isEmpty) {
      return null;
    }
    return Uint8List.fromList(base64Decode(raw));
  }

  Future<int> countTiles({String? packId}) async {
    final db = await _open();
    final txn = db.transaction(_storeName, idbModeReadOnly);
    final store = txn.objectStore(_storeName);
    if (packId == null) {
      final count = await store.count();
      await txn.completed;
      return count;
    }
    final prefix = '$packId/';
    var count = 0;
    final cursor = store.openCursor(autoAdvance: true);
    await for (final entry in cursor) {
      final key = entry.key;
      if (key is String && key.startsWith(prefix)) {
        count += 1;
      }
    }
    await txn.completed;
    return count;
  }

  /// Deletes tiles for one pack. Leaves other packs intact.
  Future<void> clearPack(String packId) async {
    final db = await _open();
    final txn = db.transaction(_storeName, idbModeReadWrite);
    final store = txn.objectStore(_storeName);
    final prefix = '$packId/';
    final keys = <Object>[];
    final cursor = store.openCursor(autoAdvance: true);
    await for (final entry in cursor) {
      final key = entry.key;
      if (key is String && key.startsWith(prefix)) {
        keys.add(key);
      }
    }
    for (final key in keys) {
      await store.delete(key);
    }
    await txn.completed;
  }

  /// Prefixes legacy `{catalogId}/z/x/y` keys with [packId] after singleton
  /// migration. Safe to call when no legacy keys remain.
  Future<int> migrateLegacyTilesToPack(String packId) async {
    final db = await _open();
    final txn = db.transaction(_storeName, idbModeReadWrite);
    final store = txn.objectStore(_storeName);
    final moves = <String, String>{};
    final cursor = store.openCursor(autoAdvance: true);
    await for (final entry in cursor) {
      final key = entry.key;
      if (key is! String) {
        continue;
      }
      final parts = key.split('/');
      // Legacy: catalogId/z/x/y (4 parts). New: packId/catalogId/z/x/y (5).
      if (parts.length == 4) {
        moves[key] = '$packId/$key';
      }
    }
    for (final entry in moves.entries) {
      final value = await store.getObject(entry.key);
      if (value != null) {
        await store.put(value, entry.value);
        await store.delete(entry.key);
      }
    }
    await txn.completed;
    return moves.length;
  }

  Future<void> clear() async {
    final db = await _open();
    final txn = db.transaction(_storeName, idbModeReadWrite);
    final store = txn.objectStore(_storeName);
    await store.clear();
    await txn.completed;
  }
}

final offlineTileCacheProvider = Provider<OfflineTileCache>(
  (ref) => OfflineTileCache(),
);
