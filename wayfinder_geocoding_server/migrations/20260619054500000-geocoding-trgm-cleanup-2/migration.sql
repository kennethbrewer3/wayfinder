BEGIN;

--
-- Drop trigram indexes managed outside Serverpod's schema model.
-- They are recreated at server startup for geocoding search performance.
--
DROP INDEX IF EXISTS "geocode_place_name_trgm_idx";
DROP INDEX IF EXISTS "geocode_place_display_name_trgm_idx";

--
-- MIGRATION VERSION FOR wayfinder_geocoding
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('wayfinder_geocoding', '20260619054500000-geocoding-trgm-cleanup-2', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260619054500000-geocoding-trgm-cleanup-2', "timestamp" = now();

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
