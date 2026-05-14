--
-- Upgrade script for DBs that pre-date the access_level column in
-- 132_table_study.sql. Fresh installs already get the column from 132 and
-- this file is a no-op for them (every statement is idempotent).
--
-- Apply ad-hoc to existing environments only (canopycli aws rds deploy-schema
-- is destructive on a live DB and is not used for incremental upgrades).
--

ALTER TABLE public.study
    ADD COLUMN IF NOT EXISTS access_level character varying(16) NOT NULL DEFAULT 'PUBLIC'
        CHECK (access_level IN ('PUBLIC', 'LIMITED', 'PRIVATE'));

CREATE INDEX IF NOT EXISTS idx_study_access_level ON public.study (access_level);
CREATE INDEX IF NOT EXISTS idx_study_created_by   ON public.study (created_by);


--
