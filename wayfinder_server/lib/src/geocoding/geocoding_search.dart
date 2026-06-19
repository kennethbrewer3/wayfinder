import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'geocoding_constants.dart';

abstract final class GeocodingSearch {
  static Future<List<GeocodeSearchResult>> search(
    Session session, {
    required String query,
    int limit = GeocodingConstants.maxSearchResults,
  }) async {
    final trimmed = query.trim();
    if (trimmed.length < GeocodingConstants.minSearchLength) {
      return const [];
    }

    final settings = await GeocodingSettings.db.findFirstRow(session);
    if (settings == null) {
      return const [];
    }

    final placesReady = settings.importStatus ==
            GeocodingConstants.statusCompleted &&
        settings.importedRowCount > 0;
    final addressesReady = settings.housenumbersImportStatus ==
            GeocodingConstants.statusCompleted &&
        settings.housenumbersImportedRowCount > 0;
    if (!placesReady && !addressesReady) {
      return const [];
    }

    final pattern = '%${_escapeLike(trimmed)}%';
    final results = <GeocodeSearchResult>[];
    final addressLimit = addressesReady && _looksLikeAddress(trimmed)
        ? (limit / 2).ceil()
        : addressesReady
            ? (limit / 3).ceil()
            : 0;

    if (addressesReady && addressLimit > 0) {
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

      for (final row in addressRows) {
        final housenumber = row[1] as String;
        final street = row[2] as String;
        final label = '$housenumber $street';
        results.add(
          GeocodeSearchResult(
            id: row[0] as int,
            name: label,
            displayName: street,
            latitude: row[4] as double,
            longitude: row[3] as double,
            importance: 0.85,
            resultType: GeocodingConstants.resultTypeAddress,
          ),
        );
      }
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

    return results;
  }

  static bool _looksLikeAddress(String input) {
    return RegExp(r'\d').hasMatch(input);
  }

  static String _escapeLike(String input) {
    return input
        .replaceAll('\\', '\\\\')
        .replaceAll('%', '\\%')
        .replaceAll('_', '\\_');
  }
}
