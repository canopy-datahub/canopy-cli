"""
Lambda artifact builders — ports the two helper scripts
  canopy-development/opensearch/opensearch_reindex/deploy_lambda.py
  (plus the manual 'email service' mvn/s3-cp sequence from DEPLOYMENT_GUIDE)
into canopycli so `canopycli aws lambda deploy <target>` is the single entry
point for both paths.

Each target produces one artifact and uploads it to
  s3://${project}-lambda-artifacts-${DeploymentId}-${env}/<target-path>/...
which is the location the Lambda CFN stack expects.
"""

import json
import os
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path
from typing import List, Optional

from rich.console import Console
from rich.panel import Panel
from rich.style import Style
from rich.table import Table

console = Console()


# Registry of available targets — add new Lambdas here.
TARGETS = ("opensearch-reindex", "email-service")


class BuildLambdaWorker:
    """Builds + uploads Lambda artifacts to the project's `lambda-artifacts` S3 bucket."""

    @staticmethod
    def deploy(target: str, dry_run: bool = False) -> None:
        if target not in TARGETS:
            console.print(
                Panel(
                    f"[red]Unknown Lambda target: [bold]{target}[/bold]"
                    f"\n[yellow]Available targets: " + ", ".join(TARGETS),
                    title="Error",
                    title_align="left",
                ),
                style=Style(color="red"),
            )
            return

        ctx = BuildLambdaWorker._resolve_context()
        if ctx is None:
            return

        if target == "opensearch-reindex":
            BuildLambdaWorker._deploy_opensearch_reindex(ctx, dry_run)
        elif target == "email-service":
            BuildLambdaWorker._deploy_email_service(ctx, dry_run)

    # ------------------------------------------------------------------ context

    @staticmethod
    def _resolve_context() -> Optional[dict]:
        """Collect env vars, read DeploymentId from the param file, validate everything."""
        canopy_home = os.environ.get("CANOPY_HOME", "")
        project = os.environ.get("CANOPY_PROJECT_NAME", "")
        env = os.environ.get("CANOPY_ENV", "")
        profile = os.environ.get("AWS_PROFILE", "")

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

        deployment_id = BuildLambdaWorker._param_value("DeploymentId")
        if not deployment_id:
            console.print(
                Panel(
                    "[red]DeploymentId not found in the param file."
                    "\n[yellow]Check CANOPY_AWS_PARAMETER_FILE — 'DeploymentId' under Parameters.",
                    title="Error",
                    title_align="left",
                ),
                style=Style(color="red"),
            )
            return None

        return {
            "canopy_home": Path(canopy_home),
            "project": project,
            "env": env,
            "profile": profile,
            "deployment_id": deployment_id,
            "bucket": f"{project}-lambda-artifacts-{deployment_id}-{env}",
        }

    @staticmethod
    def _param_value(key: str) -> str:
        """Read a key from the Parameters block of CANOPY_AWS_PARAMETER_FILE."""
        param_path = os.environ.get("CANOPY_AWS_PARAMETER_FILE", "")
        if not param_path or not Path(param_path).is_file():
            return ""
        try:
            with open(param_path, "r") as f:
                params = json.load(f).get("Parameters", {})
            return params.get(key) or ""
        except (json.JSONDecodeError, OSError):
            return ""

    @staticmethod
    def _require_tool(name: str) -> bool:
        if shutil.which(name):
            return True
        console.print(f"[red]Required tool '{name}' not found on PATH.[/red]")
        return False

    # --------------------------------------------------- target: opensearch-reindex

    @staticmethod
    def _deploy_opensearch_reindex(ctx: dict, dry_run: bool) -> None:
        """Zip the OpenSearch-reindex Python code + mapping JSONs, upload to S3."""
        if not BuildLambdaWorker._require_tool("aws"):
            return

        source_dir = ctx["canopy_home"] / "canopy-development" / "opensearch" / "opensearch_reindex"
        if not source_dir.is_dir():
            console.print(
                f"[red]Source directory not found: {source_dir}"
            )
            return

        required_files = [
            "opensearch_reindex_aws.py",
            "variable_index_mapping.json",
            "search_index_mapping.json",
            "autocomplete_index_mapping.json",
        ]
        missing = [f for f in required_files if not (source_dir / f).is_file()]
        if missing:
            console.print(
                Panel(
                    "[red]Required files missing from " + str(source_dir) + ":\n"
                    + "\n".join(f"  - {f}" for f in missing),
                    title="Error",
                    title_align="left",
                ),
                style=Style(color="red"),
            )
            return

        artifact_name = "opensearch-refresh-lambda.zip"
        artifact_path = source_dir / artifact_name
        s3_key = f"opensearch-refresh/{artifact_name}"
        s3_uri = f"s3://{ctx['bucket']}/{s3_key}"

        BuildLambdaWorker._print_summary(
            "opensearch-reindex",
            [
                ("Source dir",  str(source_dir)),
                ("Files",       ", ".join(required_files)),
                ("Artifact",    str(artifact_path)),
                ("S3 target",   s3_uri),
                ("Bucket",      ctx["bucket"]),
            ],
        )

        if dry_run:
            console.print("[bold yellow]Dry run — no zip/upload performed.[/bold yellow]")
            return

        # Build the zip — Lambda expects files at the root of the archive, no prefix.
        console.print("\n[bold]→ Building zip[/bold]")
        if artifact_path.exists():
            artifact_path.unlink()
        with zipfile.ZipFile(artifact_path, "w", zipfile.ZIP_DEFLATED) as zf:
            for f in required_files:
                zf.write(source_dir / f, arcname=f)
                console.print(f"    + {f}")
        size_bytes = artifact_path.stat().st_size
        console.print(f"  Package size: [cyan]{size_bytes / 1024:.2f} KB[/cyan]")

        # Layer-vs-code sanity check: the reindex lambda depends on heavy
        # Python libs (psycopg2-binary, opensearch-py, …) which live in the
        # Lambda layer (see `canopycli aws lambda create-layer`), not in this
        # package. A package >1 MB usually means the layer content leaked into
        # the code zip — warn but don't block.
        if size_bytes > 1024 * 1024:
            console.print(
                "  [yellow]⚠ Package is larger than 1 MB — "
                "the layer's dependencies may have leaked into the code zip.[/yellow]"
            )

        BuildLambdaWorker._s3_upload(artifact_path, s3_uri, ctx["profile"])
        BuildLambdaWorker._done(
            ctx,
            target="opensearch-reindex",
            s3_uri=s3_uri,
            update_hint=f"aws lambda update-function-code "
                        f"--function-name {ctx['project']}-OpenSearchRefresh "
                        f"--s3-bucket {ctx['bucket']} --s3-key {s3_key} "
                        f"--profile {ctx['profile']}",
        )

    # --------------------------------------------------------- target: email-service

    @staticmethod
    def _deploy_email_service(ctx: dict, dry_run: bool) -> None:
        """Maven-build the Spring Boot Lambda jar, upload to S3."""
        if not BuildLambdaWorker._require_tool("mvn"):
            return
        if not BuildLambdaWorker._require_tool("aws"):
            return

        source_dir = ctx["canopy_home"] / "datahub-service-email"
        pom = source_dir / "pom.xml"
        if not pom.is_file():
            console.print(
                Panel(
                    f"[red]pom.xml not found at {pom}"
                    f"\n[yellow]Ensure the datahub-service-email repo is cloned under CANOPY_HOME.",
                    title="Error",
                    title_align="left",
                ),
                style=Style(color="red"),
            )
            return

        BuildLambdaWorker._print_summary(
            "email-service",
            [
                ("Source dir", str(source_dir)),
                ("Build cmd",  "mvn clean package -DskipTests"),
                ("S3 bucket",  ctx["bucket"]),
                ("S3 prefix",  "email-service/"),
            ],
        )

        if dry_run:
            console.print("[bold yellow]Dry run — no build/upload performed.[/bold yellow]")
            return

        console.print("\n[bold]→ Maven build[/bold]")
        mvn = "mvn.cmd" if sys.platform == "win32" else "mvn"
        try:
            subprocess.run(
                [mvn, "clean", "package", "-DskipTests", "-q"],
                cwd=source_dir, check=True,
            )
        except subprocess.CalledProcessError as exc:
            console.print(f"[red]Maven build failed (exit {exc.returncode}).[/red]")
            return

        # Prefer the -aws.jar variant (Spring Boot Lambda bundle). Fall back to
        # any non-sources/javadoc jar if the -aws variant isn't produced.
        target_dir = source_dir / "target"
        aws_jars = [
            p for p in target_dir.glob("*-aws.jar")
            if not p.name.endswith("-sources.jar") and not p.name.endswith("-javadoc.jar")
        ]
        other_jars = [
            p for p in target_dir.glob("*.jar")
            if not p.name.endswith("-sources.jar")
            and not p.name.endswith("-javadoc.jar")
            and not p.name.endswith("-aws.jar")
        ]
        jars = aws_jars or other_jars
        if not jars:
            console.print(f"[red]No jar found in {target_dir} after build.[/red]")
            return
        jar = jars[0]
        if len(aws_jars) > 1 or (not aws_jars and len(other_jars) > 1):
            console.print(
                f"[yellow]Multiple jars found; using {jar.name}.[/yellow]"
            )

        s3_key = f"email-service/{jar.name}"
        s3_uri = f"s3://{ctx['bucket']}/{s3_key}"
        console.print(f"  Jar: [cyan]{jar.name}[/cyan] ({jar.stat().st_size / 1024 / 1024:.2f} MB)")

        BuildLambdaWorker._s3_upload(jar, s3_uri, ctx["profile"])
        BuildLambdaWorker._done(
            ctx,
            target="email-service",
            s3_uri=s3_uri,
            update_hint=f"aws lambda update-function-code "
                        f"--function-name {ctx['project']}-EmailService-{ctx['env']} "
                        f"--s3-bucket {ctx['bucket']} --s3-key {s3_key} "
                        f"--profile {ctx['profile']}",
        )

    # ------------------------------------------------------------ shared helpers

    @staticmethod
    def _s3_upload(local: Path, s3_uri: str, profile: str) -> None:
        console.print(f"\n[bold]→ Uploading to {s3_uri}[/bold]")
        try:
            subprocess.run(
                ["aws", "s3", "cp", str(local), s3_uri, "--profile", profile],
                check=True,
            )
        except subprocess.CalledProcessError as exc:
            console.print(f"[red]aws s3 cp failed (exit {exc.returncode}).[/red]")
            sys.exit(1)

    @staticmethod
    def _print_summary(target: str, rows: List[tuple]) -> None:
        table = Table("Field", "Value", title=f"Lambda deploy: {target}")
        for k, v in rows:
            table.add_row(f"[yellow]{k}[/yellow]", v)
        table.style = Style(color="yellow")
        console.print(table)

    @staticmethod
    def _done(ctx: dict, *, target: str, s3_uri: str, update_hint: str) -> None:
        console.print()
        console.print(
            Panel(
                f"[green]Artifact uploaded: {s3_uri}[/green]\n\n"
                f"[yellow]Next steps:[/yellow]\n"
                f"  • First deploy — the Lambda CFN stack reads this S3 key on create:\n"
                f"    canopycli aws cloudformation deploy Lambda\n"
                f"  • Subsequent updates — force Lambda to pick up the new code:\n[dim]"
                f"    {update_hint}[/dim]",
                title=f"Done — {target}",
                title_align="left",
            ),
            style=Style(color="green"),
        )
