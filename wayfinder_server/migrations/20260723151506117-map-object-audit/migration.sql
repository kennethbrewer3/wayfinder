BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "map_marker" ADD COLUMN "createdByAuthUserId" uuid;
ALTER TABLE "map_marker" ADD COLUMN "createdByUsername" text;
ALTER TABLE "map_marker" ADD COLUMN "updatedByAuthUserId" uuid;
ALTER TABLE "map_marker" ADD COLUMN "updatedByUsername" text;
ALTER TABLE "map_marker" ADD COLUMN "deletedAt" timestamp without time zone;
ALTER TABLE "map_marker" ADD COLUMN "deletedByAuthUserId" uuid;
ALTER TABLE "map_marker" ADD COLUMN "deletedByUsername" text;
CREATE INDEX "map_marker_deleted_at_idx" ON "map_marker" USING btree ("deletedAt");
--
-- ACTION CREATE TABLE
--
CREATE TABLE "map_object_audit_event" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "entityType" text NOT NULL,
    "entityId" uuid NOT NULL,
    "entityName" text,
    "action" text NOT NULL,
    "actorAuthUserId" uuid,
    "actorUsername" text,
    "snapshotJson" text,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "map_object_audit_created_at_idx" ON "map_object_audit_event" USING btree ("createdAt");
CREATE INDEX "map_object_audit_entity_idx" ON "map_object_audit_event" USING btree ("entityType", "entityId");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "map_zone" ADD COLUMN "createdByAuthUserId" uuid;
ALTER TABLE "map_zone" ADD COLUMN "createdByUsername" text;
ALTER TABLE "map_zone" ADD COLUMN "updatedByAuthUserId" uuid;
ALTER TABLE "map_zone" ADD COLUMN "updatedByUsername" text;
ALTER TABLE "map_zone" ADD COLUMN "deletedAt" timestamp without time zone;
ALTER TABLE "map_zone" ADD COLUMN "deletedByAuthUserId" uuid;
ALTER TABLE "map_zone" ADD COLUMN "deletedByUsername" text;
CREATE INDEX "map_zone_deleted_at_idx" ON "map_zone" USING btree ("deletedAt");

--
-- MIGRATION VERSION FOR wayfinder
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('wayfinder', '20260723151506117-map-object-audit', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260723151506117-map-object-audit', "timestamp" = now();

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
