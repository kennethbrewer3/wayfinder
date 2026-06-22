import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../core/wayfinder_log.dart';
import '../generated/protocol.dart';
import 'geocoding_constants.dart';
import 'geocoding_housenumbers_importer.dart';
import 'geocoding_import_control.dart';
import 'geocoding_import_exceptions.dart';
import 'geocoding_import_status.dart';
import 'geocoding_remote_fetch.dart';
import 'geocoding_settings_store.dart';
import 'geocoding_staging_store.dart';

abstract final class GeocodingImporter {
  static bool _running = false;
  static int _previousImportedRowCount = 0;
  static DateTime? _previousImportedAt;

  static bool get isRunning => _running;

  static Future<GeocodingSettings> startImport(
    Session session, {
    String? sourceUrl,
    List<String>? countryCodes,
  }) async {
    if (_running) {
      throw StateError('A geocoding import is already running.');
    }
    if (GeocodingHousenumbersImporter.isRunning) {
      throw StateError('A housenumbers import is already running.');
    }

    final settings = await GeocodingSettingsStore.getOrCreate(session);
    final url = (sourceUrl ?? settings.sourceUrl).trim();
    if (url.isEmpty) {
      throw FormatException('Geocoding source URL is required.');
    }
    _validateUrl(url);

    final normalizedCodes = _normalizeCountryCodes(countryCodes);
    final codesValue = normalizedCodes == null || normalizedCodes.isEmpty
        ? null
        : normalizedCodes.join(',');

    _previousImportedRowCount = settings.importedRowCount;
    _previousImportedAt = settings.importedAt;

    final updated = await GeocodingSettingsStore.update(
      session,
      settings.copyWith(
        sourceUrl: url,
        countryCodes: codesValue,
        importStatus: GeocodingConstants.statusDownloading,
        importedRowCount: 0,
        importProgress: 0,
        importError: null,
        importedAt: null,
      ),
    );

    final serverpod = session.serverpod;
    unawaited(_runImport(serverpod, url, countryFilter: normalizedCodes));
    return updated;
  }

  static Future<GeocodingSettings> cancelImport(Session session) async {
    final settings = await GeocodingSettingsStore.getOrCreate(session);

    if (_running) {
      GeocodingImportControl.requestCancel();
      return settings;
    }

    if (!GeocodingImportStatus.isActive(settings.importStatus)) {
      throw StateError('No place-name import is running.');
    }

    return _abortStaleImport(session, settings);
  }

  static Future<GeocodingSettings> _abortStaleImport(
    Session session,
    GeocodingSettings settings,
  ) async {
    await GeocodingStagingStore.discardPlacesStaging(session);
    final liveCount = await GeocodePlace.db.count(session);

    if (liveCount > 0) {
      return GeocodingSettingsStore.update(
        session,
        settings.copyWith(
          importStatus: GeocodingConstants.statusCompleted,
          importedRowCount: liveCount,
          importProgress: 1,
          importError: null,
          importedAt: settings.importedAt ?? DateTime.now().toUtc(),
        ),
      );
    }

    return GeocodingSettingsStore.update(
      session,
      settings.copyWith(
        importStatus: GeocodingConstants.statusCancelled,
        importedRowCount: 0,
        importProgress: 0,
        importError: 'Import cancelled.',
        importedAt: null,
      ),
    );
  }

  static Future<void> _runImport(
    Serverpod serverpod,
    String url, {
    Set<String>? countryFilter,
  }) async {
    _running = true;
    GeocodingImportControl.begin();
    try {
      final session = await serverpod.createSession();
      try {
        await GeocodingStagingStore.preparePlacesStaging(session);
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
          var processedBytes = 0;
          final lineStream = response
              .transform(gzip.decoder)
              .transform(utf8.decoder)
              .transform(const LineSplitter());

          final batch = <GeocodePlace>[];
          var isHeader = true;

          await for (final line in lineStream) {
            GeocodingImportControl.checkCancelled();
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

            final place = _parseLine(line, countryFilter: countryFilter);
            if (place == null) {
              continue;
            }

            batch.add(place);
            if (batch.length >= GeocodingConstants.importBatchSize) {
              importedRows += await _insertBatch(serverpod, batch);
              batch.clear();

              if (importedRows % GeocodingConstants.progressUpdateInterval ==
                  0) {
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
        },
        onClientCreated: GeocodingImportControl.attachClient,
      );

      GeocodingImportControl.checkCancelled();

      final commitSession = await serverpod.createSession();
      try {
        await GeocodingStagingStore.commitPlacesImport(commitSession);
        await GeocodingSettingsStore.update(
          commitSession,
          (await GeocodingSettingsStore.getOrCreate(commitSession)).copyWith(
            importStatus: GeocodingConstants.statusCompleted,
            importedRowCount: importedRows,
            importProgress: 1,
            importError: null,
            importedAt: DateTime.now().toUtc(),
          ),
        );
      } finally {
        await commitSession.close();
      }

      WfLog.success(
        null,
        'geocoding',
        '🌍 Geocoding import completed rows=$importedRows url=$url',
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
        '🌍 Geocoding import failed',
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
      await GeocodingStagingStore.discardPlacesStaging(session);
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

    WfLog.info(null, 'geocoding', '🌍 Geocoding import cancelled');
  }

  static Future<void> _handleFailure(
    Serverpod serverpod,
    Object error,
  ) async {
    final session = await serverpod.createSession();
    try {
      await GeocodingStagingStore.discardPlacesStaging(session);
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
    List<GeocodePlace> batch,
  ) async {
    GeocodingImportControl.checkCancelled();
    final session = await serverpod.createSession();
    try {
      await GeocodingStagingStore.insertPlacesBatch(session, batch);
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
        importStatus: importStatus,
        importedRowCount: importedRowCount ?? settings.importedRowCount,
        importProgress: importProgress ?? settings.importProgress,
        importError: importError,
        importedAt: importedAt ?? settings.importedAt,
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

  static GeocodePlace? _parseLine(
    String line, {
    Set<String>? countryFilter,
  }) {
    if (line.isEmpty) {
      return null;
    }

    final columns = line.split('\t');
    if (columns.length < 17) {
      return null;
    }

    final name = columns[0].trim();
    if (name.isEmpty) {
      return null;
    }

    final longitude = double.tryParse(columns[6]);
    final latitude = double.tryParse(columns[7]);
    final placeRank = int.tryParse(columns[8]);
    final importance = double.tryParse(columns[9]);
    if (longitude == null ||
        latitude == null ||
        placeRank == null ||
        importance == null) {
      return null;
    }

    final displayName = _optional(columns[16]);
    final countryCode = _optional(columns[15]);
    if (countryFilter != null &&
        countryFilter.isNotEmpty &&
        (countryCode == null ||
            !countryFilter.contains(countryCode.toUpperCase()))) {
      return null;
    }
    final featureClass = _optional(columns[4]);
    final featureType = _optional(columns[5]);

    return GeocodePlace(
      name: name,
      displayName: displayName,
      latitude: latitude,
      longitude: longitude,
      placeRank: placeRank,
      importance: importance,
      countryCode: countryCode,
      featureClass: featureClass,
      featureType: featureType,
    );
  }

  static String? _optional(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static void _validateUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw FormatException('Invalid geocoding source URL: $url');
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      throw FormatException('Geocoding source URL must use http or https.');
    }
  }

  static Set<String>? _normalizeCountryCodes(List<String>? countryCodes) {
    if (countryCodes == null || countryCodes.isEmpty) {
      return null;
    }

    final normalized = countryCodes
        .map((code) => code.trim().toUpperCase())
        .where((code) => code.length == 2)
        .toSet();
    return normalized.isEmpty ? null : normalized;
  }
}
