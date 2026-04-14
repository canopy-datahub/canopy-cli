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


# ── Sub-group: canopycli aws s3 ──────────────────────────────────────────
s3_app = typer.Typer(no_args_is_help=True)
app.add_typer(s3_app, name="s3", help="S3 operations...")


@s3_app.command("list", help="List S3 buckets matching the project")
def s3_list():
    AwsWorker.s3_list()


# ── Sub-group: canopycli aws elb ─────────────────────────────────────────
elb_app = typer.Typer(no_args_is_help=True)
app.add_typer(elb_app, name="elb", help="Elastic Load Balancer operations...")


@elb_app.command("dns", help="Show load balancer DNS names for the project")
def elb_dns():
    AwsWorker.elb_dns()


# ── Sub-group: canopycli aws rds ─────────────────────────────────────────
rds_app = typer.Typer(no_args_is_help=True)
app.add_typer(rds_app, name="rds", help="RDS operations...")


@rds_app.command("endpoint", help="Show the RDS endpoint for the project database")
def rds_endpoint():
    AwsWorker.rds_endpoint()


# ── Sub-group: canopycli aws logs ────────────────────────────────────────
logs_app = typer.Typer(no_args_is_help=True)
app.add_typer(logs_app, name="logs", help="CloudWatch Logs operations...")


@logs_app.command("list", help="List CloudWatch log groups for the project")
def logs_list():
    AwsWorker.logs_list()


# ── Sub-group: canopycli aws ecr ─────────────────────────────────────────
ecr_app = typer.Typer(no_args_is_help=True)
app.add_typer(ecr_app, name="ecr", help="Elastic Container Registry operations...")


@ecr_app.command("list", help="List ECR repositories for the project")
def ecr_list():
    AwsWorker.ecr_list()


# ── Sub-group: canopycli aws secrets ─────────────────────────────────────
secrets_app = typer.Typer(no_args_is_help=True)
app.add_typer(secrets_app, name="secrets", help="Secrets Manager operations...")


@secrets_app.command("describe", help="Describe the application secret for the project")
def secrets_describe():
    AwsWorker.secrets_describe()


# ── Sub-group: canopycli aws opensearch ──────────────────────────────────
opensearch_app = typer.Typer(no_args_is_help=True)
app.add_typer(opensearch_app, name="opensearch", help="OpenSearch operations...")


@opensearch_app.command("endpoint", help="Show OpenSearch VPC endpoint for the project")
def opensearch_endpoint():
    AwsWorker.opensearch_endpoint()
