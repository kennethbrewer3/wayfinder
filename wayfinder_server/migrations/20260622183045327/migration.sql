BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "app_settings" ADD COLUMN "measurementUnits" text NOT NULL DEFAULT 'metric'::text;
ALTER TABLE "app_settings" ADD COLUMN "angleDisplayFormat" text NOT NULL DEFAULT 'decimal'::text;
ALTER TABLE "app_settings" ADD COLUMN "circleSizeDisplay" text NOT NULL DEFAULT 'radius'::text;
ALTER TABLE "app_settings" ADD COLUMN "appTheme" text NOT NULL DEFAULT 'light'::text;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "pmtiles_group" ALTER COLUMN "showOnMap" SET DEFAULT false;

--
-- MIGRATION VERSION FOR wayfinder
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('wayfinder', '20260622183045327', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260622183045327', "timestamp" = now();

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
