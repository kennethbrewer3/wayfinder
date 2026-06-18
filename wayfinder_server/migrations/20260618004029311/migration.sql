BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "pmtiles_file" ADD COLUMN "minZoom" bigint;
ALTER TABLE "pmtiles_file" ADD COLUMN "maxZoom" bigint;
ALTER TABLE "pmtiles_file" ADD COLUMN "minLatitude" double precision;
ALTER TABLE "pmtiles_file" ADD COLUMN "minLongitude" double precision;
ALTER TABLE "pmtiles_file" ADD COLUMN "maxLatitude" double precision;
ALTER TABLE "pmtiles_file" ADD COLUMN "maxLongitude" double precision;

--
-- MIGRATION VERSION FOR wayfinder
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('wayfinder', '20260618004029311', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260618004029311', "timestamp" = now();

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
