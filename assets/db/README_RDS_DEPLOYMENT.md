# RDS Database Deployment Guide

## Overview
This guide explains how the Canopy database schema is deployed to an AWS RDS PostgreSQL instance, and how to regenerate the bundled init scripts.

## Layout

The init scripts are bundled with `canopy-cli` and live alongside this README:

```
canopy-cli/assets/db/
├── postgres/
│   └── init/                      # ~105 files, executed in numeric order:
│       ├── 010_roles.sql          # canopy_admin / canopy_user roles
│       ├── 020_schemas.sql        # canopy_history schema
│       ├── 030_functions.sql
│       ├── 040_procedures.sql
│       ├── 050_types.sql
│       ├── 1NN_table_<name>.sql   # one per public table
│       ├── 2NN_history_<name>.sql # one per canopy_history mirror
│       ├── 300_foreign_keys.sql
│       ├── 400_views.sql
│       ├── 500_triggers.sql
│       ├── 600_grants.sql          # function ACLs + DEFAULT PRIVILEGES
│       ├── 7NN_data_<name>.sql     # one seed file per lookup table
│       ├── 800_sequence_resets.sql
│       └── 900_seed_test_data.sql  # optional test seed (dev/test only)
└── keycloak/
    └── init/
        └── 010_create_keycloak_db.sql   # isolated Keycloak DB + role
```

## Prerequisites

1. ✅ RDS instance deployed via CloudFormation (`${CANOPY_PROJECT_NAME}-RDS-${CANOPY_ENV}` stack)
2. ✅ Python 3.7+ installed
3. ✅ PostgreSQL client (`psql`) installed and on PATH
4. ✅ AWS CLI installed and on PATH with appropriate credentials
5. ✅ Network access to RDS (security group configured)

The deploy worker scrubs any pre-set `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` / `AWS_SESSION_TOKEN` from its environment, so the AWS profile is the single source of truth for credentials.

## Database Configuration

From [`RDS.yaml`](../../../canopy-cloud-replication/modules/RDS.yaml):
- **DB Instance Identifier**: `${CANOPY_PROJECT_NAME}-postgresql-${CANOPY_ENV}`
- **Database Name**: `${CANOPY_PROJECT_NAME}_${CANOPY_ENV}` (e.g., `canopy_dev`)
- **Master Username**: `canopy_postgres_${CANOPY_ENV}` (e.g., `canopy_postgres_dev`)
- **Port**: `5432`
- **Engine**: PostgreSQL 16.9

## Deployment

```bash
canopycli aws rds deploy-schema
```

This invokes `DeployRdsWorker`, which:
1. Verifies AWS credentials and resolves the RDS endpoint.
2. Tests a `psql` connection as the master user.
3. Asks for confirmation.
4. Discovers every `*.sql` file under `assets/db/postgres/init/` and `assets/db/keycloak/init/` and runs each in filename order, showing `[N/total] filename (size)  ETA mm:ss` for every file plus an elapsed/duration readout when each one finishes.
5. The keycloak file gets `psql -v kc_db=… kc_user=… kc_password=…` from `${CANOPY_AWS_PARAMETER_FILE}` (or interactive prompts if the file is absent).

Pass `--dry-run` to print the resolved configuration without executing.

## Regenerating the init scripts

When the database schema changes, re-dump and re-split:

```bash
# Dump the schema-only DDL and the data separately (using your local DB):
pg_dump --schema-only --no-owner --no-privileges -d canopy_dev > schema.sql
pg_dump --data-only   --no-owner --no-privileges -d canopy_dev > data.sql

# Split each into per-object files under assets/db/postgres/init/:
canopycli db split-schema schema.sql
canopycli db split-data   data.sql
```

The splitters preserve numeric ordering for stable filenames so subsequent re-dumps produce small, reviewable diffs in version control.

## Post-Deployment Steps

### Update Secrets Manager

After deployment, update the `application_${CANOPY_ENV}` secret with correct RDS credentials.

**⚠️ Important**: The values you set here must match your RDS configuration in [`RDS.yaml`](../../../canopy-cloud-replication/modules/RDS.yaml). If you modify the database name, username, or other settings in `RDS.yaml`, you must update them here as well.

#### Step 1: Get RDS Endpoint

The RDS endpoint is printed by `canopycli aws rds deploy-schema`. To re-fetch it:

```bash
canopycli aws rds endpoint
```

#### Step 2: Update Parameter Files

Before updating Secrets Manager, ensure the RDS credentials in your parameter files match:

**Files to update:**
- `canopy-cloud-replication/parameters-${CANOPY_ENV}.json`

**Update these parameters:**
```json
{
  "CanopyDbUsername": "canopy_user",
  "CanopyDbPassword": "REPLACEME"
}
```

**⚠️ Note**: These credentials are for the `canopy_user` role created by `010_roles.sql`, not the RDS master user.

**⚠️ Important Consistency Checks:**

1. **Database Name**: must match between `RDS.yaml` (`DBName`), `SecretsManager.yaml` (`dbname`), and the runtime `${CANOPY_PROJECT_NAME}_${CANOPY_ENV}`.
2. **Database User**: must match between `parameters-*.json` (`CanopyDbUsername`) and the role created in `010_roles.sql`.
3. **Database Password**: must match between `parameters-*.json` (`CanopyDbPassword`) and the role password in `010_roles.sql`.
