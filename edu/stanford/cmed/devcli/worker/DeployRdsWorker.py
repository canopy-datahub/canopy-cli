"""
RDS schema deployment — the contents of the old
canopy-development/db/postgres/db-create-scripts/deploy_to_rds.py, ported into
canopycli so deploying the schema no longer requires running a helper script.

Invoked from AwsWorker.rds_deploy_schema() via `canopycli aws rds deploy-schema`.
Reads SQL files from ${CANOPY_HOME}/canopy-development/db/postgres/db-create-scripts/
and executes them in order against the project's RDS instance.
"""

import json
import os
import subprocess
import sys
from getpass import getpass
from pathlib import Path
from typing import Dict, List, Optional

from rich.console import Console
from rich.panel import Panel
from rich.style import Style

console = Console()


# Relative path under ${CANOPY_HOME} that contains the SQL files.
SQL_DIR_RELPATH = ("canopy-development", "db", "postgres", "db-create-scripts")

# Ordered list of SQL scripts to apply.
SQL_SCRIPTS: List[str] = [
    "01_create_user_roles.sql",
    "02_create_base_db.sql",
    "03_populate_base_tables.sql",
    "04_populate_variable_tables.sql",
    "05_populate_test_data.sql",
    "06_create_keycloak_db.sql",
]


class DeployRdsWorker:
    """Orchestrates the end-to-end RDS schema deployment."""

    @staticmethod
    def deploy(dry_run: bool = False) -> None:
        required_env = {
            "CANOPY_HOME": os.environ.get("CANOPY_HOME", ""),
            "CANOPY_PROJECT_NAME": os.environ.get("CANOPY_PROJECT_NAME", ""),
            "CANOPY_ENV": os.environ.get("CANOPY_ENV", ""),
            "AWS_PROFILE": os.environ.get("AWS_PROFILE", ""),
        }
        missing = [k for k, v in required_env.items() if not v]
        if missing:
            console.print(
                Panel(
                    "[red]Missing environment variables: " + ", ".join(missing)
                    + "\n[yellow]Source your set-canopy-env.sh first.",
                    title="Error",
                    title_align="left",
                ),
                style=Style(color="red"),
            )
            return

        canopy_home = required_env["CANOPY_HOME"]
        project = required_env["CANOPY_PROJECT_NAME"]
        env = required_env["CANOPY_ENV"]
        profile = required_env["AWS_PROFILE"]
        region = os.environ.get("AWS_REGION") or "us-east-1"

        sql_dir = Path(canopy_home, *SQL_DIR_RELPATH)
        if not sql_dir.is_dir():
            console.print(
                Panel(
                    f"[red]SQL directory not found: {sql_dir}"
                    f"\n[yellow]Make sure the canopy-development repo is cloned under CANOPY_HOME.",
                    title="Error",
                    title_align="left",
                ),
                style=Style(color="red"),
            )
            return

        DeployRdsWorker._require_tool("aws")
        DeployRdsWorker._require_tool("psql")

        console.print(
            Panel(
                f"[yellow] Project : {project}\n"
                f" Env     : {env}\n"
                f" Region  : {region}\n"
                f" Profile : {profile}\n"
                f" SQL dir : {sql_dir}",
                title="RDS Schema Deploy",
                title_align="left",
            ),
            style=Style(color="yellow"),
        )

        if dry_run:
            console.print("[bold yellow]Dry run — no SQL will be executed.[/bold yellow]")
            return

        # Build a scrubbed env for all subprocess calls — drop any statically
        # configured AWS credentials so the profile is the single source of
        # truth (matches the old script's behaviour).
        env_vars = os.environ.copy()
        for key in ("AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_SESSION_TOKEN"):
            env_vars.pop(key, None)
        env_vars["AWS_DEFAULT_REGION"] = region
        env_vars["AWS_PROFILE"] = profile

        console.print("\n[bold]Verifying AWS credentials…[/bold]")
        identity = DeployRdsWorker._run_aws(
            ["sts", "get-caller-identity"], env_vars=env_vars
        )
        console.print(f"  ✓ AWS Account: {identity.get('Account', 'unknown')}")
        console.print(f"  ✓ AWS User:    {identity.get('Arn', 'unknown')}\n")

        console.print("[bold]Getting RDS endpoint…[/bold]")
        db_identifier = f"{project}-postgresql-{env}"
        rds_info = DeployRdsWorker._run_aws(
            [
                "rds",
                "describe-db-instances",
                "--db-instance-identifier",
                db_identifier,
                "--region",
                region,
            ],
            env_vars=env_vars,
        )
        try:
            endpoint = rds_info["DBInstances"][0]["Endpoint"]["Address"]
        except (KeyError, IndexError):
            console.print(
                f"[red]Error: Could not get RDS endpoint for {db_identifier}"
            )
            sys.exit(1)
        console.print(f"  RDS endpoint: [cyan]{endpoint}[/cyan]\n")

        # These derivations match the old script verbatim. Param file has
        # CanopyAppDbName / DbMasterUsername with the same values today.
        db_name = f"{project}_{env}"
        db_user = f"datahub_postgres_{env}"

        db_password = getpass("Enter database master password: ")
        console.print("\n[bold]Testing connection…[/bold]")
        if not DeployRdsWorker._test_psql_connection(endpoint, db_user, db_name, db_password):
            console.print(
                Panel(
                    "[red]Could not connect to database.\n"
                    "[yellow]Common causes:\n"
                    f"  1. Wrong master password (check DbMasterPassword in the param file)\n"
                    f"  2. Security group doesn't allow your IP (update MyIP and re-deploy RDS)\n"
                    f"  3. RDS instance not yet ACTIVE — check\n"
                    f"     aws rds describe-db-instances --db-instance-identifier {db_identifier} --region {region} --query 'DBInstances[0].DBInstanceStatus'\n"
                    f"  4. Network-level connectivity issues",
                    title="Connection failed",
                    title_align="left",
                ),
                style=Style(color="red"),
            )
            sys.exit(1)
        console.print("  ✓ Connection successful\n")

        console.print(
            Panel(
                f"[yellow]About to deploy database schema to:\n"
                f"  Environment: {env}\n"
                f"  Endpoint:    {endpoint}\n"
                f"  Database:    {db_name}",
                title="Confirm",
                title_align="left",
            ),
            style=Style(color="yellow"),
        )
        confirm = input("Continue? (yes/no): ").strip().lower()
        if confirm not in {"y", "yes"}:
            console.print("[yellow]Deployment cancelled.[/yellow]")
            return

        kc_params = DeployRdsWorker._load_keycloak_db_params()
        psql_vars_for: Dict[str, Dict[str, str]] = {
            "06_create_keycloak_db.sql": {
                "kc_db": kc_params["KeycloakDbName"],
                "kc_user": kc_params["KeycloakDbUsername"],
                "kc_password": kc_params["KeycloakDbPassword"],
            },
        }

        console.print("\n[bold]Running SQL scripts…[/bold]")
        for script_name in SQL_SCRIPTS:
            sql_path = sql_dir / script_name
            if not sql_path.exists():
                console.print(f"  [yellow]⚠ {script_name} not found, skipping[/yellow]")
                continue
            console.print(f"\n[bold]  → {script_name}[/bold]")
            vars_for_file = psql_vars_for.get(script_name)
            ok = DeployRdsWorker._run_psql_file(
                endpoint, db_user, db_name, db_password, sql_path, vars_for_file
            )
            if ok:
                console.print(f"  [green]✓ {script_name} completed[/green]")
            else:
                console.print(
                    f"  [red]✗ {script_name} failed — aborting[/red]"
                )
                sys.exit(1)

        console.print(
            Panel(
                "[green]Database schema deployment completed.",
                title="Done",
                title_align="left",
            ),
            style=Style(color="green"),
        )

    # ------------------------------------------------------------------ helpers

    @staticmethod
    def _require_tool(name: str) -> None:
        """Abort with a clear error if the given CLI tool isn't on PATH."""
        from shutil import which

        if which(name):
            return
        console.print(f"[red]Error: required tool '{name}' not found on PATH[/red]")
        sys.exit(1)

    @staticmethod
    def _run_aws(args: List[str], env_vars: Dict[str, str]) -> dict:
        """Run `aws <args> --output json` and return parsed JSON. Abort on failure."""
        cmd = ["aws", *args, "--output", "json"]
        try:
            completed = subprocess.run(
                cmd, env=env_vars, capture_output=True, text=True, check=True
            )
        except FileNotFoundError:
            console.print("[red]Error: AWS CLI not found on PATH[/red]")
            sys.exit(1)
        except subprocess.CalledProcessError as exc:
            msg = (exc.stderr or exc.stdout or "").strip()
            console.print(f"[red]Error: AWS CLI command failed:[/red]\n{msg}")
            sys.exit(1)
        try:
            return json.loads(completed.stdout)
        except json.JSONDecodeError:
            console.print(f"[red]Error: Could not parse AWS CLI output:[/red]\n{completed.stdout}")
            sys.exit(1)

    @staticmethod
    def _test_psql_connection(
        endpoint: str, user: str, db_name: str, password: str
    ) -> bool:
        env = os.environ.copy()
        env["PGPASSWORD"] = password
        cmd = [
            "psql",
            "-h", endpoint,
            "-U", user,
            "-d", db_name,
            "-c", "SELECT version();",
        ]
        try:
            subprocess.run(cmd, env=env, check=True, stdout=subprocess.DEVNULL)
            return True
        except FileNotFoundError:
            console.print("[red]Error: psql not found on PATH[/red]")
            sys.exit(1)
        except subprocess.CalledProcessError:
            return False

    @staticmethod
    def _run_psql_file(
        endpoint: str,
        user: str,
        db_name: str,
        password: str,
        sql_file: Path,
        psql_vars: Optional[Dict[str, str]] = None,
    ) -> bool:
        env = os.environ.copy()
        env["PGPASSWORD"] = password
        cmd: List[str] = ["psql", "-h", endpoint, "-U", user, "-d", db_name]
        for key, value in (psql_vars or {}).items():
            cmd.extend(["-v", f"{key}={value}"])
        cmd.extend(["-f", str(sql_file)])
        try:
            subprocess.run(cmd, env=env, check=True)
            return True
        except subprocess.CalledProcessError:
            return False

    @staticmethod
    def _load_keycloak_db_params() -> Dict[str, str]:
        """Read KeycloakDbName/Username/Password from CANOPY_AWS_PARAMETER_FILE.
        Falls back to interactive prompts if the file is missing or a key is absent.
        Refuses placeholder values so the deploy fails fast instead of creating a
        role with a literal "REPLACEME" password.
        """
        required = ("KeycloakDbName", "KeycloakDbUsername", "KeycloakDbPassword")
        placeholders = {"", "REPLACEME", "REPLACEME_kc_db_password"}
        values: Dict[str, str] = {}

        param_path = os.environ.get("CANOPY_AWS_PARAMETER_FILE", "")
        if param_path and Path(param_path).is_file():
            try:
                with open(param_path, "r") as f:
                    params = json.load(f).get("Parameters", {})
                for key in required:
                    if params.get(key):
                        values[key] = params[key]
            except (json.JSONDecodeError, OSError) as exc:
                console.print(f"[yellow]Warning: could not read {param_path}: {exc}[/yellow]")

        for key in required:
            if not values.get(key):
                if key == "KeycloakDbPassword":
                    values[key] = getpass(f"Enter {key}: ")
                else:
                    values[key] = input(f"Enter {key}: ").strip()

        if any(v in placeholders for v in values.values()):
            console.print(
                "[red]Error: one or more Keycloak DB parameters are still placeholders — "
                "edit CANOPY_AWS_PARAMETER_FILE and retry.[/red]"
            )
            sys.exit(1)

        return values
