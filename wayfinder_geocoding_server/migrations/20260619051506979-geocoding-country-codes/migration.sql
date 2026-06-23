BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "geocoding_settings" ADD COLUMN "countryCodes" text;

--
-- MIGRATION VERSION FOR wayfinder
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('wayfinder', '20260619051506979-geocoding-country-codes', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260619051506979-geocoding-country-codes', "timestamp" = now();

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
