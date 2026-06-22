BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "geocode_housenumber" (
    "id" bigserial PRIMARY KEY,
    "streetId" text NOT NULL,
    "street" text NOT NULL,
    "housenumber" text NOT NULL,
    "latitude" double precision NOT NULL,
    "longitude" double precision NOT NULL
);

-- Indexes
CREATE INDEX "geocode_housenumber_street_idx" ON "geocode_housenumber" USING btree ("street");
CREATE INDEX "geocode_housenumber_housenumber_idx" ON "geocode_housenumber" USING btree ("housenumber");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "geocoding_settings" ADD COLUMN "housenumbersSourceUrl" text NOT NULL DEFAULT 'https://github.com/OSMNames/OSMNames/releases/download/v2.0.4/planet-latest_housenumbers.tsv.gz'::text;
ALTER TABLE "geocoding_settings" ADD COLUMN "housenumbersImportStatus" text NOT NULL DEFAULT 'idle'::text;
ALTER TABLE "geocoding_settings" ADD COLUMN "housenumbersImportedRowCount" bigint NOT NULL DEFAULT 0;
ALTER TABLE "geocoding_settings" ADD COLUMN "housenumbersImportProgress" double precision NOT NULL DEFAULT 0;
ALTER TABLE "geocoding_settings" ADD COLUMN "housenumbersImportError" text;
ALTER TABLE "geocoding_settings" ADD COLUMN "housenumbersImportedAt" timestamp without time zone;

--
-- MIGRATION VERSION FOR wayfinder
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('wayfinder', '20260619060749227', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260619060749227', "timestamp" = now();

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
