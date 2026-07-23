BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "marker_attachment" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "markerId" uuid NOT NULL,
    "fileName" text NOT NULL,
    "contentType" text NOT NULL,
    "sizeBytes" bigint NOT NULL,
    "storageId" text NOT NULL,
    "addedAt" timestamp without time zone NOT NULL,
    "sortOrder" bigint NOT NULL
);

-- Indexes
CREATE INDEX "marker_attachment_marker_id_idx" ON "marker_attachment" USING btree ("markerId");
CREATE UNIQUE INDEX "marker_attachment_storage_id_idx" ON "marker_attachment" USING btree ("storageId");


--
-- MIGRATION VERSION FOR wayfinder
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('wayfinder', '20260723025014401-marker-attachments', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260723025014401-marker-attachments', "timestamp" = now();

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
