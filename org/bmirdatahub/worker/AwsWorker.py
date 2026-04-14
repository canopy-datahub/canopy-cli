import os
import subprocess
import sys

from rich.console import Console
from rich.panel import Panel
from rich.style import Style
from rich.table import Table
from rich.live import Live
from rich.text import Text

from org.bmirdatahub.worker.Worker import Worker
from org.bmirdatahub.util.GlobalContext import GlobalContext

console = Console()

# ---------------------------------------------------------------------------
# Stack registry
# ---------------------------------------------------------------------------
# Each entry maps a short stack name to its deploy configuration.
#   template  – path relative to the cloud-replication repo root
#   tags      – whether to append standard project/env tags
#   region    – whether to pass --region explicitly
#
# The "standard" pattern covers 90 % of stacks:
#     aws cloudformation deploy \
#       --stack-name ${PROJECT}-<Name>-${ENV} \
#       --template-file modules/<Name>.yaml \
#       --parameter-overrides file://${PARAM_FILE} \
#       --capabilities CAPABILITY_NAMED_IAM \
#       --profile ${AWS_PROFILE} \
#       --tags projectname=${PROJECT} environment=${ENV}
# ---------------------------------------------------------------------------

STACKS = {
    "Networking": {
        "template": "modules/Networking.yaml",
    },
    "S3": {
        "template": "modules/S3.yaml",
    },
    "LoadBalancer": {
        "template": "modules/LoadBalancer.yaml",
    },
    "RDS": {
        "template": "modules/RDS.yaml",
    },
    "Route53": {
        "template": "modules/Route53.yaml",
    },
    "CloudWatch": {
        "template": "modules/CloudWatch.yaml",
    },
    "SQS": {
        "template": "modules/SQS.yaml",
    },
    "ECR": {
        "template": "modules/ECR.yaml",
    },
    "OpenSearch": {
        "template": "modules/OpenSearch.yaml",
    },
    "SecretsManager": {
        "template": "modules/SecretsManager.yaml",
    },
    "Lambda": {
        "template": "modules/Lambda.yaml",
    },
    "ECS": {
        "template": "modules/ECS.yaml",
    },
    "ECS-Keycloak": {
        "template": "modules/ECS-Keycloak.yaml",
        "tags": False,
        "region": True,
    },
    "SES": {
        "template": "modules/SES.yaml",
    },
    "EventBridge": {
        "template": "modules/EventBridge.yaml",
    },
    "TransferFamily": {
        "template": "modules/TransferFamily.yaml",
    },
}


class AwsWorker(Worker):
    """Handles AWS CloudFormation operations."""

    # ---- required env vars ------------------------------------------------

    REQUIRED_VARS = [
        "CANOPY_PROJECT_NAME",
        "CANOPY_ENV",
        "CANOPY_AWS_PARAMETER_FILE",
        "CANOPY_CLOUD_REPLICATION",
        "AWS_PROFILE",
    ]

    # ---- helpers ----------------------------------------------------------

    @staticmethod
    def _get_env(name: str) -> str:
        """Return an env var or empty string."""
        return os.environ.get(name, "")

    @staticmethod
    def _check_env() -> bool:
        """Validate that all required environment variables are set.
        Prints a table and returns True if all present."""
        missing = []
        table = Table("Variable", "Value", title="AWS environment check")
        for var in AwsWorker.REQUIRED_VARS:
            val = AwsWorker._get_env(var)
            if val:
                table.add_row("[yellow]" + var, "[green]" + val)
            else:
                table.add_row("[yellow]" + var, "[red]NOT SET")
                missing.append(var)
        table.style = Style(color="green")
        console.print(table)
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
            return False
        return True

    # ---- public API -------------------------------------------------------

    @staticmethod
    def list_stacks():
        """Print a table of all known CloudFormation stacks."""
        templates_dir = AwsWorker._get_env("CANOPY_CLOUD_REPLICATION")
        table = Table("Stack Name", "Template", title="Available CloudFormation Stacks")
        for name, cfg in STACKS.items():
            full_path = os.path.join(templates_dir, cfg["template"]) if templates_dir else cfg["template"]
            table.add_row("[cyan]" + name, full_path)
        table.caption = f"{len(STACKS)} stacks — templates dir: {templates_dir or '(NOT SET)'}"
        table.style = Style(color="green")
        console.print(table)

    @staticmethod
    def deploy(stack_name: str, dry_run: bool = False):
        """Deploy a CloudFormation stack by its short name."""
        if stack_name not in STACKS:
            console.print(
                Panel(
                    f"[red]Unknown stack: [bold]{stack_name}[/bold]"
                    f"\n[yellow]Run [bold]canopycli aws cloudformation list[/bold] to see available stacks.",
                    title="Error",
                    title_align="left",
                ),
                style=Style(color="red"),
            )
            return

        if not AwsWorker._check_env():
            return

        cfg = STACKS[stack_name]
        project = AwsWorker._get_env("CANOPY_PROJECT_NAME")
        env = AwsWorker._get_env("CANOPY_ENV")
        param_file = AwsWorker._get_env("CANOPY_AWS_PARAMETER_FILE")
        templates_dir = AwsWorker._get_env("CANOPY_CLOUD_REPLICATION")
        profile = AwsWorker._get_env("AWS_PROFILE")
        region = AwsWorker._get_env("AWS_REGION")

        full_stack_name = f"{project}-{stack_name}-{env}"
        template_path = os.path.join(templates_dir, cfg["template"])

        # Build the command
        cmd_parts = [
            "aws", "cloudformation", "deploy",
            "--stack-name", full_stack_name,
            "--template-file", template_path,
            "--parameter-overrides", f"file://{param_file}",
            "--capabilities", "CAPABILITY_NAMED_IAM",
            "--profile", profile,
        ]

        # Some stacks need --region explicitly
        if cfg.get("region", False) and region:
            cmd_parts.extend(["--region", region])

        # Most stacks get standard tags
        if cfg.get("tags", True):
            cmd_parts.extend([
                "--tags",
                f"projectname={project}",
                f"environment={env}",
            ])

        cmd_string = " \\\n  ".join(cmd_parts)

        # Show what we're about to do
        panel_content = (
            f"[yellow] Stack     : [bold]{full_stack_name}[/bold]\n"
            f" Template  : {cfg['template']}\n"
            f" Profile   : {profile}\n"
            f" Region    : {region or '(default)'}\n"
            f" Command   :\n[dim]{cmd_string}[/dim]"
        )
        console.print(
            Panel(panel_content, title=f"CloudFormation Deploy: {stack_name}", title_align="left"),
            style=Style(color="yellow"),
        )

        if dry_run:
            console.print("[bold yellow]Dry run — command was NOT executed.[/bold yellow]")
            return

        # Execute
        console.print()
        cmd_flat = " ".join(cmd_parts)
        Worker.execute_generic_shell_commands(
            [cmd_flat],
            title=f"Deploying {stack_name}",
        )

        console.print()
        console.print(f"[bold green]Deploy command for {stack_name} finished.[/bold green]")

    @staticmethod
    def status(stack_name: str):
        """Check the status of a CloudFormation stack."""
        if not AwsWorker._check_env():
            return

        project = AwsWorker._get_env("CANOPY_PROJECT_NAME")
        env = AwsWorker._get_env("CANOPY_ENV")
        profile = AwsWorker._get_env("AWS_PROFILE")

        full_stack_name = f"{project}-{stack_name}-{env}"

        cmd = (
            f"aws cloudformation describe-stacks"
            f" --stack-name {full_stack_name}"
            f" --query 'Stacks[0].StackStatus'"
            f" --output text"
            f" --no-cli-pager"
            f" --profile {profile}"
        )

        Worker.execute_generic_shell_commands(
            [cmd],
            title=f"Status: {full_stack_name}",
        )

    @staticmethod
    def status_all():
        """Check the status of all known CloudFormation stacks."""
        if not AwsWorker._check_env():
            return

        project = AwsWorker._get_env("CANOPY_PROJECT_NAME")
        env = AwsWorker._get_env("CANOPY_ENV")
        profile = AwsWorker._get_env("AWS_PROFILE")

        cmd = (
            f"aws cloudformation list-stacks"
            f" --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE ROLLBACK_COMPLETE CREATE_IN_PROGRESS UPDATE_IN_PROGRESS"
            f" --query \"StackSummaries[?contains(StackName, '{project}')].{{Name:StackName,Status:StackStatus,Updated:LastUpdatedTime}}\""
            f" --output table"
            f" --no-cli-pager"
            f" --profile {profile}"
        )

        Worker.execute_generic_shell_commands(
            [cmd],
            title=f"All stacks for {project}",
        )
