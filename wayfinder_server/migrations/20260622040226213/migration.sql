BEGIN;

--
-- Many-to-many PMTiles file/group memberships.
--

CREATE TABLE "pmtiles_file_group" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "fileId" uuid NOT NULL,
    "groupId" uuid NOT NULL
);

CREATE INDEX "pmtiles_file_group_file_idx" ON "pmtiles_file_group" USING btree ("fileId");
CREATE INDEX "pmtiles_file_group_group_idx" ON "pmtiles_file_group" USING btree ("groupId");
CREATE UNIQUE INDEX "pmtiles_file_group_unique_idx" ON "pmtiles_file_group" USING btree ("fileId", "groupId");

INSERT INTO "pmtiles_file_group" ("id", "fileId", "groupId")
SELECT gen_random_uuid(), "id", "groupId"
FROM "pmtiles_file"
WHERE "groupId" IS NOT NULL;

DROP INDEX IF EXISTS "pmtiles_file_group_id_idx";
ALTER TABLE "pmtiles_file" DROP COLUMN "groupId";

ALTER TABLE "pmtiles_group" ADD COLUMN IF NOT EXISTS "showOnMap" boolean NOT NULL DEFAULT false;

INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('wayfinder', '20260622040226213', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260622040226213', "timestamp" = now();

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
