BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "pmtiles_file" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "name" text NOT NULL,
    "sizeBytes" bigint NOT NULL,
    "isActive" boolean NOT NULL,
    "addedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "pmtiles_file_name_idx" ON "pmtiles_file" USING btree ("name");


--
-- MIGRATION VERSION FOR wayfinder
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('wayfinder', '20260615140325241', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260615140325241', "timestamp" = now();

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
