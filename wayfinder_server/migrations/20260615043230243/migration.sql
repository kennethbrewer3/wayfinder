BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "category" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "parentId" uuid,
    "name" text NOT NULL,
    "sortOrder" bigint NOT NULL
);

-- Indexes
CREATE INDEX "category_name_idx" ON "category" USING btree ("name");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "map_marker" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "name" text NOT NULL,
    "notes" text,
    "latitude" double precision NOT NULL,
    "longitude" double precision NOT NULL,
    "color" text NOT NULL,
    "icon" text NOT NULL,
    "visible" boolean NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "map_marker_name_idx" ON "map_marker" USING btree ("name");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "map_zone" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "name" text NOT NULL,
    "type" text NOT NULL,
    "color" text NOT NULL,
    "borderColor" text NOT NULL,
    "borderPattern" text NOT NULL,
    "fillColor" text NOT NULL,
    "visible" boolean NOT NULL,
    "geometryJson" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "map_zone_name_idx" ON "map_zone" USING btree ("name");
CREATE INDEX "map_zone_type_idx" ON "map_zone" USING btree ("type");


--
-- MIGRATION VERSION FOR wayfinder
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('wayfinder', '20260615043230243', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260615043230243', "timestamp" = now();

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
