import 'package:serverpod/serverpod.dart';

import '../core/endpoint_logging.dart';
import '../generated/protocol.dart';
import 'tide_coastal_regions.dart';
import 'tide_extremes.dart';
import 'tide_harmonic_predict.dart';
import 'tide_noaa_import.dart';
import 'tide_storage.dart';

class TidesEndpoint extends Endpoint with EndpointLogging {
  static const _tag = 'tides';

  TideStorage get _storage => TideStorage();

  Future<List<TidePackInfo>> listPacks(Session session) {
    return loggedCall(
      session,
      _tag,
      'listPacks',
      () async {
        final packs = await _storage.listPacks();
        return packs.map(_toPackInfo).toList();
      },
      onSuccess: (packs) => 'count=${packs.length}',
    );
  }

  Future<List<TideCoastalRegion>> listCoastalRegions(Session session) {
    return loggedCall(
      session,
      _tag,
      'listCoastalRegions',
      () async => [
        for (final region in TideCoastalRegions.all)
          TideCoastalRegion(
            id: region.id,
            name: region.name,
            minLatitude: region.minLatitude,
            minLongitude: region.minLongitude,
            maxLatitude: region.maxLatitude,
            maxLongitude: region.maxLongitude,
          ),
      ],
      onSuccess: (regions) => 'count=${regions.length}',
    );
  }

  Future<TidePackInfo> importCoastalRegion(Session session, String regionId) {
    return loggedCall(
      session,
      _tag,
      'importCoastalRegion',
      () async {
        final region = TideCoastalRegions.byId(regionId);
        if (region == null) {
          throw FormatException(
            'Unknown coastal region "$regionId". '
            'Call listCoastalRegions() for valid ids.',
          );
        }
        final pack = await TideNoaaImport.importCoastalRegion(
          region,
          storage: _storage,
        );
        return _toPackInfo(pack);
      },
      onSuccess: (pack) =>
          'id=${pack.id} stations=${pack.stationCount} active=${pack.isActive}',
    );
  }

  Future<TidePackInfo> setPackActive(
    Session session,
    String packId,
    bool active,
  ) {
    return loggedCall(
      session,
      _tag,
      'setPackActive',
      () async {
        final pack = await _storage.setPackActive(packId.trim(), active);
        return _toPackInfo(pack);
      },
      onSuccess: (pack) => 'id=${pack.id} active=${pack.isActive}',
    );
  }

  Future<bool> deletePack(Session session, String packId) {
    return loggedCall(
      session,
      _tag,
      'deletePack',
      () => _storage.deletePack(packId.trim()),
      onSuccess: (deleted) =>
          deleted ? 'deleted id=$packId' : 'not found id=$packId',
    );
  }

  Future<TideQueryResult> queryAt(
    Session session,
    double lat,
    double lng,
    DateTime date, {
    int hours = 24,
  }) {
    return loggedCall(
      session,
      _tag,
      'queryAt',
      () async {
        if (hours < 1 || hours > 168) {
          throw const FormatException('hours must be between 1 and 168.');
        }

        final active = await _storage.listActivePacks();
        if (active.isEmpty) {
          final any = await _storage.listPacks();
          if (any.isEmpty) {
            throw const FormatException(
              'No tide packs installed. Import a coastal region first '
              '(importCoastalRegion).',
            );
          }
          throw const FormatException(
            'No active tide packs. Enable a pack with setPackActive.',
          );
        }

        final nearest = _storage.nearestStation(
          active,
          latitude: lat,
          longitude: lng,
        );
        if (nearest == null) {
          throw const FormatException(
            'No tide stations found in active packs.',
          );
        }

        final dayStart = DateTime.utc(date.year, date.month, date.day);
        final windowStart = hours == 24
            ? dayStart
            : date.toUtc().subtract(Duration(minutes: (hours * 60) ~/ 2));
        const step = Duration(minutes: 6);
        final sampleCount = (hours * 60) ~/ 6 + 1;

        final series = predictTideSeries(
          start: windowStart,
          count: sampleCount,
          step: step,
          meanLevelMeters: nearest.station.meanLevelMeters,
          constituents: nearest.station.constituents,
        );

        final extremes = hours == 24
            ? findTideExtremesForDay(
                dayStartUtc: dayStart,
                meanLevelMeters: nearest.station.meanLevelMeters,
                constituents: nearest.station.constituents,
              )
            : findTideExtremesInSeries(series);

        final distanceKm = nearest.distanceMeters / 1000.0;
        final message = distanceKm >= 1
            ? 'Nearest station is ${distanceKm.toStringAsFixed(1)} km away. '
                  'Heights are approximate harmonic predictions.'
            : 'Heights are approximate harmonic predictions.';

        return TideQueryResult(
          station: TideStationInfo(
            id: nearest.station.id,
            name: nearest.station.name,
            latitude: nearest.station.lat,
            longitude: nearest.station.lng,
            distanceMeters: nearest.distanceMeters,
          ),
          datum: nearest.pack.datum,
          units: nearest.pack.units,
          samples: [
            for (final s in series)
              TideSample(time: s.time, heightMeters: s.heightMeters),
          ],
          extremes: [
            for (final e in extremes)
              TideExtreme(
                time: e.time,
                heightMeters: e.heightMeters,
                type: e.type,
              ),
          ],
          approximate: true,
          message: message,
        );
      },
      onSuccess: (result) =>
          'station=${result.station.id} samples=${result.samples.length} '
          'extremes=${result.extremes.length}',
    );
  }

  TidePackInfo _toPackInfo(TidePackRecord pack) {
    return TidePackInfo(
      id: pack.id,
      name: pack.name,
      source: pack.source,
      datum: pack.datum,
      units: pack.units,
      stationCount: pack.stationCount,
      sizeBytes: pack.sizeBytes,
      addedAt: pack.importedAt,
      isActive: pack.isActive,
      minLatitude: pack.minLatitude,
      minLongitude: pack.minLongitude,
      maxLatitude: pack.maxLatitude,
      maxLongitude: pack.maxLongitude,
    );
  }
}
