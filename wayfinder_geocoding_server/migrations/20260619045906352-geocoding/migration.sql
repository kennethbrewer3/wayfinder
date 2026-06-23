BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "geocode_place" (
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

-- Indexes
CREATE INDEX "geocode_place_name_idx" ON "geocode_place" USING btree ("name");
CREATE INDEX "geocode_place_importance_idx" ON "geocode_place" USING btree ("importance");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "geocoding_settings" (
    "id" bigserial PRIMARY KEY,
    "sourceUrl" text NOT NULL,
    "importStatus" text NOT NULL DEFAULT 'idle'::text,
    "importedRowCount" bigint NOT NULL DEFAULT 0,
    "importProgress" double precision NOT NULL DEFAULT 0,
    "importError" text,
    "importedAt" timestamp without time zone,
    "updatedAt" timestamp without time zone NOT NULL
);


--
-- MIGRATION VERSION FOR wayfinder
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('wayfinder', '20260619045906352-geocoding', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260619045906352-geocoding', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260129180959368', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129180959368', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260213194423028', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260213194423028', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260129181112269', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129181112269', "timestamp" = now();


COMMIT;
