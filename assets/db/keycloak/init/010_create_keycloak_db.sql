-- Isolates Keycloak state from the application database.
-- Run against the RDS master user; canopycli aws rds deploy-schema passes
-- the three psql variables below from CANOPY_AWS_PARAMETER_FILE.
--
-- Required psql vars (pass via psql -v):
--   kc_db         Keycloak database name      (e.g. canopy_keycloak_prod)
--   kc_user       Keycloak PostgreSQL role    (e.g. keycloak_user)
--   kc_password   Keycloak PostgreSQL password
--
-- Re-runnable: role is ALTERed (password reset) if it already exists;
-- database is created only if missing; ownership is re-applied either way.

\set ON_ERROR_STOP on

-- Create or update the Keycloak role.
SELECT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'kc_user')::text AS kc_role_exists \gset

\if :kc_role_exists
  \echo 'Keycloak role already exists — updating password.'
  ALTER ROLE :"kc_user" WITH LOGIN PASSWORD :'kc_password';
\else
  \echo 'Creating Keycloak role...'
  CREATE ROLE :"kc_user" WITH LOGIN PASSWORD :'kc_password' NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
\endif

-- Create the Keycloak database if it does not already exist.
-- CREATE DATABASE cannot run inside a transaction block, so build it as a
-- psql variable and execute it at top level.
SELECT EXISTS (SELECT 1 FROM pg_database WHERE datname = :'kc_db')::text AS kc_db_exists \gset
SELECT format('CREATE DATABASE %I OWNER %I', :'kc_db', :'kc_user') AS kc_create_db \gset

\if :kc_db_exists
  \echo 'Keycloak database already exists.'
\else
  \echo 'Creating Keycloak database...'
  :kc_create_db ;
\endif

-- Ensure ownership even if DB pre-existed.
SELECT format('ALTER DATABASE %I OWNER TO %I', :'kc_db', :'kc_user') AS kc_alter_db \gset
:kc_alter_db ;

GRANT CONNECT ON DATABASE :"kc_db" TO :"kc_user";
