BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "app_settings" ADD COLUMN "darkMapTilesInDarkMode" boolean NOT NULL DEFAULT true;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "user_client_preferences" ADD COLUMN "darkMapTilesInDarkMode" boolean NOT NULL DEFAULT true;

--
-- MIGRATION VERSION FOR wayfinder
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('wayfinder', '20260723180519607-dark-map-tiles-pref', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260723180519607-dark-map-tiles-pref', "timestamp" = now();

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
