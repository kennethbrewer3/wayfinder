import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Staging tables keep live geocoding data intact until an import succeeds.
abstract final class GeocodingStagingStore {
  /// Creates staging tables when missing (e.g. DB migrated past the staging
  /// migration without applying it, or migrations not yet run on first boot).
  static Future<void> ensureStagingTablesReady(Session session) async {
    await session.db.unsafeExecute('''
CREATE TABLE IF NOT EXISTS "geocode_place_staging" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "displayName" text,
    "latitude" double precision NOT NULL,
    "longitude" double precision NOT NULL,
    "placeRank" bigint NOT NULL,
    "importance" double precision NOT NULL,
    "countryCode" text,
    "featureClass" text,
    "featureType" text
);

CREATE TABLE IF NOT EXISTS "geocode_housenumber_staging" (
    "id" bigserial PRIMARY KEY,
    "streetId" text NOT NULL,
    "street" text NOT NULL,
    "housenumber" text NOT NULL,
    "latitude" double precision NOT NULL,
    "longitude" double precision NOT NULL
);
''');
  }

  static Future<void> preparePlacesStaging(Session session) async {
    await ensureStagingTablesReady(session);
    await session.db.unsafeExecute(
      'TRUNCATE "geocode_place_staging" RESTART IDENTITY',
    );
  }

  static Future<void> prepareHousenumbersStaging(Session session) async {
    await ensureStagingTablesReady(session);
    await session.db.unsafeExecute(
      'TRUNCATE "geocode_housenumber_staging" RESTART IDENTITY',
    );
  }

  static Future<void> insertPlacesBatch(
    Session session,
    List<GeocodePlace> batch,
  ) async {
    if (batch.isEmpty) {
      return;
    }

    await ensureStagingTablesReady(session);
    final values = batch.map(_placeValues).join(',\n');
    await session.db.unsafeExecute('''
INSERT INTO "geocode_place_staging" (
  "name",
  "displayName",
  "latitude",
  "longitude",
  "placeRank",
  "importance",
  "countryCode",
  "featureClass",
  "featureType"
)
VALUES
$values
''');
  }

  static Future<void> insertHousenumbersBatch(
    Session session,
    List<GeocodeHousenumber> batch,
  ) async {
    if (batch.isEmpty) {
      return;
    }

    await ensureStagingTablesReady(session);
    final values = batch.map(_housenumberValues).join(',\n');
    await session.db.unsafeExecute('''
INSERT INTO "geocode_housenumber_staging" (
  "streetId",
  "street",
  "housenumber",
  "latitude",
  "longitude"
)
VALUES
$values
''');
  }

  static Future<void> commitPlacesImport(Session session) async {
    await ensureStagingTablesReady(session);
    await session.db.transaction((transaction) async {
      await session.db.unsafeExecute(
        'TRUNCATE "geocode_place" RESTART IDENTITY',
        transaction: transaction,
      );
      await session.db.unsafeExecute(
        '''
INSERT INTO "geocode_place" (
  "name",
  "displayName",
  "latitude",
  "longitude",
  "placeRank",
  "importance",
  "countryCode",
  "featureClass",
  "featureType"
)
SELECT
  "name",
  "displayName",
  "latitude",
  "longitude",
  "placeRank",
  "importance",
  "countryCode",
  "featureClass",
  "featureType"
FROM "geocode_place_staging"
''',
        transaction: transaction,
      );
      await session.db.unsafeExecute(
        'TRUNCATE "geocode_place_staging" RESTART IDENTITY',
        transaction: transaction,
      );
    });
  }

  static Future<void> commitHousenumbersImport(Session session) async {
    await ensureStagingTablesReady(session);
    await session.db.transaction((transaction) async {
      await session.db.unsafeExecute(
        'TRUNCATE "geocode_housenumber" RESTART IDENTITY',
        transaction: transaction,
      );
      await session.db.unsafeExecute(
        '''
INSERT INTO "geocode_housenumber" (
  "streetId",
  "street",
  "housenumber",
  "latitude",
  "longitude"
)
SELECT
  "streetId",
  "street",
  "housenumber",
  "latitude",
  "longitude"
FROM "geocode_housenumber_staging"
''',
        transaction: transaction,
      );
      await session.db.unsafeExecute(
        'TRUNCATE "geocode_housenumber_staging" RESTART IDENTITY',
        transaction: transaction,
      );
    });
  }

  static Future<void> discardPlacesStaging(Session session) async {
    await ensureStagingTablesReady(session);
    await session.db.unsafeExecute(
      'TRUNCATE "geocode_place_staging" RESTART IDENTITY',
    );
  }

  static Future<void> discardHousenumbersStaging(Session session) async {
    await ensureStagingTablesReady(session);
    await session.db.unsafeExecute(
      'TRUNCATE "geocode_housenumber_staging" RESTART IDENTITY',
    );
  }

  static String _placeValues(GeocodePlace place) {
    return '''
(
  ${_sqlString(place.name)},
  ${_sqlNullable(place.displayName)},
  ${place.latitude},
  ${place.longitude},
  ${place.placeRank},
  ${place.importance},
  ${_sqlNullable(place.countryCode)},
  ${_sqlNullable(place.featureClass)},
  ${_sqlNullable(place.featureType)}
)''';
  }

  static String _housenumberValues(GeocodeHousenumber address) {
    return '''
(
  ${_sqlString(address.streetId)},
  ${_sqlString(address.street)},
  ${_sqlString(address.housenumber)},
  ${address.latitude},
  ${address.longitude}
)''';
  }

  static String _sqlString(String value) {
    return "'${value.replaceAll("'", "''")}'";
  }

  static String _sqlNullable(String? value) {
    if (value == null) {
      return 'NULL';
    }
    return _sqlString(value);
  }
}
