import typer

from org.bmirdatahub.worker.AwsWorker import AwsWorker

# ── Top-level: canopycli aws ──────────────────────────────────────────────
app = typer.Typer(no_args_is_help=True)

# ── Sub-group: canopycli aws cloudformation ───────────────────────────────
cloudformation_app = typer.Typer(no_args_is_help=True)
app.add_typer(cloudformation_app, name="cloudformation", help="CloudFormation operations...")


@cloudformation_app.command("deploy", help="Deploy a CloudFormation stack")
def cf_deploy(
    stack: str = typer.Argument(..., help="Stack name (e.g. Networking, S3, ECS-Keycloak). Use 'list' to see all."),
    dry_run: bool = typer.Option(False, "--dry-run", help="Show the command without executing it"),
):
    AwsWorker.deploy(stack, dry_run)


@cloudformation_app.command("status", help="Check status of a deployed stack")
def cf_status(
    stack: str = typer.Argument(..., help="Stack name to check (e.g. Networking, RDS)"),
):
    AwsWorker.status(stack)


@cloudformation_app.command("status-all", help="Check status of all project stacks")
def cf_status_all():
    AwsWorker.status_all()


@cloudformation_app.command("list", help="List all available CloudFormation stacks")
def cf_list():
    AwsWorker.list_stacks()
