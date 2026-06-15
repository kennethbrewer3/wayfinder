import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/constants.dart';
import '../../../core/logging/app_logger.dart';
import 'pmtiles_file_store.dart';

class IoPmtilesFileStore extends PmtilesFileStore {
  static final _log = AppLogger.logStorage;

  Future<Directory> _directory() async {
    final base = await getApplicationDocumentsDirectory();
    final directory = Directory(
      p.join(base.path, AppConstants.pmtilesDirectoryName),
    );
    if (!directory.existsSync()) {
      _log.info('📁 Creating PMTiles directory', data: directory.path);
      directory.createSync(recursive: true);
    }
    return directory;
  }

  Future<File> _file(String id) async {
    final directory = await _directory();
    return File(p.join(directory.path, '$id.pmtiles'));
  }

  @override
  Future<void> write(String id, Uint8List bytes) async {
    final file = await _file(id);
    _log.info(
      '💾 [io] write started',
      data: 'path=${file.path} size=${formatBytes(bytes.length)}',
    );
    try {
      await file.writeAsBytes(bytes, flush: true);
      _log.success('💾 [io] write complete', data: file.path);
    } catch (error, stackTrace) {
      _log.error(
        '💾 [io] write failed',
        error: error,
        stackTrace: stackTrace,
        data: file.path,
      );
      rethrow;
    }
  }

  @override
  Future<Uint8List?> read(String id) async {
    final file = await _file(id);
    _log.debug('📥 [io] read started', data: file.path);
    if (!file.existsSync()) {
      _log.warn('📥 [io] read miss — file not found', data: file.path);
      return null;
    }
    try {
      final bytes = await file.readAsBytes();
      _log.success(
        '📥 [io] read hit',
        data: 'path=${file.path} size=${formatBytes(bytes.length)}',
      );
      return bytes;
    } catch (error, stackTrace) {
      _log.error(
        '📥 [io] read failed',
        error: error,
        stackTrace: stackTrace,
        data: file.path,
      );
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    final file = await _file(id);
    _log.info('🗑️ [io] delete started', data: file.path);
    if (file.existsSync()) {
      try {
        await file.delete();
        _log.success('🗑️ [io] delete complete', data: file.path);
      } catch (error, stackTrace) {
        _log.error(
          '🗑️ [io] delete failed',
          error: error,
          stackTrace: stackTrace,
          data: file.path,
        );
        rethrow;
      }
    } else {
      _log.warn('🗑️ [io] delete skipped — file not found', data: file.path);
    }
  }

  @override
  Future<bool> exists(String id) async {
    final file = await _file(id);
    return file.existsSync();
  }

  @override
  Future<Set<String>> listStoredIds() async {
    final directory = await _directory();
    if (!directory.existsSync()) return {};
    return directory
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.pmtiles'))
        .map((file) => p.basenameWithoutExtension(file.path))
        .toSet();
  }

  @override
  Future<String?> localPath(String id) => filePath(id);

  Future<String?> filePath(String id) async {
    final file = await _file(id);
    if (!file.existsSync()) return null;
    return file.path;
  }
}

PmtilesFileStore createPlatformPmtilesFileStore() {
  AppLogger.logStorage.info('🏗️ Creating IoPmtilesFileStore (filesystem backend)');
  return IoPmtilesFileStore();
}
