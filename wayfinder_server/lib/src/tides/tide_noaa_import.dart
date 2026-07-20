import 'dart:convert';
import 'dart:io';

import '../core/wayfinder_log.dart';
import 'tide_coastal_regions.dart';
import 'tide_harmonic_predict.dart';
import 'tide_storage.dart';

/// Downloads NOAA CO-OPS harmonic tide packs into [TideStorage].
abstract final class TideNoaaImport {
  static const _tag = 'tides';
  static const _stationsUrl =
      'https://api.tidesandcurrents.noaa.gov/mdapi/prod/webapi/stations.json'
      '?type=tidepredictions';
  static const _maxStations = 80;
  static const _feetToMeters = 0.3048;

  static String harconUrl(String stationId) =>
      'https://api.tidesandcurrents.noaa.gov/mdapi/prod/webapi/stations/'
      '$stationId/harcon.json';

  /// Import a curated coastal region as a tide pack (pack id = region id).
  static Future<TidePackRecord> importCoastalRegion(
    TideCoastalRegionDef region, {
    TideStorage? storage,
  }) {
    return importBbox(
      packId: region.id,
      name: region.name,
      minLatitude: region.minLatitude,
      minLongitude: region.minLongitude,
      maxLatitude: region.maxLatitude,
      maxLongitude: region.maxLongitude,
      storage: storage,
    );
  }

  /// Fetch NOAA stations in [bbox], cap at [_maxStations] nearest center,
  /// download harmonic constituents, and save the pack.
  static Future<TidePackRecord> importBbox({
    required String packId,
    required String name,
    required double minLatitude,
    required double minLongitude,
    required double maxLatitude,
    required double maxLongitude,
    TideStorage? storage,
  }) async {
    final store = storage ?? TideStorage();
    await store.ensureReady();

    WfLog.info(
      null,
      _tag,
      '🌊 NOAA import started "$name" | pack=$packId | '
      'bbox=[$minLatitude,$minLongitude]-[$maxLatitude,$maxLongitude]',
    );

    final stationsJson = await _getJson(_stationsUrl);
    final rawStations = (stationsJson['stations'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();

    final centerLat = (minLatitude + maxLatitude) / 2;
    final centerLng = (minLongitude + maxLongitude) / 2;

    final inBbox = <_NoaaStationMeta>[];
    for (final raw in rawStations) {
      final lat = (raw['lat'] as num?)?.toDouble();
      final lng = (raw['lng'] as num?)?.toDouble();
      final id = raw['id']?.toString();
      final stationName = raw['name']?.toString();
      if (lat == null || lng == null || id == null || stationName == null) {
        continue;
      }
      if (lat < minLatitude ||
          lat > maxLatitude ||
          lng < minLongitude ||
          lng > maxLongitude) {
        continue;
      }
      inBbox.add(
        _NoaaStationMeta(
          id: id,
          name: stationName,
          lat: lat,
          lng: lng,
          timezone: raw['timezone']?.toString() ?? 'UTC',
          distanceToCenter: TideStorage.haversineMeters(
            centerLat,
            centerLng,
            lat,
            lng,
          ),
        ),
      );
    }

    inBbox.sort((a, b) => a.distanceToCenter.compareTo(b.distanceToCenter));
    final selected = inBbox.length <= _maxStations
        ? inBbox
        : inBbox.sublist(0, _maxStations);

    if (selected.isEmpty) {
      throw FormatException(
        'No NOAA tide-prediction stations found in region "$name".',
      );
    }

    WfLog.info(
      null,
      _tag,
      '🌊 NOAA stations selected | inBbox=${inBbox.length} '
      'importing=${selected.length}',
    );

    final stations = <TideStationRecord>[];
    for (final meta in selected) {
      try {
        final station = await _fetchStation(meta);
        if (station != null) {
          stations.add(station);
        }
      } on Object catch (e) {
        WfLog.warn(
          null,
          _tag,
          '🌊 Skipping station ${meta.id} (${meta.name}): $e',
        );
      }
    }

    if (stations.isEmpty) {
      throw FormatException(
        'Failed to download harmonic constituents for region "$name".',
      );
    }

    final existing = await store.listPacks();
    final isFirstPack = existing.isEmpty;
    // Re-import preserves prior isActive; first pack on the server is active.
    final prior = existing.where((p) => p.id == packId).firstOrNull;
    final toSave = TidePackRecord(
      id: packId,
      name: name,
      source: 'NOAA CO-OPS',
      datum: 'MLLW',
      units: 'meters',
      stationCount: stations.length,
      sizeBytes: 0,
      importedAt: prior?.importedAt ?? DateTime.now().toUtc(),
      isActive: prior?.isActive ?? isFirstPack,
      minLatitude: minLatitude,
      minLongitude: minLongitude,
      maxLatitude: maxLatitude,
      maxLongitude: maxLongitude,
      stations: stations,
    );

    final saved = await store.savePack(toSave);
    WfLog.success(
      null,
      _tag,
      '🌊 NOAA import complete "$name" | stations=${saved.stationCount} '
      'active=${saved.isActive}',
    );
    return saved;
  }

  static Future<TideStationRecord?> _fetchStation(_NoaaStationMeta meta) async {
    final json = await _getJson(harconUrl(meta.id));
    final units = (json['units'] as String?)?.toLowerCase() ?? 'feet';
    final rawConsts =
        (json['HarmonicConstituents'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>();
    if (rawConsts.isEmpty) {
      return null;
    }

    final convertFeet = units.contains('feet') || units.contains('foot');
    final constituents = <TideConstituent>[];
    for (final raw in rawConsts) {
      final name = raw['name']?.toString();
      final amplitude = (raw['amplitude'] as num?)?.toDouble();
      final phase = (raw['phase_GMT'] as num?)?.toDouble();
      final speed = (raw['speed'] as num?)?.toDouble();
      if (name == null || amplitude == null || phase == null || speed == null) {
        continue;
      }
      final amplitudeMeters = convertFeet
          ? amplitude * _feetToMeters
          : amplitude;
      constituents.add(
        TideConstituent(
          name: name,
          amplitudeMeters: amplitudeMeters,
          phaseGmtDeg: phase,
          speedDegPerHour: speed,
        ),
      );
    }

    if (constituents.isEmpty) {
      return null;
    }

    return TideStationRecord(
      id: meta.id,
      name: meta.name,
      lat: meta.lat,
      lng: meta.lng,
      timezone: meta.timezone,
      meanLevelMeters: 0,
      constituents: constituents,
    );
  }

  static Future<Map<String, dynamic>> _getJson(String url) async {
    final uri = Uri.parse(url);
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 60);
    client.idleTimeout = const Duration(minutes: 2);
    try {
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'NOAA API returned HTTP ${response.statusCode}',
          uri: uri,
        );
      }
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw FormatException('NOAA response was not a JSON object: $url');
      }
      return decoded;
    } finally {
      client.close(force: true);
    }
  }
}

class _NoaaStationMeta {
  const _NoaaStationMeta({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.timezone,
    required this.distanceToCenter,
  });

  final String id;
  final String name;
  final double lat;
  final double lng;
  final String timezone;
  final double distanceToCenter;
}
