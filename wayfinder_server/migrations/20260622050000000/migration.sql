BEGIN;

--
-- Align pmtiles_group.showOnMap with Serverpod schema expectations.
--
ALTER TABLE "pmtiles_group"
  ALTER COLUMN "showOnMap" SET DEFAULT false;

UPDATE "pmtiles_group"
SET "showOnMap" = false
WHERE "showOnMap" IS NULL;

INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('wayfinder', '20260622050000000', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260622050000000', "timestamp" = now();

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
