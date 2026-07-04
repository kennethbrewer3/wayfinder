BEGIN;

ALTER TABLE "app_settings"
  ADD COLUMN IF NOT EXISTS "mapMarkerSizeScale" double precision NOT NULL DEFAULT 1.0;

ALTER TABLE "app_settings"
  ADD COLUMN IF NOT EXISTS "mapViewportDebugBorder" boolean NOT NULL DEFAULT false;

ALTER TABLE "app_settings"
  ADD COLUMN IF NOT EXISTS "mapTileBorderDebug" boolean NOT NULL DEFAULT false;

INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('wayfinder', '20260705120000000', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260705120000000', "timestamp" = now();

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
