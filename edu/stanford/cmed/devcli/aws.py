import typer

from edu.stanford.cmed.devcli.worker.AwsWorker import AwsWorker

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


@rds_app.command("deploy-schema", help="Run the RDS schema deployment script (creates users, tables, views, and seed data)")
def rds_deploy_schema(
    dry_run: bool = typer.Option(False, "--dry-run", help="Show the command without executing it"),
):
    AwsWorker.rds_deploy_schema(dry_run)


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


@ecr_app.command(
    "list-images",
    help="List image tags in project ECR repos (all project repos, or filter to one by service name)",
)
def ecr_list_images(
    service: str = typer.Argument(
        None,
        help="Optional: one service name (e.g. keycloak, user-service) — restricts the listing to '<project>-<service>/<env>'. Omit to list all project repos.",
    ),
):
    AwsWorker.ecr_list_images(service)


# ── Sub-group: canopycli aws transfer ────────────────────────────────────
transfer_app = typer.Typer(no_args_is_help=True)
app.add_typer(transfer_app, name="transfer", help="Transfer Family operations...")


@transfer_app.command("endpoint", help="Show the SFTP Transfer Family endpoint")
def transfer_endpoint():
    AwsWorker.transfer_endpoint()


# ── Sub-group: canopycli aws ec2 ─────────────────────────────────────────
ec2_app = typer.Typer(no_args_is_help=True)
app.add_typer(ec2_app, name="ec2", help="EC2 operations...")


@ec2_app.command("allocate-eip", help="Allocate an Elastic IP for SFTP")
def ec2_allocate_eip():
    AwsWorker.ec2_allocate_eip()


@ec2_app.command("describe-eip", help="List Elastic IPs tagged for this project (shows AllocationId + PublicIp)")
def ec2_describe_eip():
    AwsWorker.ec2_describe_eip()


# ── Sub-group: canopycli aws ecs ─────────────────────────────────────────
ecs_app = typer.Typer(no_args_is_help=True)
app.add_typer(ecs_app, name="ecs", help="Elastic Container Service operations...")


@ecs_app.command("list-services", help="List ECS services in the project cluster")
def ecs_list_services():
    AwsWorker.ecs_list_services()


@ecs_app.command(
    "deploy",
    help="Build + push a service image and trigger ECS deployment (user-service, submission-service, …, ui, keycloak)",
)
def ecs_deploy(
    service: str = typer.Argument(
        ...,
        help=(
            "Service name. Options: user-service | submission-service | report-service | "
            "download-service | approved-data-service | entity-service | search-service | "
            "ui | keycloak"
        ),
    ),
    tag: str = typer.Option(
        None,
        "--tag",
        help=(
            "Docker image tag. Defaults to 'latest' for most services; for 'keycloak', "
            "defaults to the KeycloakImageTag value from the param file."
        ),
    ),
    dry_run: bool = typer.Option(False, "--dry-run", help="Show what would happen without executing"),
):
    AwsWorker.ecs_deploy(service, tag=tag, dry_run=dry_run)


# ── Sub-group: canopycli aws lambda ──────────────────────────────────────
lambda_app = typer.Typer(no_args_is_help=True)
app.add_typer(lambda_app, name="lambda", help="Lambda operations...")


@lambda_app.command("list", help="List Lambda functions for the project")
def lambda_list():
    AwsWorker.lambda_list()


@lambda_app.command("invoke", help="Invoke a Lambda function (e.g. OpenSearchRefresh)")
def lambda_invoke(
    function: str = typer.Argument(..., help="Function suffix (e.g. OpenSearchRefresh)"),
):
    AwsWorker.lambda_invoke(function)


@lambda_app.command("deploy", help="Build a Lambda artifact (code zip or Spring Boot jar) and upload it to S3")
def lambda_deploy(
    target: str = typer.Argument(
        ...,
        help="Target to build+upload. Options: opensearch-reindex | email-service",
    ),
    dry_run: bool = typer.Option(False, "--dry-run", help="Show what would happen without executing"),
):
    AwsWorker.lambda_deploy(target, dry_run)


@lambda_app.command(
    "create-layer",
    help="Build the ARM64 Python 3.11 dependency layer (Docker + pip) and publish it to Lambda",
)
def lambda_create_layer(
    name: str = typer.Option("dependency-layer", "--name", help="Layer name"),
    dry_run: bool = typer.Option(False, "--dry-run", help="Show what would happen without executing"),
):
    AwsWorker.lambda_create_layer(name, dry_run)


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


# ── Sub-group: canopycli aws ses ─────────────────────────────────────────
ses_app = typer.Typer(no_args_is_help=True)
app.add_typer(ses_app, name="ses", help="SES (Simple Email Service) operations...")


@ses_app.command("dkim", help="Show DKIM CNAME records to add to DNS for an SES identity")
def ses_dkim(
    identity: str = typer.Argument(
        None,
        help="Optional: SES identity (usually a domain, e.g. egyedia.com). If omitted, defaults to SenderDomain from the param file.",
    ),
):
    AwsWorker.ses_dkim(identity)


@ses_app.command("verification", help="Show the overall VerificationStatus for an SES identity (email or domain)")
def ses_verification(
    identity: str = typer.Argument(
        None,
        help="Optional: SES identity (email or domain). If omitted, defaults to SupportEmail from the param file.",
    ),
):
    AwsWorker.ses_verification(identity)


# ── Top-level: canopycli aws open ────────────────────────────────────────
@app.command("open", help="Open a project URL in your default browser")
def aws_open(
    target: str = typer.Argument(
        ...,
        help=(
            "What to open. Options: "
            "'keycloak-admin' (master realm console), "
            "'keycloak-realm' (CANOPY realm console), "
            "'app' (the app root)."
        ),
    ),
):
    AwsWorker.open_url(target)
