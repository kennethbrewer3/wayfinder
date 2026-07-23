BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "user_client_preferences" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "authUserId" uuid NOT NULL,
    "measurementUnits" text NOT NULL DEFAULT 'metric'::text,
    "angleDisplayFormat" text NOT NULL DEFAULT 'decimal'::text,
    "bearingReference" text NOT NULL DEFAULT 'true'::text,
    "circleSizeDisplay" text NOT NULL DEFAULT 'radius'::text,
    "appTheme" text NOT NULL DEFAULT 'light'::text,
    "appLocale" text NOT NULL DEFAULT 'system'::text,
    "mapMarkerSizeScale" double precision NOT NULL DEFAULT 1.0,
    "mapViewportDebugBorder" boolean NOT NULL DEFAULT false,
    "mapTileBorderDebug" boolean NOT NULL DEFAULT false,
    "mapCompassRoseEnabled" boolean NOT NULL DEFAULT true,
    "mapMgrsGridEnabled" boolean NOT NULL DEFAULT false,
    "polygonSnapRightAngles" boolean NOT NULL DEFAULT true,
    "polygonSnap45Angles" boolean NOT NULL DEFAULT false,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "user_client_preferences_auth_user_idx" ON "user_client_preferences" USING btree ("authUserId");

-- Seed one prefs row per existing membership from current TOC AppSettings defaults.
INSERT INTO "user_client_preferences" (
    "authUserId",
    "measurementUnits",
    "angleDisplayFormat",
    "bearingReference",
    "circleSizeDisplay",
    "appTheme",
    "appLocale",
    "mapMarkerSizeScale",
    "mapViewportDebugBorder",
    "mapTileBorderDebug",
    "mapCompassRoseEnabled",
    "mapMgrsGridEnabled",
    "polygonSnapRightAngles",
    "polygonSnap45Angles",
    "updatedAt"
)
SELECT
    m."authUserId",
    COALESCE(s."measurementUnits", 'metric'),
    COALESCE(s."angleDisplayFormat", 'decimal'),
    COALESCE(s."bearingReference", 'true'),
    COALESCE(s."circleSizeDisplay", 'radius'),
    COALESCE(s."appTheme", 'light'),
    COALESCE(s."appLocale", 'system'),
    COALESCE(s."mapMarkerSizeScale", 1.0),
    COALESCE(s."mapViewportDebugBorder", false),
    COALESCE(s."mapTileBorderDebug", false),
    COALESCE(s."mapCompassRoseEnabled", true),
    COALESCE(s."mapMgrsGridEnabled", false),
    COALESCE(s."polygonSnapRightAngles", true),
    COALESCE(s."polygonSnap45Angles", false),
    now()
FROM "user_membership" m
LEFT JOIN "app_settings" s ON true
ON CONFLICT ("authUserId") DO NOTHING;

--
-- MIGRATION VERSION FOR wayfinder
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('wayfinder', '20260723164055395-user-client-preferences', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260723164055395-user-client-preferences', "timestamp" = now();

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
