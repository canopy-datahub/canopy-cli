-- 600_grants.sql
--
-- Schema-level + broad object grants to the application user. The pg_dump
-- output had per-table/sequence/function GRANT statements naming literal
-- "canopy_user". Those have been stripped from the per-table init files
-- (the splitter does it automatically on re-dump) because broad GRANTs on
-- ALL ... IN SCHEMA cover every existing object, and ALTER DEFAULT
-- PRIVILEGES covers every future object — without ever naming the app
-- user literally except via the :'app_user' psql variable.
--
-- Required psql vars (passed by DeployRdsWorker via psql -v):
--   app_user   CanopyDbUsername from CANOPY_AWS_PARAMETER_FILE

\set ON_ERROR_STOP on

-- ---------------------------------------------------------------------------
-- Lock down the trigger functions from PUBLIC. The originals are owned by
-- canopy_admin; only canopy_admin and the application user need EXECUTE.
-- ---------------------------------------------------------------------------
REVOKE ALL ON FUNCTION public.after_operation_trigger_fnc()  FROM PUBLIC;
REVOKE ALL ON FUNCTION public.before_operation_trigger_fnc() FROM PUBLIC;

-- ---------------------------------------------------------------------------
-- Schema-level access for the application user — both public (where most
-- tables live) and canopy_history (where the audit-trigger mirrors live).
-- ---------------------------------------------------------------------------
GRANT USAGE ON SCHEMA public         TO :"app_user";
GRANT USAGE ON SCHEMA canopy_history TO :"app_user";

-- ---------------------------------------------------------------------------
-- Object-level grants on every existing schema object.
--   - public: full read+write on tables, plus sequence/function execute.
--   - canopy_history: insert + read only (the app appends audit rows; nothing
--     should update or delete history rows).
-- ---------------------------------------------------------------------------
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES     IN SCHEMA public         TO :"app_user";
GRANT SELECT, INSERT                 ON ALL TABLES     IN SCHEMA canopy_history TO :"app_user";
GRANT USAGE,  SELECT, UPDATE         ON ALL SEQUENCES  IN SCHEMA public         TO :"app_user";
GRANT EXECUTE                        ON ALL FUNCTIONS  IN SCHEMA public         TO :"app_user";
GRANT EXECUTE                        ON ALL PROCEDURES IN SCHEMA public         TO :"app_user";

-- ---------------------------------------------------------------------------
-- Default privileges for any FUTURE object created by canopy_admin in either
-- schema. Without this, every newly-added table/sequence/function would need
-- to be re-granted manually after a schema migration.
--
-- Must run as canopy_admin so the defaults are owned by the right role.
-- The master user (canopi_postgres_<env>) is granted membership in
-- canopy_admin by 010_roles.sql, which makes the SET ROLE legal.
-- ---------------------------------------------------------------------------
SET ROLE canopy_admin;

ALTER DEFAULT PRIVILEGES FOR ROLE canopy_admin IN SCHEMA public GRANT
    SELECT, INSERT, UPDATE, DELETE ON TABLES    TO :"app_user";
ALTER DEFAULT PRIVILEGES FOR ROLE canopy_admin IN SCHEMA public GRANT
    USAGE, SELECT, UPDATE          ON SEQUENCES TO :"app_user";
ALTER DEFAULT PRIVILEGES FOR ROLE canopy_admin IN SCHEMA public GRANT
    EXECUTE                        ON FUNCTIONS TO :"app_user";
ALTER DEFAULT PRIVILEGES FOR ROLE canopy_admin IN SCHEMA canopy_history GRANT
    SELECT, INSERT                 ON TABLES    TO :"app_user";

RESET ROLE;
