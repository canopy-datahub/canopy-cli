-- Role: canopy_admin
-- DROP ROLE IF EXISTS canopy_admin;

CREATE ROLE canopy_admin WITH
  LOGIN
  PASSWORD 'REPLACEME'
  NOSUPERUSER
  INHERIT
  CREATEDB
  CREATEROLE
  NOREPLICATION;

GRANT rds_superuser TO canopy_admin WITH ADMIN OPTION;

-- The deploy runs as the RDS master user (e.g. canopi_postgres_<env>), which
-- needs to be a member of canopy_admin so subsequent files can `SET ROLE
-- canopy_admin` (e.g. ALTER DEFAULT PRIVILEGES FOR ROLE canopy_admin in
-- 600_grants.sql). Granted dynamically against the connected user so the
-- script doesn't hardcode the master-user name.
DO $$ BEGIN
  EXECUTE format('GRANT canopy_admin TO %I', current_user);
END $$;

-- Role: canopy_user
-- DROP ROLE IF EXISTS canopy_user;

CREATE ROLE canopy_user WITH
  LOGIN
  PASSWORD 'REPLACEME'
  NOSUPERUSER
  INHERIT
  NOCREATEDB
  NOCREATEROLE
  NOREPLICATION
  VALID UNTIL 'infinity';
