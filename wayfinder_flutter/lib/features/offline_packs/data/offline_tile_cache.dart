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

/// Stores basemap tile bytes for a prepared offline AOI.
class OfflineTileCache {
  Database? _db;

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
    required String catalogId,
    required int z,
    required int x,
    required int y,
  }) => '$catalogId/$z/$x/$y';

  Future<void> putTile({
    required String catalogId,
    required int z,
    required int x,
    required int y,
    required Uint8List bytes,
  }) async {
    final db = await _open();
    final txn = db.transaction(_storeName, idbModeReadWrite);
    final store = txn.objectStore(_storeName);
    await store.put(
      base64Encode(bytes),
      tileKey(catalogId: catalogId, z: z, x: x, y: y),
    );
    await txn.completed;
  }

  Future<Uint8List?> getTile({
    required String catalogId,
    required int z,
    required int x,
    required int y,
  }) async {
    final db = await _open();
    final txn = db.transaction(_storeName, idbModeReadOnly);
    final store = txn.objectStore(_storeName);
    final raw = await store.getObject(
      tileKey(catalogId: catalogId, z: z, x: x, y: y),
    );
    await txn.completed;
    if (raw is! String || raw.isEmpty) {
      return null;
    }
    return Uint8List.fromList(base64Decode(raw));
  }

  Future<int> countTiles() async {
    final db = await _open();
    final txn = db.transaction(_storeName, idbModeReadOnly);
    final store = txn.objectStore(_storeName);
    final count = await store.count();
    await txn.completed;
    return count;
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
