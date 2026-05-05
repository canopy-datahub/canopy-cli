"""
RDS schema deployment.

Invoked from AwsWorker.rds_deploy_schema() via `canopycli aws rds deploy-schema`.
Reads SQL files from canopy-cli's bundled assets at:
    canopy-cli/assets/db/postgres/init/   (canopy app database)
    canopy-cli/assets/db/keycloak/init/   (keycloak database bootstrap)
and executes each file in numeric order against the project's RDS instance,
showing per-file progress with an elapsed/ETA readout.
"""

import json
import os
import re
import subprocess
import sys
import time
from getpass import getpass
from pathlib import Path
from typing import Dict, List, Optional

from rich.console import Console
from rich.panel import Panel
from rich.style import Style

console = Console()


# Bundled asset roots. __file__ is at
#   canopy-cli/edu/stanford/cmed/devcli/worker/DeployRdsWorker.py
# parents[5] resolves to the canopy-cli repo root.
_ASSETS_DB = Path(__file__).resolve().parents[5] / "assets" / "db"
POSTGRES_INIT_DIR = _ASSETS_DB / "postgres" / "init"
KEYCLOAK_INIT_DIR = _ASSETS_DB / "keycloak" / "init"

# Files in the keycloak phase need extra psql -v variables passed in. Other
# files run with no variables.
_KEYCLOAK_VAR_KEYS = ("kc_db", "kc_user", "kc_password")


def _fmt_secs(s: float) -> str:
    if s < 0 or s != s:  # NaN guard
        return "--:--"
    s = int(s)
    return f"{s // 60:02d}:{s % 60:02d}"


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

        if not POSTGRES_INIT_DIR.is_dir():
            console.print(
                Panel(
                    f"[red]Bundled SQL asset dir not found: {POSTGRES_INIT_DIR}"
                    f"\n[yellow]Re-pull canopy-cli — the assets/db tree is missing.",
                    title="Error",
                    title_align="left",
                ),
                style=Style(color="red"),
            )
            return

        postgres_scripts = sorted(POSTGRES_INIT_DIR.glob("*.sql"))
        keycloak_scripts = sorted(KEYCLOAK_INIT_DIR.glob("*.sql")) if KEYCLOAK_INIT_DIR.is_dir() else []
        all_scripts = postgres_scripts + keycloak_scripts
        if not all_scripts:
            console.print(
                Panel(
                    f"[red]No SQL files found under {POSTGRES_INIT_DIR}",
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
                f" SQL dir : {POSTGRES_INIT_DIR}\n"
                f" Files   : {len(postgres_scripts)} postgres + {len(keycloak_scripts)} keycloak",
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

        # The application DB name and the RDS master username are both set
        # at CloudFormation deploy time from CANOPY_AWS_PARAMETER_FILE
        # (RDS.yaml reads CanopyAppDbName / DbMasterUsername). Read them
        # back from the same file here so we connect with whatever the
        # user actually configured — not a hardcoded `canopy_*` derivation
        # that breaks the moment ProjectName isn't literally "canopy".
        db_name = DeployRdsWorker._param(
            "CanopyAppDbName", default=f"{project}_{env}")
        db_user = DeployRdsWorker._param(
            "DbMasterUsername", default=f"{project}_postgres_{env}")

        db_password = getpass("Enter database master password: ")
        console.print("\n[bold]Testing connection…[/bold]")
        if not DeployRdsWorker._test_psql_connection(endpoint, db_user, db_name, db_password):
            console.print(
                Panel(
                    "[red]Could not connect to database.\n"
                    "[yellow]Common causes:\n"
                    f"  1. Wrong master password — show the value RDS was created with:\n"
                    f"     jq -r '.Parameters.DbMasterPassword' \"$CANOPY_AWS_PARAMETER_FILE\"\n"
                    f"  2. The param file was edited *after* RDS was deployed. The master\n"
                    f"     password is set at create time; later edits are not picked up.\n"
                    f"     Rotate it with:\n"
                    f"     aws rds modify-db-instance \\\n"
                    f"       --db-instance-identifier {db_identifier} \\\n"
                    f"       --master-user-password '<new>' --apply-immediately\n"
                    f"  3. Special characters in the password mangled by your shell —\n"
                    f"     re-test using PGPASSWORD instead of the prompt.\n"
                    f"  4. Security group doesn't allow your IP (update MyIP and re-deploy RDS).\n"
                    f"  5. RDS instance not yet ACTIVE — check:\n"
                    f"     aws rds describe-db-instances --db-instance-identifier {db_identifier} --region {region} --query 'DBInstances[0].DBInstanceStatus'",
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
        keycloak_vars = {
            "kc_db": kc_params["KeycloakDbName"],
            "kc_user": kc_params["KeycloakDbUsername"],
            "kc_password": kc_params["KeycloakDbPassword"],
        }

        # Pre-compute total bytes for ETA. ETA estimates remaining time as
        # (remaining_bytes / bytes_per_second_so_far), recomputed after each
        # script. It's a heuristic — large INSERT-heavy files run slower per
        # byte than DDL — but it's far better than nothing.
        total_files = len(all_scripts)
        total_bytes = sum(p.stat().st_size for p in all_scripts)
        bytes_done = 0
        deploy_start = time.monotonic()

        console.print(
            f"\n[bold]Running {total_files} SQL scripts "
            f"({total_bytes/1024:,.0f} KB total)…[/bold]"
        )

        for idx, sql_path in enumerate(all_scripts, start=1):
            script_name = sql_path.name
            size = sql_path.stat().st_size
            is_keycloak = sql_path.parent == KEYCLOAK_INIT_DIR

            elapsed = time.monotonic() - deploy_start
            if bytes_done > 0 and elapsed > 0:
                bps = bytes_done / elapsed
                eta = max(0.0, (total_bytes - bytes_done) / bps) if bps else 0.0
                eta_str = f"  ETA {_fmt_secs(eta)}"
            else:
                eta_str = ""

            console.print(
                f"\n[bold cyan][{idx:>3}/{total_files}][/bold cyan] "
                f"{script_name}  [dim]({size/1024:,.1f} KB"
                f"{', keycloak' if is_keycloak else ''}){eta_str}[/dim]"
            )

            vars_for_file = keycloak_vars if is_keycloak else None
            t0 = time.monotonic()
            ok = DeployRdsWorker._run_psql_file(
                endpoint, db_user, db_name, db_password, sql_path, vars_for_file
            )
            dt = time.monotonic() - t0

            if ok:
                console.print(f"  [green]✓ {script_name}[/green] [dim]({_fmt_secs(dt)})[/dim]")
                bytes_done += size
            else:
                console.print(f"  [red]✗ {script_name} failed — aborting[/red]")
                sys.exit(1)

        total_elapsed = time.monotonic() - deploy_start
        console.print(
            f"\n[dim]Total: {total_files} files, "
            f"{total_bytes/1024:,.0f} KB in {_fmt_secs(total_elapsed)}[/dim]"
        )

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
        # PGSSLMODE=require pins the connection to TLS. RDS sets
        # `rds.force_ssl=1` by default, which makes a plaintext-fallback
        # attempt fail with a misleading "no pg_hba.conf entry … no
        # encryption" message that hides the real auth failure.
        env["PGSSLMODE"] = "require"
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
        env["PGSSLMODE"] = "require"     # pin to TLS; see _test_psql_connection
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
    def _param(key: str, default: str = "") -> str:
        """Read a single value from CANOPY_AWS_PARAMETER_FILE, substituting
        any `<<ENV_VAR>>` placeholders that haven't been resolved yet.
        Returns `default` if the file is missing, can't be parsed, or the
        key is absent."""
        path = os.environ.get("CANOPY_AWS_PARAMETER_FILE", "")
        if not path or not Path(path).is_file():
            return default
        try:
            params = json.loads(Path(path).read_text()).get("Parameters", {})
        except (json.JSONDecodeError, OSError):
            return default
        val = params.get(key)
        if not isinstance(val, str) or not val:
            return default
        return re.sub(
            r"<<([A-Z_][A-Z0-9_]*)>>",
            lambda m: os.environ.get(m.group(1), m.group(0)),
            val,
        )

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
