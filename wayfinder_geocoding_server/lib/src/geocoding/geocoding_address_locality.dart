import 'package:serverpod/serverpod.dart';

/// Resolves a human-readable locality label for a street address coordinate.
abstract final class GeocodingAddressLocality {
  static Future<String?> resolve(
    Session session, {
    required double latitude,
    required double longitude,
  }) async {
    final rows = await session.db.unsafeQuery(
      '''
SELECT
  "displayName",
  "name",
  "countryCode"
FROM "geocode_place"
WHERE "latitude" BETWEEN @minLat AND @maxLat
  AND "longitude" BETWEEN @minLon AND @maxLon
  AND "featureClass" IS DISTINCT FROM 'highway'
  AND (
    "featureClass" = 'place'
    OR "displayName" LIKE '%,%'
  )
ORDER BY
  CASE WHEN "featureClass" = 'place' THEN 0 ELSE 1 END,
  (power("latitude" - @lat, 2) + power("longitude" - @lon, 2))
LIMIT 1
''',
      parameters: QueryParameters.named({
        'lat': latitude,
        'lon': longitude,
        'minLat': latitude - 0.35,
        'maxLat': latitude + 0.35,
        'minLon': longitude - 0.35,
        'maxLon': longitude + 0.35,
      }),
    );

    if (rows.isEmpty) {
      return null;
    }

    final displayName = rows.first[0] as String?;
    if (displayName != null && displayName.trim().isNotEmpty) {
      return displayName.trim();
    }

    final name = rows.first[1] as String?;
    final countryCode = rows.first[2] as String?;
    if (name == null || name.trim().isEmpty) {
      return null;
    }
    if (countryCode == null || countryCode.trim().isEmpty) {
      return name.trim();
    }
    return '${name.trim()}, ${countryCode.trim().toUpperCase()}';
  }

  static String formatCoordinates(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
  }
}
