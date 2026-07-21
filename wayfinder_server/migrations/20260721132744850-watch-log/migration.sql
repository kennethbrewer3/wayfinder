BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "watch_log_entry" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "occurredAt" timestamp without time zone NOT NULL,
    "author" text,
    "severity" text NOT NULL,
    "text" text NOT NULL,
    "markerId" uuid,
    "zoneId" uuid,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "watch_log_occurred_at_idx" ON "watch_log_entry" USING btree ("occurredAt");
CREATE INDEX "watch_log_marker_id_idx" ON "watch_log_entry" USING btree ("markerId");
CREATE INDEX "watch_log_zone_id_idx" ON "watch_log_entry" USING btree ("zoneId");


--
-- MIGRATION VERSION FOR wayfinder
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('wayfinder', '20260721132744850-watch-log', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260721132744850-watch-log', "timestamp" = now();

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
