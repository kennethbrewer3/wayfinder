BEGIN;

--
-- Registers search-index schema expectations with Serverpod.
-- Trigram indexes are built at server startup by GeocodingSearchIndexes.ensureReady()
-- so they are not created here (CREATE INDEX on millions of rows cannot run safely
-- inside a migration transaction).
--

INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('wayfinder', '20260622000000000-geocoding-search-indexes', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260622000000000-geocoding-search-indexes', "timestamp" = now();

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
