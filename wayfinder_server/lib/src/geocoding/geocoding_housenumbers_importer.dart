import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../core/wayfinder_log.dart';
import '../generated/protocol.dart';
import 'geocoding_constants.dart';
import 'geocoding_importer.dart';
import 'geocoding_remote_fetch.dart';
import 'geocoding_settings_store.dart';

abstract final class GeocodingHousenumbersImporter {
  static bool _running = false;

  static bool get isRunning => _running;

  static Future<GeocodingSettings> startImport(
    Session session, {
    String? sourceUrl,
  }) async {
    if (_running) {
      throw StateError('A housenumbers import is already running.');
    }
    if (GeocodingImporter.isRunning) {
      throw StateError('A place-name import is already running.');
    }

    final settings = await GeocodingSettingsStore.getOrCreate(session);
    final url = (sourceUrl ?? settings.housenumbersSourceUrl).trim();
    if (url.isEmpty) {
      throw FormatException('Housenumbers source URL is required.');
    }
    _validateUrl(url);

    final updated = await GeocodingSettingsStore.update(
      session,
      settings.copyWith(
        housenumbersSourceUrl: url,
        housenumbersImportStatus: GeocodingConstants.statusDownloading,
        housenumbersImportedRowCount: 0,
        housenumbersImportProgress: 0,
        housenumbersImportError: null,
        housenumbersImportedAt: null,
      ),
    );

    final serverpod = session.serverpod;
    unawaited(_runImport(serverpod, url));
    return updated;
  }

  static Future<void> _runImport(
    Serverpod serverpod,
    String url,
  ) async {
    _running = true;
    try {
      final session = await serverpod.createSession();
      try {
        await session.db
            .unsafeExecute('TRUNCATE "geocode_housenumber" RESTART IDENTITY');
        await _setStatus(
          session,
          importStatus: GeocodingConstants.statusDownloading,
          importedRowCount: 0,
          importProgress: 0,
          importError: null,
        );
      } finally {
        await session.close();
      }

      var importedRows = 0;
      await GeocodingRemoteFetch.withDownload(url, (response) async {
        final totalBytes = response.contentLength;
        var processedBytes = 0;
        final lineStream = response
            .transform(gzip.decoder)
            .transform(utf8.decoder)
            .transform(const LineSplitter());

        final batch = <GeocodeHousenumber>[];
        var isHeader = true;

        await for (final line in lineStream) {
          processedBytes += line.length + 1;
          if (isHeader) {
            isHeader = false;
            await _updateProgress(
              serverpod,
              importStatus: GeocodingConstants.statusImporting,
              importedRowCount: 0,
              importProgress: totalBytes > 0 ? 0.01 : 0,
            );
            continue;
          }

          final address = _parseLine(line);
          if (address == null) {
            continue;
          }

          batch.add(address);
          if (batch.length >= GeocodingConstants.importBatchSize) {
            importedRows += await _insertBatch(serverpod, batch);
            batch.clear();

            if (importedRows % GeocodingConstants.progressUpdateInterval == 0) {
              final progress = _downloadProgress(
                processedBytes: processedBytes,
                totalBytes: totalBytes,
                importedRows: importedRows,
              );
              await _updateProgress(
                serverpod,
                importStatus: GeocodingConstants.statusImporting,
                importedRowCount: importedRows,
                importProgress: progress,
              );
            }
          }
        }

        if (batch.isNotEmpty) {
          importedRows += await _insertBatch(serverpod, batch);
        }
      });

      final finishSession = await serverpod.createSession();
      try {
        await GeocodingSettingsStore.update(
          finishSession,
          (await GeocodingSettingsStore.getOrCreate(finishSession)).copyWith(
            housenumbersImportStatus: GeocodingConstants.statusCompleted,
            housenumbersImportedRowCount: importedRows,
            housenumbersImportProgress: 1,
            housenumbersImportError: null,
            housenumbersImportedAt: DateTime.now().toUtc(),
          ),
        );
      } finally {
        await finishSession.close();
      }

      WfLog.success(
        null,
        'geocoding',
        '🏠 Housenumbers import completed rows=$importedRows url=$url',
      );
    } catch (error, stackTrace) {
      WfLog.error(
        null,
        'geocoding',
        '🏠 Housenumbers import failed',
        error: error,
        stackTrace: stackTrace,
      );
      final errorSession = await serverpod.createSession();
      try {
        await _setStatus(
          errorSession,
          importStatus: GeocodingConstants.statusFailed,
          importError: error.toString(),
        );
      } finally {
        await errorSession.close();
      }
    } finally {
      _running = false;
    }
  }

  static Future<int> _insertBatch(
    Serverpod serverpod,
    List<GeocodeHousenumber> batch,
  ) async {
    final session = await serverpod.createSession();
    try {
      await GeocodeHousenumber.db.insert(session, batch);
      return batch.length;
    } finally {
      await session.close();
    }
  }

  static Future<void> _updateProgress(
    Serverpod serverpod, {
    required String importStatus,
    required int importedRowCount,
    required double importProgress,
  }) async {
    final session = await serverpod.createSession();
    try {
      await _setStatus(
        session,
        importStatus: importStatus,
        importedRowCount: importedRowCount,
        importProgress: importProgress,
      );
    } finally {
      await session.close();
    }
  }

  static Future<void> _setStatus(
    Session session, {
    required String importStatus,
    int? importedRowCount,
    double? importProgress,
    String? importError,
  }) async {
    final settings = await GeocodingSettingsStore.getOrCreate(session);
    await GeocodingSettingsStore.update(
      session,
      settings.copyWith(
        housenumbersImportStatus: importStatus,
        housenumbersImportedRowCount:
            importedRowCount ?? settings.housenumbersImportedRowCount,
        housenumbersImportProgress:
            importProgress ?? settings.housenumbersImportProgress,
        housenumbersImportError: importError,
      ),
    );
  }

  static double _downloadProgress({
    required int processedBytes,
    required int totalBytes,
    required int importedRows,
  }) {
    if (totalBytes > 0) {
      return (processedBytes / totalBytes).clamp(0, 0.99);
    }
    if (importedRows <= 0) {
      return 0;
    }
    return 0.5;
  }

  static GeocodeHousenumber? _parseLine(String line) {
    if (line.isEmpty) {
      return null;
    }

    final columns = line.split('\t');
    if (columns.length < 6) {
      return null;
    }

    final streetId = columns[1].trim();
    final street = columns[2].trim();
    final housenumber = columns[3].trim();
    final longitude = double.tryParse(columns[4]);
    final latitude = double.tryParse(columns[5]);
    if (streetId.isEmpty ||
        street.isEmpty ||
        housenumber.isEmpty ||
        longitude == null ||
        latitude == null) {
      return null;
    }

    return GeocodeHousenumber(
      streetId: streetId,
      street: street,
      housenumber: housenumber,
      latitude: latitude,
      longitude: longitude,
    );
  }

  static void _validateUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw FormatException('Invalid housenumbers source URL: $url');
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      throw FormatException('Housenumbers source URL must use http or https.');
    }
  }
}
