BEGIN;

CREATE TABLE "geocode_place_staging" (
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

CREATE TABLE "geocode_housenumber_staging" (
    "id" bigserial PRIMARY KEY,
    "streetId" text NOT NULL,
    "street" text NOT NULL,
    "housenumber" text NOT NULL,
    "latitude" double precision NOT NULL,
    "longitude" double precision NOT NULL
);

INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('wayfinder_geocoding', '20260621210000000', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260621210000000', "timestamp" = now();

INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260129180959368', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129180959368', "timestamp" = now();

INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260213194423028', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260213194423028', "timestamp" = now();

INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260129181112269', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129181112269', "timestamp" = now();

COMMIT;
