BEGIN;

CREATE TABLE "geocode_contribution" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "latitude" double precision NOT NULL,
    "longitude" double precision NOT NULL,
    "notes" text,
    "countryCode" text,
    "contentKey" text NOT NULL,
    "importedFromCrowd" boolean NOT NULL DEFAULT false,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

CREATE UNIQUE INDEX "geocode_contribution_content_key_idx"
    ON "geocode_contribution" USING btree ("contentKey");
CREATE INDEX "geocode_contribution_name_idx"
    ON "geocode_contribution" USING btree ("name");

ALTER TABLE "geocoding_settings"
    ADD COLUMN IF NOT EXISTS "crowdsourceSourceUrl" text NOT NULL DEFAULT 'https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/geocoding-crowdsource/contributions.json'::text;

INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('wayfinder_geocoding', '20260623120000000-geocoding-contributions', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260623120000000-geocoding-contributions', "timestamp" = now();

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
