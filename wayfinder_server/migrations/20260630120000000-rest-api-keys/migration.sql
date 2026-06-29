BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "rest_api_key" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "name" text NOT NULL,
    "keyHash" text NOT NULL,
    "keyPreview" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

CREATE INDEX "rest_api_key_name_idx" ON "rest_api_key" USING btree ("name");

--
-- ACTION MIGRATE LEGACY SINGLE KEY
--
INSERT INTO "rest_api_key" ("id", "name", "keyHash", "keyPreview", "createdAt")
SELECT gen_random_uuid(), 'Legacy key', "restApiKeyHash", 'wf_••••••••', now()
FROM "app_settings"
WHERE "restApiKeyHash" IS NOT NULL AND btrim("restApiKeyHash") <> '';

UPDATE "app_settings" SET "restApiKeyHash" = NULL WHERE "restApiKeyHash" IS NOT NULL;

--
-- MIGRATION VERSION FOR wayfinder
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('wayfinder', '20260630120000000-rest-api-keys', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260630120000000-rest-api-keys', "timestamp" = now();

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
