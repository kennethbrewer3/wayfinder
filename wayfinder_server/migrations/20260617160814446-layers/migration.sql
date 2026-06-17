BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "map_layer" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "name" text NOT NULL,
    "sortOrder" bigint NOT NULL,
    "visible" boolean NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "map_layer_sort_order_idx" ON "map_layer" USING btree ("sortOrder");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "map_marker" ADD COLUMN "layerId" uuid;
CREATE INDEX "map_marker_layer_id_idx" ON "map_marker" USING btree ("layerId");
--
-- ACTION ALTER TABLE
--
ALTER TABLE "map_zone" ADD COLUMN "layerId" uuid;
CREATE INDEX "map_zone_layer_id_idx" ON "map_zone" USING btree ("layerId");

--
-- ACTION SEED DEFAULT LAYER
--
INSERT INTO "map_layer" ("id", "name", "sortOrder", "visible", "createdAt", "updatedAt")
VALUES (
  '00000000-0000-4000-8000-000000000001',
  'Default',
  0,
  true,
  now(),
  now()
);

UPDATE "map_marker"
SET "layerId" = '00000000-0000-4000-8000-000000000001'
WHERE "layerId" IS NULL;

UPDATE "map_zone"
SET "layerId" = '00000000-0000-4000-8000-000000000001'
WHERE "layerId" IS NULL;

--
-- MIGRATION VERSION FOR wayfinder
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('wayfinder', '20260617160814446-layers', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260617160814446-layers', "timestamp" = now();

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
