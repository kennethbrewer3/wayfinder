import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../core/wayfinder_log.dart';
import '../generated/protocol.dart';
import 'geocoding_constants.dart';
import 'geocoding_download_progress.dart';
import 'geocoding_importer.dart';
import 'geocoding_import_control.dart';
import 'geocoding_import_exceptions.dart';
import 'geocoding_import_status.dart';
import 'geocoding_remote_fetch.dart';
import 'geocoding_settings_store.dart';
import 'geocoding_staging_store.dart';

abstract final class GeocodingHousenumbersImporter {
  static bool _running = false;
  static int _previousImportedRowCount = 0;
  static DateTime? _previousImportedAt;

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

    _previousImportedRowCount = settings.housenumbersImportedRowCount;
    _previousImportedAt = settings.housenumbersImportedAt;

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
    WfLog.info(
      session,
      'geocoding',
      '🏠 Starting housenumbers import url=$url',
    );
    unawaited(_runImport(serverpod, url));
    return updated;
  }

  static Future<GeocodingSettings> cancelImport(Session session) async {
    final settings = await GeocodingSettingsStore.getOrCreate(session);

    if (_running) {
      GeocodingImportControl.requestCancel();
      return settings;
    }

    if (!GeocodingImportStatus.isActive(settings.housenumbersImportStatus)) {
      throw StateError('No housenumbers import is running.');
    }

    return _abortStaleImport(session, settings);
  }

  static Future<GeocodingSettings> _abortStaleImport(
    Session session,
    GeocodingSettings settings,
  ) async {
    await GeocodingStagingStore.discardHousenumbersStaging(session);
    final liveCount = await GeocodeHousenumber.db.count(session);

    if (liveCount > 0) {
      return GeocodingSettingsStore.update(
        session,
        settings.copyWith(
          housenumbersImportStatus: GeocodingConstants.statusCompleted,
          housenumbersImportedRowCount: liveCount,
          housenumbersImportProgress: 1,
          housenumbersImportError: null,
          housenumbersImportedAt:
              settings.housenumbersImportedAt ?? DateTime.now().toUtc(),
        ),
      );
    }

    return GeocodingSettingsStore.update(
      session,
      settings.copyWith(
        housenumbersImportStatus: GeocodingConstants.statusCancelled,
        housenumbersImportedRowCount: 0,
        housenumbersImportProgress: 0,
        housenumbersImportError: 'Import cancelled.',
        housenumbersImportedAt: null,
      ),
    );
  }

  static Future<void> _runImport(
    Serverpod serverpod,
    String url,
  ) async {
    _running = true;
    GeocodingImportControl.begin();
    try {
      final session = await serverpod.createSession();
      try {
        await GeocodingStagingStore.prepareHousenumbersStaging(session);
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
      await GeocodingRemoteFetch.withDownload(
        url,
        (response) async {
          final totalBytes = response.contentLength;
          final progress = GeocodingDownloadProgress(
            serverpod: serverpod,
            logLabel: 'housenumbers',
            totalBytes: totalBytes,
            updateStatus: ({
              required String importStatus,
              required int importedRowCount,
              required double importProgress,
            }) =>
                _updateProgress(
              serverpod,
              importStatus: importStatus,
              importedRowCount: importedRowCount,
              importProgress: importProgress,
            ),
          );
          final lineStream = response
              .transform(gzip.decoder)
              .transform(utf8.decoder)
              .transform(const LineSplitter());

          final batch = <GeocodeHousenumber>[];
          var isHeader = true;

          await for (final line in lineStream) {
            GeocodingImportControl.checkCancelled();
            progress.addLineBytes(line.length);
            await progress.maybeReport(
              importStatus: isHeader
                  ? GeocodingConstants.statusDownloading
                  : GeocodingConstants.statusImporting,
              phase: isHeader ? 'download' : 'import',
            );
            if (isHeader) {
              isHeader = false;
              await _updateProgress(
                serverpod,
                importStatus: GeocodingConstants.statusImporting,
                importedRowCount: 0,
                importProgress: progress.computeProgress().clamp(0.01, 0.99),
              );
              WfLog.info(
                null,
                'geocoding',
                '🏠 Housenumbers import started parsing rows '
                'totalBytes=${totalBytes >= 0 ? GeocodingDownloadProgress.formatBytes(totalBytes) : 'unknown'}',
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
              progress.importedRows = importedRows;
              batch.clear();

              if (importedRows % GeocodingConstants.progressUpdateInterval ==
                  0) {
                await _updateProgress(
                  serverpod,
                  importStatus: GeocodingConstants.statusImporting,
                  importedRowCount: importedRows,
                  importProgress: progress.computeProgress(),
                );
              }
            }
          }

          if (batch.isNotEmpty) {
            importedRows += await _insertBatch(serverpod, batch);
            progress.importedRows = importedRows;
          }
        },
        onClientCreated: GeocodingImportControl.attachClient,
        logLabel: 'housenumbers',
      );

      GeocodingImportControl.checkCancelled();

      final commitSession = await serverpod.createSession();
      try {
        await GeocodingStagingStore.commitHousenumbersImport(commitSession);
        await GeocodingSettingsStore.update(
          commitSession,
          (await GeocodingSettingsStore.getOrCreate(commitSession)).copyWith(
            housenumbersImportStatus: GeocodingConstants.statusCompleted,
            housenumbersImportedRowCount: importedRows,
            housenumbersImportProgress: 1,
            housenumbersImportError: null,
            housenumbersImportedAt: DateTime.now().toUtc(),
          ),
        );
      } finally {
        await commitSession.close();
      }

      WfLog.success(
        null,
        'geocoding',
        '🏠 Housenumbers import completed rows=$importedRows url=$url',
      );
    } on ImportCancelledException {
      await _handleCancelled(serverpod);
    } catch (error, stackTrace) {
      if (GeocodingImportControl.cancelRequested) {
        await _handleCancelled(serverpod);
        return;
      }
      WfLog.error(
        null,
        'geocoding',
        '🏠 Housenumbers import failed',
        error: error,
        stackTrace: stackTrace,
      );
      await _handleFailure(serverpod, error);
    } finally {
      _running = false;
      GeocodingImportControl.end();
    }
  }

  static Future<void> _handleCancelled(Serverpod serverpod) async {
    final session = await serverpod.createSession();
    try {
      await GeocodingStagingStore.discardHousenumbersStaging(session);
      await _setStatus(
        session,
        importStatus: GeocodingConstants.statusCancelled,
        importedRowCount: _previousImportedRowCount,
        importProgress: 0,
        importError: 'Import cancelled.',
        importedAt: _previousImportedAt,
      );
    } finally {
      await session.close();
    }

    WfLog.info(null, 'geocoding', '🏠 Housenumbers import cancelled');
  }

  static Future<void> _handleFailure(
    Serverpod serverpod,
    Object error,
  ) async {
    final session = await serverpod.createSession();
    try {
      await GeocodingStagingStore.discardHousenumbersStaging(session);
      await _setStatus(
        session,
        importStatus: GeocodingConstants.statusFailed,
        importedRowCount: _previousImportedRowCount,
        importProgress: 0,
        importError: error.toString(),
        importedAt: _previousImportedAt,
      );
    } finally {
      await session.close();
    }
  }

  static Future<int> _insertBatch(
    Serverpod serverpod,
    List<GeocodeHousenumber> batch,
  ) async {
    GeocodingImportControl.checkCancelled();
    final session = await serverpod.createSession();
    try {
      await GeocodingStagingStore.insertHousenumbersBatch(session, batch);
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
    GeocodingImportControl.checkCancelled();
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
    DateTime? importedAt,
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
        housenumbersImportedAt: importedAt ?? settings.housenumbersImportedAt,
      ),
    );
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
