import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'geocoding_address_locality.dart';
import 'geocoding_address_query.dart';
import 'geocoding_constants.dart';
import 'geocoding_import_status.dart';
import 'geocoding_search_ranking.dart';

abstract final class GeocodingSearch {
  static Future<List<GeocodeSearchResult>> search(
    Session session, {
    required String query,
    int limit = GeocodingConstants.maxSearchResults,
    double? nearLatitude,
    double? nearLongitude,
  }) async {
    final trimmed = query.trim();
    if (trimmed.length < GeocodingConstants.minSearchLength) {
      return const [];
    }

    final settings = await GeocodingSettings.db.findFirstRow(session);
    if (settings == null) {
      return const [];
    }

    final placesReady = GeocodingImportStatus.isSearchable(
      settings.importStatus,
      settings.importedRowCount,
    );
    final addressesReady = GeocodingImportStatus.isSearchable(
      settings.housenumbersImportStatus,
      settings.housenumbersImportedRowCount,
    );
    final contributionCount = await GeocodeContribution.db.count(session);
    final contributionsReady = contributionCount > 0;
    if (!placesReady && !addressesReady && !contributionsReady) {
      return const [];
    }

    final pattern = '%${_escapeLike(trimmed)}%';
    final results = <GeocodeSearchResult>[];
    final addressLimit = addressesReady && _looksLikeAddress(trimmed)
        ? (limit / 2).ceil()
        : 0;

    if (addressesReady && addressLimit > 0) {
      final parsedAddress = parseAddressSearchQuery(trimmed);
      if (parsedAddress != null) {
        final structured = buildStructuredAddressSearch(parsedAddress);
        final structuredRows = await session.db.unsafeQuery(
          '${structured.sql}\nLIMIT @limit',
          parameters: QueryParameters.named({
            ...structured.parameters,
            'limit': addressLimit,
          }),
        );
        _appendAddressRows(results, structuredRows);
      }

      if (results.isEmpty) {
        final addressRows = await session.db.unsafeQuery(
          '''
        SELECT
          "id",
          "housenumber",
          "street",
          "latitude",
          "longitude"
        FROM "geocode_housenumber"
        WHERE "street" ILIKE @pattern ESCAPE '\\'
           OR "housenumber" ILIKE @pattern ESCAPE '\\'
           OR ("housenumber" || ' ' || "street") ILIKE @pattern ESCAPE '\\'
           OR ("street" || ' ' || "housenumber") ILIKE @pattern ESCAPE '\\'
        ORDER BY
          CASE
            WHEN ("housenumber" || ' ' || "street") ILIKE @pattern ESCAPE '\\'
              THEN 0
            WHEN ("street" || ' ' || "housenumber") ILIKE @pattern ESCAPE '\\'
              THEN 1
            ELSE 2
          END,
          "street",
          "housenumber"
        LIMIT @limit
        ''',
          parameters: QueryParameters.named({
            'pattern': pattern,
            'limit': addressLimit,
          }),
        );
        _appendAddressRows(results, addressRows);
      }

      await _finalizeAddressResults(
        session,
        results,
        nearLatitude: nearLatitude,
        nearLongitude: nearLongitude,
      );
    }

    final remaining = limit - results.length;
    if (placesReady && remaining > 0) {
      final placeRows = await session.db.unsafeQuery(
        '''
        SELECT
          "id",
          "name",
          "displayName",
          "latitude",
          "longitude",
          "countryCode",
          "importance"
        FROM "geocode_place"
        WHERE "name" ILIKE @pattern ESCAPE '\\'
           OR "displayName" ILIKE @pattern ESCAPE '\\'
        ORDER BY "importance" DESC, "placeRank" ASC
        LIMIT @limit
        ''',
        parameters: QueryParameters.named({
          'pattern': pattern,
          'limit': remaining,
        }),
      );

      for (final row in placeRows) {
        results.add(
          GeocodeSearchResult(
            id: row[0] as int,
            name: row[1] as String,
            displayName: row[2] as String?,
            latitude: row[3] as double,
            longitude: row[4] as double,
            countryCode: row[5] as String?,
            importance: row[6] as double,
            resultType: GeocodingConstants.resultTypePlace,
          ),
        );
      }
    }

    final remainingAfterPlaces = limit - results.length;
    if (contributionsReady && remainingAfterPlaces > 0) {
      final contributionRows = await session.db.unsafeQuery(
        '''
        SELECT
          "id",
          "name",
          "notes",
          "latitude",
          "longitude",
          "countryCode"
        FROM "geocode_contribution"
        WHERE "name" ILIKE @pattern ESCAPE '\\'
           OR "notes" ILIKE @pattern ESCAPE '\\'
        ORDER BY "name"
        LIMIT @limit
        ''',
        parameters: QueryParameters.named({
          'pattern': pattern,
          'limit': remainingAfterPlaces,
        }),
      );

      for (final row in contributionRows) {
        final notes = row[2] as String?;
        results.add(
          GeocodeSearchResult(
            id: row[0] as int,
            name: row[1] as String,
            displayName: notes,
            latitude: row[3] as double,
            longitude: row[4] as double,
            countryCode: row[5] as String?,
            importance: 0.95,
            resultType: GeocodingConstants.resultTypeContribution,
          ),
        );
      }
    }

    return results;
  }

  static bool _looksLikeAddress(String input) {
    return RegExp(r'\d').hasMatch(input);
  }

  static void _appendAddressRows(
    List<GeocodeSearchResult> results,
    List<List<dynamic>> rows,
  ) {
    for (final row in rows) {
      final housenumber = row[1] as String;
      final street = row[2] as String;
      final label = '$housenumber $street';
      results.add(
        GeocodeSearchResult(
          id: row[0] as int,
          name: label,
          displayName: null,
          latitude: row[4] as double,
          longitude: row[3] as double,
          importance: 0.85,
          resultType: GeocodingConstants.resultTypeAddress,
        ),
      );
    }
  }

  static Future<void> _finalizeAddressResults(
    Session session,
    List<GeocodeSearchResult> results, {
    double? nearLatitude,
    double? nearLongitude,
  }) async {
    final localityCache = <String, String?>{};

    for (var index = 0; index < results.length; index++) {
      final result = results[index];
      if (result.resultType != GeocodingConstants.resultTypeAddress) {
        continue;
      }

      final cacheKey =
          '${result.latitude.toStringAsFixed(3)}:${result.longitude.toStringAsFixed(3)}';
      localityCache[cacheKey] ??= await GeocodingAddressLocality.resolve(
        session,
        latitude: result.latitude,
        longitude: result.longitude,
      );
      final resolvedLocality = localityCache[cacheKey];
      results[index] = result.copyWith(
        displayName: resolvedLocality ??
            GeocodingAddressLocality.formatCoordinates(
              result.latitude,
              result.longitude,
            ),
      );
    }

    if (nearLatitude != null && nearLongitude != null) {
      sortAddressResultsByProximity(
        results,
        latitude: nearLatitude,
        longitude: nearLongitude,
      );
    }
  }

  static String _escapeLike(String input) {
    return input
        .replaceAll('\\', '\\\\')
        .replaceAll('%', '\\%')
        .replaceAll('_', '\\_');
  }
}
