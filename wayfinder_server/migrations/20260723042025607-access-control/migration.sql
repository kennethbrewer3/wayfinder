BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "access_role" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "key" text NOT NULL,
    "name" text NOT NULL,
    "description" text,
    "isSystem" boolean NOT NULL,
    "permissionsJson" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "access_role_key_idx" ON "access_role" USING btree ("key");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "user_membership" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "authUserId" uuid NOT NULL,
    "roleId" uuid NOT NULL,
    "email" text NOT NULL,
    "displayName" text,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "user_membership_auth_user_idx" ON "user_membership" USING btree ("authUserId");
CREATE UNIQUE INDEX "user_membership_email_idx" ON "user_membership" USING btree ("email");


--
-- MIGRATION VERSION FOR wayfinder
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('wayfinder', '20260723042025607-access-control', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260723042025607-access-control', "timestamp" = now();

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
