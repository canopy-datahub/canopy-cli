-- PostgreSQL extensions used by the application schema. Must run BEFORE
-- 030_functions.sql, since the trigger function `after_operation_trigger_fnc()`
-- declares variables of type `hstore`.

CREATE EXTENSION IF NOT EXISTS hstore;
