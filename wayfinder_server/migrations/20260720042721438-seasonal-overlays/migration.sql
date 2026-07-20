BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "seasonal_overlay" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "name" text NOT NULL,
    "color" text NOT NULL,
    "borderColor" text NOT NULL,
    "fillColor" text NOT NULL,
    "visible" boolean NOT NULL,
    "notes" text,
    "dateMode" text NOT NULL,
    "dateWindowsJson" text NOT NULL,
    "geometryJson" text NOT NULL,
    "sortOrder" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "seasonal_overlay_sort_order_idx" ON "seasonal_overlay" USING btree ("sortOrder");


--
-- MIGRATION VERSION FOR wayfinder
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('wayfinder', '20260720042721438-seasonal-overlays', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260720042721438-seasonal-overlays', "timestamp" = now();

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
