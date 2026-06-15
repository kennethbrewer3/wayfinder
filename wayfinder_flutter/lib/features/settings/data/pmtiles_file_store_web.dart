import 'dart:typed_data';

import 'package:idb_shim/idb_browser.dart';

import '../../../core/logging/app_logger.dart';
import 'pmtiles_file_store.dart';

class WebPmtilesFileStore extends PmtilesFileStore {
  static const _databaseName = 'wayfinder_pmtiles';
  static const _storeName = 'files';
  static const _metaStoreName = 'meta';
  static const _databaseVersion = 2;
  static final _log = AppLogger.logStorage;

  Future<Database> _openDatabase() async {
    _log.debug(
      '🌐 Opening IndexedDB',
      data: 'db=$_databaseName stores=$_storeName,$_metaStoreName',
    );
    final factory = getIdbFactory();
    if (factory == null) {
      _log.error('🌐 IndexedDB factory unavailable in this browser');
      throw StateError('IndexedDB is not available in this browser.');
    }

    try {
      final database = await factory.open(
        _databaseName,
        version: _databaseVersion,
        onUpgradeNeeded: (VersionChangeEvent event) {
          _log.info(
            '🌐 IndexedDB upgrade needed',
            data: 'version=${event.oldVersion}->${event.newVersion}',
          );
          final database = event.database;
          if (!database.objectStoreNames.contains(_storeName)) {
            database.createObjectStore(_storeName);
            _log.success('🌐 IndexedDB object store created', data: _storeName);
          }
          if (!database.objectStoreNames.contains(_metaStoreName)) {
            database.createObjectStore(_metaStoreName);
            _log.success('🌐 IndexedDB object store created', data: _metaStoreName);
          }
        },
      );
      _log.success('🌐 IndexedDB opened');
      return database;
    } catch (error, stackTrace) {
      _log.error(
        '🌐 IndexedDB open failed',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> write(String id, Uint8List bytes) async {
    _log.info('💾 [web] write started', data: 'id=$id size=${formatBytes(bytes.length)}');
    final database = await _openDatabase();
    try {
      final transaction = database.transaction(_storeName, idbModeReadWrite);
      await transaction.objectStore(_storeName).put(bytes, id);
      await transaction.completed;
      _log.success('💾 [web] write complete', data: id);
    } catch (error, stackTrace) {
      _log.error(
        '💾 [web] write failed',
        error: error,
        stackTrace: stackTrace,
        data: 'id=$id size=${formatBytes(bytes.length)}',
      );
      rethrow;
    } finally {
      database.close();
    }
  }

  @override
  Future<Uint8List?> read(String id) async {
    _log.debug('📥 [web] read started', data: id);
    final database = await _openDatabase();
    try {
      final transaction = database.transaction(_storeName, idbModeReadOnly);
      final value = await transaction.objectStore(_storeName).getObject(id);
      await transaction.completed;

      if (value == null) {
        _log.warn('📥 [web] read miss', data: id);
        return null;
      }

      if (value is Uint8List) {
        _log.success('📥 [web] read hit', data: 'id=$id size=${formatBytes(value.length)}');
        return value;
      }
      if (value is List<int>) {
        final bytes = Uint8List.fromList(value);
        _log.success(
          '📥 [web] read hit (List<int>)',
          data: 'id=$id size=${formatBytes(bytes.length)}',
        );
        return bytes;
      }

      _log.error(
        '📥 [web] unexpected stored value type',
        data: 'id=$id runtimeType=${value.runtimeType}',
      );
      return null;
    } catch (error, stackTrace) {
      _log.error(
        '📥 [web] read failed',
        error: error,
        stackTrace: stackTrace,
        data: id,
      );
      rethrow;
    } finally {
      database.close();
    }
  }

  @override
  Future<void> delete(String id) async {
    _log.info('🗑️ [web] delete started', data: id);
    final database = await _openDatabase();
    try {
      final transaction = database.transaction(_storeName, idbModeReadWrite);
      await transaction.objectStore(_storeName).delete(id);
      await transaction.completed;
      _log.success('🗑️ [web] delete complete', data: id);
    } catch (error, stackTrace) {
      _log.error(
        '🗑️ [web] delete failed',
        error: error,
        stackTrace: stackTrace,
        data: id,
      );
      rethrow;
    } finally {
      database.close();
    }
  }

  @override
  Future<bool> exists(String id) async {
    final ids = await listStoredIds();
    return ids.contains(id);
  }

  @override
  Future<Set<String>> listStoredIds() async {
    final database = await _openDatabase();
    try {
      final transaction = database.transaction(_storeName, idbModeReadOnly);
      final keys = await transaction.objectStore(_storeName).getAllKeys();
      await transaction.completed;
      return keys.map((key) => key.toString()).toSet();
    } finally {
      database.close();
    }
  }

  @override
  Future<void> writeMeta(String key, String value) async {
    _log.debug('📝 [web] meta write', data: key);
    final database = await _openDatabase();
    try {
      final transaction = database.transaction(_metaStoreName, idbModeReadWrite);
      await transaction.objectStore(_metaStoreName).put(value, key);
      await transaction.completed;
    } finally {
      database.close();
    }
  }

  @override
  Future<String?> readMeta(String key) async {
    _log.debug('📝 [web] meta read', data: key);
    final database = await _openDatabase();
    try {
      final transaction = database.transaction(_metaStoreName, idbModeReadOnly);
      final value = await transaction.objectStore(_metaStoreName).getObject(key);
      await transaction.completed;
      final text = value?.toString();
      if (text == null || text.isEmpty) {
        return null;
      }
      return text;
    } finally {
      database.close();
    }
  }

  @override
  Future<void> deleteMeta(String key) async {
    _log.debug('📝 [web] meta delete', data: key);
    final database = await _openDatabase();
    try {
      final transaction = database.transaction(_metaStoreName, idbModeReadWrite);
      await transaction.objectStore(_metaStoreName).delete(key);
      await transaction.completed;
    } finally {
      database.close();
    }
  }

  @override
  Future<String?> localPath(String id) async => null;
}

PmtilesFileStore createPlatformPmtilesFileStore() {
  AppLogger.logStorage.info('🏗️ Creating WebPmtilesFileStore (IndexedDB backend)');
  return WebPmtilesFileStore();
}
