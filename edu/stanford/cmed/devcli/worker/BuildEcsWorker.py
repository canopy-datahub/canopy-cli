"""
ECS service build-and-deploy — the contents of the old canopy-deployment-scripts/deploy.py
ported into canopycli so `canopycli aws ecs deploy <service> [--tag T]` is the single
entry point for every service (user-service, submission-service, …, ui, keycloak).

End-to-end flow per service:
  1. Verify the local source directory + Dockerfile exist.
  2. Build the application (Maven for Spring Boot services; no-op for ui/keycloak — their
     Dockerfiles handle the build internally).
  3. Authenticate Docker with ECR (STS + ECR token → docker login --password-stdin).
  4. docker buildx (preferred) / docker build+push — linux/amd64, with NEXT_PUBLIC_* build
     args for the ui service.
  5. ECS UpdateService --force-new-deployment, with first-run detection (if the service
     isn't ACTIVE, print a clear "deploy the CFN stack first" message and exit 0 — the
     image is already pushed).
"""

import base64
import json
import os
import subprocess
import sys
import time
from pathlib import Path
from typing import Dict, List, Optional

from rich.console import Console
from rich.panel import Panel
from rich.style import Style
from rich.table import Table

try:
    import boto3
except ImportError:
    boto3 = None  # Checked at runtime — tells the user to install.

console = Console()


# Per-service naming. Each entry maps the user-facing service name to:
#   source_dir  - path under CANOPY_HOME containing the Dockerfile (and pom.xml for Spring Boot)
#   ecr_suffix  - appended to {project} to form the ECR repo: {project}-{ecr_suffix}/{env}
#   ecs_suffix  - appended to {project} to form the ECS service name: {project}-{ecs_suffix}
#
# Inherited warts on purpose: entity-service → entityservice (no hyphen),
# search-service → search (no -service), ui/keycloak get Dockerfile-internal builds.
SERVICES: Dict[str, Dict[str, str]] = {
    "user-service": {
        "source_dir": "datahub-service-user",
        "ecr_suffix": "user-service",
        "ecs_suffix": "UserService",
    },
    "submission-service": {
        "source_dir": "datahub-service-submission",
        "ecr_suffix": "submission-service",
        "ecs_suffix": "SubmissionService",
    },
    "report-service": {
        "source_dir": "datahub-service-report",
        "ecr_suffix": "report-service",
        "ecs_suffix": "ReportService",
    },
    "download-service": {
        "source_dir": "datahub-service-download",
        "ecr_suffix": "download-service",
        "ecs_suffix": "DownloadService",
    },
    "approved-data-service": {
        "source_dir": "datahub-service-approved-data",
        "ecr_suffix": "approved-data-service",
        "ecs_suffix": "ApprovedDataService",
    },
    "entity-service": {
        "source_dir": "datahub-service-entity",
        "ecr_suffix": "entityservice",
        "ecs_suffix": "EntityService",
    },
    "search-service": {
        "source_dir": "datahub-service-search",
        "ecr_suffix": "search",
        "ecs_suffix": "Search",
    },
    "ui": {
        "source_dir": "datahub-ui-main",
        "ecr_suffix": "ui",
        "ecs_suffix": "UI",
    },
    "keycloak": {
        "source_dir": "canopy-cloud-replication/keycloak",
        "ecr_suffix": "keycloak",
        "ecs_suffix": "Keycloak",
    },
}


# Services whose Dockerfile handles the build internally (no local Maven step).
DOCKERFILE_BUILT = {"ui", "keycloak"}


# NEXT_PUBLIC_* values baked into the Next.js bundle at docker build time.
# Required ones must come from either .env.production or the shell env;
# the rest are optional.
UI_BUILD_ARG_KEYS: List[str] = [
    "NEXT_PUBLIC_BACKEND_URL",
    "NEXT_PUBLIC_KEYCLOAK_URL",
    "NEXT_PUBLIC_KEYCLOAK_REALM",
    "NEXT_PUBLIC_KEYCLOAK_CLIENT_ID",
    "NEXT_PUBLIC_GTAG",
    "NODE_TLS_REJECT_UNAUTHORIZED",
]
UI_BUILD_ARG_REQUIRED: List[str] = [
    "NEXT_PUBLIC_BACKEND_URL",
    "NEXT_PUBLIC_KEYCLOAK_URL",
    "NEXT_PUBLIC_KEYCLOAK_REALM",
    "NEXT_PUBLIC_KEYCLOAK_CLIENT_ID",
]


class BuildEcsWorker:
    """Builds + pushes a service image and kicks off an ECS deployment."""

    # --------------------------------------------------------------- public API

    @staticmethod
    def deploy(service: str, tag: Optional[str] = None, dry_run: bool = False) -> None:
        if service not in SERVICES:
            console.print(
                Panel(
                    f"[red]Unknown service: [bold]{service}[/bold]"
                    f"\n[yellow]Available: " + ", ".join(SERVICES.keys()),
                    title="Error",
                    title_align="left",
                ),
                style=Style(color="red"),
            )
            return

        if boto3 is None:
            console.print(
                "[red]boto3 is not installed.[/red]\n"
                "[yellow]pip install -r ${CANOPY_HOME}/canopy-cli/requirements.txt[/yellow]"
            )
            return

        ctx = BuildEcsWorker._resolve_context(service)
        if ctx is None:
            return

        # Resolve the final image tag: keycloak reads from KeycloakImageTag in the
        # param file; every other service defaults to 'latest'. User --tag wins.
        if tag is None:
            tag = BuildEcsWorker._default_tag(service)
        ctx["tag"] = tag

        # ECR repo URL + ECS cluster/service derivations.
        ecr_url = (
            f"{ctx['account_id']}.dkr.ecr.{ctx['region']}.amazonaws.com/"
            f"{ctx['project']}-{ctx['ecr_suffix']}/{ctx['env']}"
        )
        ecs_cluster = f"{ctx['project']}-Services-{ctx['env']}"
        ecs_service = f"{ctx['project']}-{ctx['ecs_suffix']}"
        ctx.update({"ecr_url": ecr_url, "ecs_cluster": ecs_cluster, "ecs_service": ecs_service})

        BuildEcsWorker._print_summary(service, ctx)

        if dry_run:
            console.print("[bold yellow]Dry run — no build/push/deploy performed.[/bold yellow]")
            return

        try:
            BuildEcsWorker._verify_source(ctx)
            BuildEcsWorker._build_app(service, ctx)
            BuildEcsWorker._authenticate_ecr(ctx)
            ui_build_args = (
                BuildEcsWorker._ui_build_args(ctx) if service == "ui" else None
            )
            BuildEcsWorker._docker_build_push(ctx, build_args=ui_build_args)
            BuildEcsWorker._deploy_to_ecs(ctx)
        except _DeploymentError as exc:
            console.print(f"\n[red]❌ Deployment failed: {exc}[/red]\n")
            sys.exit(1)
        except KeyboardInterrupt:
            console.print("\n[yellow]Interrupted by user[/yellow]\n")
            sys.exit(130)

    # --------------------------------------------------------------- context / setup

    @staticmethod
    def _resolve_context(service: str) -> Optional[dict]:
        canopy_home = os.environ.get("CANOPY_HOME", "")
        project = os.environ.get("CANOPY_PROJECT_NAME", "")
        env = os.environ.get("CANOPY_ENV", "")
        profile = os.environ.get("AWS_PROFILE", "")
        region = os.environ.get("AWS_REGION") or "us-east-1"

        missing = [
            n for n, v in (
                ("CANOPY_HOME", canopy_home),
                ("CANOPY_PROJECT_NAME", project),
                ("CANOPY_ENV", env),
                ("AWS_PROFILE", profile),
            )
            if not v
        ]
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
            return None

        service_cfg = SERVICES[service]
        service_path = Path(canopy_home) / service_cfg["source_dir"]

        try:
            session = boto3.Session(profile_name=profile, region_name=region)
            account_id = session.client("sts").get_caller_identity()["Account"]
        except Exception as exc:
            console.print(
                Panel(
                    f"[red]Failed to create AWS session: {exc}"
                    f"\n[yellow]Check that AWS_PROFILE={profile} is configured.",
                    title="Error",
                    title_align="left",
                ),
                style=Style(color="red"),
            )
            return None

        return {
            "service": service,
            "canopy_home": Path(canopy_home),
            "project": project,
            "env": env,
            "profile": profile,
            "region": region,
            "session": session,
            "account_id": account_id,
            "service_path": service_path,
            "source_dir": service_cfg["source_dir"],
            "ecr_suffix": service_cfg["ecr_suffix"],
            "ecs_suffix": service_cfg["ecs_suffix"],
        }

    @staticmethod
    def _default_tag(service: str) -> str:
        """Keycloak reads KeycloakImageTag from the param file; everything else gets 'latest'."""
        if service != "keycloak":
            return "latest"
        param_path = os.environ.get("CANOPY_AWS_PARAMETER_FILE", "")
        if param_path and Path(param_path).is_file():
            try:
                with open(param_path, "r") as f:
                    tag = json.load(f).get("Parameters", {}).get("KeycloakImageTag", "")
                if tag:
                    return tag
            except (json.JSONDecodeError, OSError):
                pass
        console.print(
            "[yellow]KeycloakImageTag not found in the param file — falling back to 'latest'.[/yellow]"
        )
        return "latest"

    @staticmethod
    def _print_summary(service: str, ctx: dict) -> None:
        table = Table("Field", "Value", title=f"ECS deploy: {service}")
        for k, v in (
            ("Project",     ctx["project"]),
            ("Environment", ctx["env"]),
            ("Profile",     ctx["profile"]),
            ("Account",     ctx["account_id"]),
            ("Region",      ctx["region"]),
            ("Source dir",  str(ctx["service_path"])),
            ("ECR repo",    f"{ctx['project']}-{ctx['ecr_suffix']}/{ctx['env']}"),
            ("Image tag",   ctx["tag"]),
            ("ECS cluster", ctx["ecs_cluster"]),
            ("ECS service", ctx["ecs_service"]),
        ):
            table.add_row(f"[yellow]{k}[/yellow]", v)
        table.style = Style(color="yellow")
        console.print(table)

    # --------------------------------------------------------------- step 1: source

    @staticmethod
    def _verify_source(ctx: dict) -> None:
        console.print("\n[bold]📁 Step 1: Verify source directory[/bold]")
        path = ctx["service_path"]
        if not path.exists():
            raise _DeploymentError(f"Source directory not found: {path}")
        if not (path / "Dockerfile").exists():
            raise _DeploymentError(f"Dockerfile not found in: {path}")
        console.print(f"  ✓ {path}")

    # --------------------------------------------------------------- step 2: build

    @staticmethod
    def _build_app(service: str, ctx: dict) -> None:
        console.print("\n[bold]🔧 Step 2: Build application[/bold]")
        if service in DOCKERFILE_BUILT:
            console.print(f"  [dim]({service}: build handled inside Dockerfile — skipping Maven)[/dim]")
            return

        pom = ctx["service_path"] / "pom.xml"
        if not pom.exists():
            raise _DeploymentError(f"pom.xml not found in: {ctx['service_path']}")

        mvn = "mvn.cmd" if sys.platform == "win32" else "mvn"
        try:
            subprocess.run(
                [mvn, "clean", "package", "-DskipTests", "-q"],
                cwd=ctx["service_path"], check=True,
            )
        except FileNotFoundError:
            raise _DeploymentError(
                f"'{mvn}' not found on PATH. Install Maven or activate your canopycli venv."
            )
        except subprocess.CalledProcessError as exc:
            raise _DeploymentError(f"Maven build failed (exit {exc.returncode}).")

        target_dir = ctx["service_path"] / "target"
        jars = [
            p for p in target_dir.glob("*.jar")
            if not p.name.endswith("-sources.jar") and not p.name.endswith("-javadoc.jar")
        ]
        if not jars:
            raise _DeploymentError(f"No jar produced in {target_dir}.")
        console.print(f"  ✓ {jars[0].name} ({jars[0].stat().st_size / 1024 / 1024:.2f} MB)")

    # --------------------------------------------------------------- step 3: ECR auth

    @staticmethod
    def _authenticate_ecr(ctx: dict) -> None:
        console.print("\n[bold]🔐 Step 3: Authenticate Docker with ECR[/bold]")
        try:
            ecr = ctx["session"].client("ecr", region_name=ctx["region"])
            auth = ecr.get_authorization_token()["authorizationData"][0]
            token = base64.b64decode(auth["authorizationToken"]).decode("utf-8")
            _, password = token.split(":", 1)
            endpoint = auth["proxyEndpoint"]
        except Exception as exc:
            raise _DeploymentError(f"ECR token fetch failed: {exc}")

        try:
            result = subprocess.run(
                ["docker", "login", "--username", "AWS", "--password-stdin", endpoint],
                input=password, text=True, capture_output=True, check=False,
            )
        except FileNotFoundError:
            raise _DeploymentError(
                "'docker' not found on PATH. Is Docker Desktop running / installed?"
            )
        if result.returncode != 0:
            raise _DeploymentError(f"docker login failed: {result.stderr.strip()}")
        console.print("  ✓ logged in to ECR")

    # --------------------------------------------------------------- step 4: docker build+push

    @staticmethod
    def _docker_build_push(ctx: dict, build_args: Optional[Dict[str, str]] = None) -> None:
        console.print("\n[bold]🔨 Step 4: Docker build + push[/bold]")
        console.print(f"  Platform: linux/amd64")
        console.print(f"  Target:   {ctx['ecr_url']}:{ctx['tag']}")

        build_arg_flags: List[str] = []
        for key, value in (build_args or {}).items():
            build_arg_flags += ["--build-arg", f"{key}={value}"]

        # Prefer docker buildx (one-shot build+push, no separate push command).
        buildx_available = (
            subprocess.run(
                ["docker", "buildx", "version"],
                capture_output=True, text=True,
            ).returncode == 0
        )

        if buildx_available:
            cmd = [
                "docker", "buildx", "build",
                "--platform", "linux/amd64",
                "--provenance=false",
                "--sbom=false",
                *build_arg_flags,
                "-t", f"{ctx['ecr_url']}:{ctx['tag']}",
                "--push",
                ".",
            ]
            try:
                subprocess.run(cmd, cwd=ctx["service_path"], check=True)
            except subprocess.CalledProcessError as exc:
                raise _DeploymentError(f"docker buildx failed (exit {exc.returncode}).")
        else:
            console.print("  [dim](docker buildx unavailable — falling back to build + push)[/dim]")
            build_cmd = [
                "docker", "build",
                "--platform", "linux/amd64",
                *build_arg_flags,
                "-t", f"{ctx['ecr_url']}:{ctx['tag']}",
                ".",
            ]
            push_cmd = ["docker", "push", f"{ctx['ecr_url']}:{ctx['tag']}"]
            try:
                subprocess.run(build_cmd, cwd=ctx["service_path"], check=True)
                subprocess.run(push_cmd, cwd=ctx["service_path"], check=True)
            except subprocess.CalledProcessError as exc:
                raise _DeploymentError(f"docker build/push failed (exit {exc.returncode}).")

        console.print("  ✓ built and pushed")

    # --------------------------------------------------------------- step 5: ECS deploy

    @staticmethod
    def _deploy_to_ecs(ctx: dict) -> None:
        console.print("\n[bold]🚀 Step 5: ECS deploy[/bold]")
        try:
            ecs = ctx["session"].client("ecs", region_name=ctx["region"])

            # First-run detection: if the service doesn't exist yet or is
            # INACTIVE (e.g. freshly deleted), UpdateService would fail with
            # ServiceNotFoundException / ServiceNotActiveException. That's
            # expected on first-time setup — the image is pushed; the CFN
            # stack that owns the service just hasn't been deployed yet.
            describe = ecs.describe_services(
                cluster=ctx["ecs_cluster"], services=[ctx["ecs_service"]]
            )
            existing = describe.get("services") or []
            status = existing[0].get("status") if existing else None

            if status != "ACTIVE":
                console.print(
                    Panel(
                        f"[yellow]ECS service '{ctx['ecs_service']}' is not ACTIVE "
                        f"(current status: {status or 'MISSING'}).\n\n"
                        f"This is expected on first-time setup or after a stack teardown —\n"
                        f"the CloudFormation stack that owns the service hasn't been deployed yet.\n\n"
                        f"[green]✓ Image built and pushed to ECR.[/green]\n\n"
                        f"[bold]Next:[/bold] deploy the stack that owns this service, e.g.\n"
                        f"  [cyan]canopycli aws cloudformation deploy "
                        f"{'ECS-Keycloak' if ctx['service'] == 'keycloak' else 'ECS'}[/cyan]\n\n"
                        f"Once the service is ACTIVE, re-run this command to push future updates.",
                        title="First-run — nothing to redeploy",
                        title_align="left",
                    ),
                    style=Style(color="yellow"),
                )
                return

            # Force-new-deployment on an existing ACTIVE service.
            ecs.update_service(
                cluster=ctx["ecs_cluster"],
                service=ctx["ecs_service"],
                desiredCount=1,
                forceNewDeployment=True,
            )
            console.print("  [dim]waiting for ECS to accept the deployment…[/dim]")

            # Poll PRIMARY deployment for up to 60s.
            max_attempts = 12
            desired_count = 0
            for attempt in range(1, max_attempts + 1):
                time.sleep(5)
                response = ecs.describe_services(
                    cluster=ctx["ecs_cluster"], services=[ctx["ecs_service"]]
                )
                service_desc = response["services"][0]
                primary = next(
                    (d for d in service_desc["deployments"] if d["status"] == "PRIMARY"),
                    None,
                )
                if primary:
                    desired_count = primary["desiredCount"]
                    if desired_count == 1:
                        console.print(
                            f"  ✓ PRIMARY deployment live (after {attempt * 5}s)"
                        )
                        return
                if attempt % 3 == 0:
                    console.print(
                        f"  [dim]still waiting (desired={desired_count}, {attempt * 5}s elapsed)[/dim]"
                    )

            console.print(
                f"  [yellow]⚠ Deployment verification timed out after 60s "
                f"(desired count: {desired_count}). Deployment may still succeed — "
                f"check the ECS console.[/yellow]"
            )
        except Exception as exc:
            raise _DeploymentError(f"ECS deployment failed: {exc}")

    # ---------------------------------------------------------- UI: .env.production

    @staticmethod
    def _ui_build_args(ctx: dict) -> Dict[str, str]:
        env_file = ctx["service_path"] / ".env.production"
        env_vars = BuildEcsWorker._load_env_file(env_file)

        build_args: Dict[str, str] = {}
        missing: List[str] = []
        for key in UI_BUILD_ARG_KEYS:
            value = env_vars.get(key) or os.environ.get(key, "")
            if value:
                build_args[key] = value
            elif key in UI_BUILD_ARG_REQUIRED:
                missing.append(key)

        if missing:
            raise _DeploymentError(
                "Required UI build args missing: " + ", ".join(missing) +
                f"\n    Add them to {env_file} or export them as environment variables."
                f"\n    Copy {ctx['service_path'] / '.env.example'} → {env_file} and fill in."
            )

        source = env_file if env_file.exists() else "environment variables"
        console.print(f"  [dim]UI build args loaded from {source}:[/dim]")
        for key, value in build_args.items():
            display = value if "GTAG" not in key else (value[:4] + "****")
            console.print(f"    [dim]{key}={display}[/dim]")
        return build_args

    @staticmethod
    def _load_env_file(path: Path) -> Dict[str, str]:
        """Parse a .env file; skip blanks/comments; shell env wins over file values."""
        out: Dict[str, str] = {}
        if not path.exists():
            return out
        try:
            with open(path) as f:
                for line in f:
                    line = line.strip()
                    if not line or line.startswith("#") or "=" not in line:
                        continue
                    key, _, value = line.partition("=")
                    key = key.strip()
                    value = value.strip().strip('"').strip("'")
                    out[key] = os.environ.get(key, value)
        except OSError as exc:
            console.print(f"  [yellow]⚠ could not read {path}: {exc}[/yellow]")
        return out


class _DeploymentError(Exception):
    """Raised by a pipeline step; caught at the top of deploy() for a uniform exit."""
    pass
