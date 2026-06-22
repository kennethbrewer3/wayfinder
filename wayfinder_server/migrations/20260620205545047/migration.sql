BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "app_settings" (
    "id" bigserial PRIMARY KEY,
    "homeLatitude" double precision NOT NULL DEFAULT 38.903481,
    "homeLongitude" double precision NOT NULL DEFAULT -77.262817,
    "homeZoom" double precision NOT NULL DEFAULT 12.0,
    "updatedAt" timestamp without time zone NOT NULL
);


--
-- MIGRATION VERSION FOR wayfinder
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('wayfinder', '20260620205545047', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260620205545047', "timestamp" = now();

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
