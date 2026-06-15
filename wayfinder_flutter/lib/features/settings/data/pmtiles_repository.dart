import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/platform_file_utils.dart';
import '../models/pmtiles_file.dart';
import '../models/pmtiles_source.dart';
import 'pmtiles_file_store.dart';
import 'pmtiles_file_store_factory.dart';

class PmtilesRepository {
  PmtilesRepository({PmtilesFileStore? store})
      : _store = store ?? createPmtilesFileStore();

  final PmtilesFileStore _store;
  static final _log = AppLogger.logPmtiles;

  Future<List<PmtilesFile>> listFiles() async {
    _log.debug('📋 Loading PMTiles manifest');
    try {
      final raw = await _readPreference(AppConstants.pmtilesManifestKey);
      if (raw == null) {
        _log.info('📋 Manifest empty — no files registered yet');
        return <PmtilesFile>[];
      }

      final decoded = jsonDecode(raw) as List<dynamic>;
      final files = decoded
          .cast<Map<String, dynamic>>()
          .map(PmtilesFile.fromJson)
          .toList()
        ..sort((a, b) => b.addedAt.compareTo(a.addedAt));

      _log.success('📋 Manifest loaded', data: 'count=${files.length}');
      for (final file in files) {
        _log.trace(
          '📄 catalog entry',
          data: 'id=${file.id} name="${file.name}" size=${formatBytes(file.sizeBytes)}',
        );
      }
      return files;
    } catch (error, stackTrace) {
      _log.error(
        '📋 Failed to load manifest',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<String?> activeFileId() async {
    final activeId = await _readPreference(AppConstants.activePmtilesIdKey);
    _log.debug('🎯 Active PMTiles id', data: activeId ?? '(none)');
    return activeId;
  }

  /// Validates catalog/active-file state and repairs common persistence gaps.
  Future<void> repairPersistence() async {
    _log.info('🔧 Repairing PMTiles persistence');
    final storedIds = await _store.listStoredIds();
    var files = await listFiles();

    if (files.isEmpty && storedIds.isNotEmpty) {
      _log.warn(
        '🔧 IndexedDB has tile blobs but manifest is empty — rebuilding catalog',
        data: 'storedIds=${storedIds.length}',
      );
      files = storedIds.map(_fileFromStoredId).toList()
        ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
      await _saveManifest(files);
    }

    files = files.where((file) => storedIds.contains(file.id)).toList();
    if (files.length != (await listFiles()).length) {
      _log.warn(
        '🔧 Removed manifest entries missing from storage',
        data: 'remaining=${files.length}',
      );
      await _saveManifest(files);
    }

    if (files.isEmpty) {
      await clearActiveFile();
      _log.info('🔧 No persisted PMTiles catalog entries');
      return;
    }

    final activeId = await activeFileId();
    if (activeId != null && storedIds.contains(activeId)) {
      _log.success('🔧 Active PMTiles file verified', data: activeId);
      return;
    }

    if (activeId != null) {
      _log.warn('🔧 Active id missing from storage — selecting replacement', data: activeId);
    } else {
      _log.warn('🔧 No active PMTiles id — selecting from catalog');
    }

    await setActiveFile(files.first.id);
    _log.success('🔧 Restored active PMTiles file', data: files.first.id);
  }

  Future<PmtilesFile?> activeFile() async {
    final activeId = await activeFileId();
    if (activeId == null) return null;

    final files = await listFiles();
    for (final file in files) {
      if (file.id == activeId) {
        _log.debug('🎯 Active PMTiles file resolved', data: '"${file.name}"');
        return file;
      }
    }

    _log.warn(
      '🎯 Active id not found in manifest',
      data: 'activeId=$activeId',
    );
    return null;
  }

  Future<PmtilesSource?> resolveActiveSource() async {
    _log.debug('🧭 Resolving active PMTiles source');

    if (AppConstants.pmtilesPath.isNotEmpty) {
      _log.info(
        '🧭 Using dart-define PMTILES_PATH override',
        data: AppConstants.pmtilesPath,
      );
      return PmtilesSourcePath(AppConstants.pmtilesPath);
    }

    final activeId = await activeFileId();
    if (activeId == null) {
      final files = await listFiles();
      if (files.isEmpty) {
        _log.warn('🧭 No active PMTiles file configured');
        return null;
      }
      _log.warn('🧭 No active id — using first catalog entry', data: files.first.id);
      await setActiveFile(files.first.id);
      return resolveActiveSource();
    }

    final localPath = await _store.localPath(activeId);
    if (localPath != null) {
      _log.success('🧭 Resolved filesystem source', data: localPath);
      return PmtilesSourcePath(localPath);
    }

    _log.debug('🧭 No local path — loading bytes from storage', data: activeId);
    final bytes = await _store.read(activeId);
    if (bytes == null) {
      _log.error(
        '🧭 Active file bytes missing from storage',
        data: 'activeId=$activeId',
      );
      final files = await listFiles();
      for (final file in files) {
        if (file.id == activeId) continue;
        final alternateBytes = await _store.read(file.id);
        if (alternateBytes != null) {
          _log.warn('🧭 Falling back to alternate stored file', data: file.id);
          await setActiveFile(file.id);
          return PmtilesSourceBytes(alternateBytes);
        }
      }
      return null;
    }

    _log.success(
      '🧭 Resolved in-memory source',
      data: 'activeId=$activeId size=${formatBytes(bytes.length)}',
    );
    return PmtilesSourceBytes(bytes);
  }

  Future<PmtilesFile> uploadFile(PlatformFile file) async {
    _log.info(
      '📤 Upload started',
      data: describePlatformFile(file),
    );

    final name = file.name;
    if (!_isPmtilesFile(name)) {
      _log.error('📤 Invalid file extension', data: 'name="$name"');
      throw FormatException('Only .pmtiles files are supported.');
    }

    late final Uint8List bytes;
    try {
      bytes = await _readFileBytes(file);
      _log.success(
        '📤 File bytes read',
        data: 'bytes=${bytes.length} (${formatBytes(bytes.length)})',
      );
    } catch (error, stackTrace) {
      _log.error(
        '📤 Failed to read file bytes',
        error: error,
        stackTrace: stackTrace,
        data: describePlatformFile(file),
      );
      rethrow;
    }

    if (bytes.isEmpty) {
      _log.error('📤 File is empty after read', data: 'name="$name"');
      throw FormatException('The selected file is empty.');
    }

    final entry = PmtilesFile(
      id: _createId(name),
      name: name,
      sizeBytes: bytes.length,
      addedAt: DateTime.now().toUtc(),
    );
    _log.info(
      '📤 Created catalog entry',
      data: 'id=${entry.id} size=${formatBytes(entry.sizeBytes)}',
    );

    try {
      _log.debug('💾 Writing bytes to platform storage', data: entry.id);
      await _store.write(entry.id, bytes);
      _log.success('💾 Storage write complete', data: entry.id);
    } catch (error, stackTrace) {
      _log.error(
        '💾 Storage write failed',
        error: error,
        stackTrace: stackTrace,
        data: 'id=${entry.id} size=${formatBytes(bytes.length)}',
      );
      rethrow;
    }

    try {
      final files = [entry, ...(await listFiles())];
      await _saveManifest(files);
      _log.success(
        '📋 Manifest updated',
        data: 'totalFiles=${files.length}',
      );
    } catch (error, stackTrace) {
      _log.error(
        '📋 Manifest update failed — rolling back storage write',
        error: error,
        stackTrace: stackTrace,
        data: entry.id,
      );
      try {
        await _store.delete(entry.id);
        _log.warn('🗑️ Rolled back storage write after manifest failure', data: entry.id);
      } catch (rollbackError, rollbackStack) {
        _log.error(
          '🗑️ Rollback failed — orphaned storage entry may remain',
          error: rollbackError,
          stackTrace: rollbackStack,
          data: entry.id,
        );
      }
      rethrow;
    }

    final activeId = await activeFileId();
    if (activeId == null) {
      _log.info('🎯 Setting uploaded file as active', data: entry.id);
      await setActiveFile(entry.id);
    } else {
      _log.debug('🎯 Keeping existing active file', data: activeId);
    }

    _log.success(
      '📤 Upload complete',
      data: 'name="${entry.name}" id=${entry.id}',
    );
    return entry;
  }

  Future<void> setActiveFile(String id) async {
    _log.info('🎯 Setting active PMTiles file', data: id);
    await _writePreference(AppConstants.activePmtilesIdKey, id);
    _log.success('🎯 Active file updated', data: id);
  }

  Future<void> clearActiveFile() async {
    _log.info('🎯 Clearing active PMTiles file');
    await _removePreference(AppConstants.activePmtilesIdKey);
    _log.success('🎯 Active file cleared');
  }

  Future<void> deleteFile(String id) async {
    _log.info('🗑️ Delete requested', data: id);
    try {
      await _store.delete(id);
      _log.success('💾 Storage entry deleted', data: id);
    } catch (error, stackTrace) {
      _log.error(
        '💾 Storage delete failed',
        error: error,
        stackTrace: stackTrace,
        data: id,
      );
      rethrow;
    }

    final files = await listFiles();
    files.removeWhere((file) => file.id == id);
    await _saveManifest(files);
    _log.success('📋 Manifest updated after delete', data: 'remaining=${files.length}');

    final activeId = await activeFileId();
    if (activeId == id) {
      if (files.isEmpty) {
        await clearActiveFile();
      } else {
        await setActiveFile(files.first.id);
      }
    }
    _log.success('🗑️ Delete complete', data: id);
  }

  Future<void> _saveManifest(List<PmtilesFile> files) async {
    _log.debug('📋 Saving manifest', data: 'count=${files.length}');
    final encoded = jsonEncode(files.map((file) => file.toJson()).toList());
    await _writePreference(AppConstants.pmtilesManifestKey, encoded);
    _log.trace('📋 Manifest JSON length', data: encoded.length);
  }

  Future<String?> _readPreference(String key) async {
    if (kIsWeb) {
      final meta = await _store.readMeta(key);
      if (meta != null && meta.isNotEmpty) {
        return meta;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key);
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }

  Future<void> _writePreference(String key, String value) async {
    if (kIsWeb) {
      await _store.writeMeta(key, value);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> _removePreference(String key) async {
    if (kIsWeb) {
      await _store.deleteMeta(key);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  PmtilesFile _fileFromStoredId(String id) {
    final parts = id.split('_');
    final timestamp = parts.isNotEmpty ? int.tryParse(parts.first) : null;
    final rawName = parts.length > 2 ? parts.sublist(2).join('_') : id;
    final name = rawName.toLowerCase().endsWith('.pmtiles') ? rawName : '$rawName.pmtiles';
    return PmtilesFile(
      id: id,
      name: name,
      sizeBytes: 0,
      addedAt: timestamp != null
          ? DateTime.fromMicrosecondsSinceEpoch(timestamp, isUtc: true)
          : DateTime.now().toUtc(),
    );
  }

  Future<Uint8List> _readFileBytes(PlatformFile file) async {
    _log.debug(
      '📥 Reading PlatformFile bytes',
      data: describePlatformFile(file),
    );

    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      _log.error(
        '📥 PlatformFile.bytes unavailable',
        data: {
          ...describePlatformFile(file),
          'hint':
              'Ensure FilePicker uses withData: true; large files may exceed memory limits on web',
        },
      );
      throw StateError(
        'Could not read the selected file. Try choosing the file again.',
      );
    }
    return bytes;
  }

  bool _isPmtilesFile(String name) {
    return name.toLowerCase().endsWith('.pmtiles');
  }

  String _createId(String name) {
    // Avoid `1 << 32` — on JS/web it evaluates to 0 and breaks Random.nextInt.
    final random = Random().nextInt(1000000000);
    final safeName = name.replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
    return '${DateTime.now().microsecondsSinceEpoch}_${random}_$safeName';
  }
}
