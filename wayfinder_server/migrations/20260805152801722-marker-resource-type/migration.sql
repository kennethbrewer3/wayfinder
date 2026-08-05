BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "map_marker" ADD COLUMN "resourceType" text;
CREATE INDEX "map_marker_resource_type_idx" ON "map_marker" USING btree ("resourceType");

-- Best-effort backfill from known resource icons (do not map generic "water").
UPDATE "map_marker" SET "resourceType" = 'well'
  WHERE "resourceType" IS NULL AND "icon" = 'water_well';
UPDATE "map_marker" SET "resourceType" = 'cache'
  WHERE "resourceType" IS NULL
    AND "icon" IN ('supply_cache', 'medical_cache', 'ammo_cache');
UPDATE "map_marker" SET "resourceType" = 'fuel'
  WHERE "resourceType" IS NULL AND "icon" IN ('fuel', 'fuel_depot');
UPDATE "map_marker" SET "resourceType" = 'clinic'
  WHERE "resourceType" IS NULL AND "icon" = 'clinic';

--
-- MIGRATION VERSION FOR wayfinder
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('wayfinder', '20260805152801722-marker-resource-type', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260805152801722-marker-resource-type', "timestamp" = now();

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
