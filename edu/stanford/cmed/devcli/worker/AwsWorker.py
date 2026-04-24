import json
import os
import subprocess
import sys
import webbrowser

from rich.console import Console
from rich.panel import Panel
from rich.style import Style
from rich.table import Table
from rich.live import Live
from rich.text import Text

from edu.stanford.cmed.devcli.worker.Worker import Worker

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
    "Bootstrap": {
        "template": "modules/Bootstrap.yaml",
    },
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

    # ---- S3 ---------------------------------------------------------------

    @staticmethod
    def s3_list():
        """List S3 buckets matching the project name."""
        if not AwsWorker._check_env():
            return

        project = AwsWorker._get_env("CANOPY_PROJECT_NAME")

        cmd = f"aws s3 ls | grep {project}"

        Worker.execute_generic_shell_commands(
            [cmd],
            title=f"S3 buckets matching '{project}'",
        )

    # ---- ELB --------------------------------------------------------------

    @staticmethod
    def elb_dns():
        """Show DNS names of load balancers matching the project."""
        if not AwsWorker._check_env():
            return

        project = AwsWorker._get_env("CANOPY_PROJECT_NAME")
        profile = AwsWorker._get_env("AWS_PROFILE")

        cmd = (
            f"aws elbv2 describe-load-balancers"
            f" --query \"LoadBalancers[?contains(LoadBalancerName, \\`{project}\\`)].DNSName\""
            f" --output text"
            f" --no-cli-pager"
            f" --profile {profile}"
        )

        Worker.execute_generic_shell_commands(
            [cmd],
            title=f"Load balancer DNS for '{project}'",
        )

    # ---- RDS --------------------------------------------------------------

    @staticmethod
    def rds_endpoint():
        """Show the RDS endpoint for the project database."""
        if not AwsWorker._check_env():
            return

        project = AwsWorker._get_env("CANOPY_PROJECT_NAME")
        env = AwsWorker._get_env("CANOPY_ENV")
        profile = AwsWorker._get_env("AWS_PROFILE")

        cmd = (
            f"aws rds describe-db-instances"
            f" --query \"DBInstances[?DBInstanceIdentifier==\\`{project}-postgresql-{env}\\`].Endpoint.Address\""
            f" --output text"
            f" --no-cli-pager"
            f" --profile {profile}"
        )

        Worker.execute_generic_shell_commands(
            [cmd],
            title=f"RDS endpoint for '{project}-postgresql-{env}'",
        )

    @staticmethod
    def rds_deploy_schema(dry_run: bool = False):
        """Deploy the RDS schema by delegating to DeployRdsWorker.

        The implementation lives in DeployRdsWorker (the script
        canopy-development/db/postgres/db-create-scripts/deploy_to_rds.py has
        been retired; only the SQL files remain on disk, at that same path).
        """
        from edu.stanford.cmed.devcli.worker.DeployRdsWorker import DeployRdsWorker
        DeployRdsWorker.deploy(dry_run=dry_run)

    # ---- CloudWatch Logs --------------------------------------------------

    @staticmethod
    def logs_list():
        """List CloudWatch log groups matching the project name."""
        if not AwsWorker._check_env():
            return

        project = AwsWorker._get_env("CANOPY_PROJECT_NAME")
        profile = AwsWorker._get_env("AWS_PROFILE")

        cmd = (
            f"aws logs describe-log-groups"
            f" --query \"logGroups[?contains(logGroupName, \\`{project}\\`)].logGroupName\""
            f" --no-cli-pager"
            f" --profile {profile}"
        )

        Worker.execute_generic_shell_commands(
            [cmd],
            title=f"Log groups matching '{project}'",
        )

    # ---- ECR --------------------------------------------------------------

    @staticmethod
    def ecr_list():
        """List ECR repositories matching the project name."""
        if not AwsWorker._check_env():
            return

        project = AwsWorker._get_env("CANOPY_PROJECT_NAME")
        profile = AwsWorker._get_env("AWS_PROFILE")

        cmd = (
            f"aws ecr describe-repositories"
            f" --query \"repositories[?contains(repositoryName, \\`{project}\\`)].repositoryName\""
            f" --no-cli-pager"
            f" --profile {profile}"
        )

        Worker.execute_generic_shell_commands(
            [cmd],
            title=f"ECR repositories matching '{project}'",
        )

    @staticmethod
    def ecr_list_images(service: str = None):
        """List image tags in project ECR repos.

        If ``service`` is provided, restricts the listing to
        ``<project>-<service>/<env>`` (e.g. ``keycloak`` → ``canopy-keycloak/prod``).
        If omitted, loops over every ECR repo whose name contains the project name
        and prints its tags.
        """
        if not AwsWorker._check_env():
            return

        project = AwsWorker._get_env("CANOPY_PROJECT_NAME")
        env = AwsWorker._get_env("CANOPY_ENV")
        profile = AwsWorker._get_env("AWS_PROFILE")

        if service:
            repository = f"{project}-{service}/{env}"
            cmd = (
                f"aws ecr list-images"
                f" --repository-name {repository}"
                f" --query 'imageIds[].imageTag'"
                f" --output text"
                f" --no-cli-pager"
                f" --profile {profile}"
            )
            Worker.execute_generic_shell_commands(
                [cmd],
                title=f"ECR image tags in '{repository}'",
            )
            return

        # No service filter — iterate every project-owned repo, one line per
        # repo: "<repository-name>   <tag1>, <tag2>, ..."  or "(no images)".
        cmd = (
            "for repo in $("
            f"aws ecr describe-repositories"
            f" --query \"repositories[?contains(repositoryName, \\`{project}\\`)].repositoryName\""
            f" --output text"
            f" --no-cli-pager"
            f" --profile {profile}"
            "); do "
            "  tags=$("
            f"aws ecr list-images"
            "    --repository-name \"$repo\""
            "    --query 'imageIds[].imageTag'"
            "    --output text"
            "    --no-cli-pager"
            f"    --profile {profile}"
            "  2>/dev/null); "
            "  if [ -z \"$tags\" ]; then "
            "    printf '%-40s %s\\n' \"$repo\" '(no images)'; "
            "  else "
            "    printf '%-40s %s\\n' \"$repo\" \"$(echo \"$tags\" | tr '\\t\\n' ',,' | sed 's/,/, /g; s/, $//')\"; "
            "  fi; "
            "done"
        )

        Worker.execute_generic_shell_commands(
            [cmd],
            title=f"ECR image tags across all '{project}'-prefixed repos",
        )

    # ---- Transfer Family --------------------------------------------------

    @staticmethod
    def transfer_endpoint():
        """Show the SFTP endpoint for the Transfer Family server."""
        if not AwsWorker._check_env():
            return

        profile = AwsWorker._get_env("AWS_PROFILE")
        region = AwsWorker._get_env("AWS_REGION")

        cmd = (
            f"SERVER_ID=$(aws transfer list-servers"
            f" --profile {profile}"
            f" --query 'Servers[0].ServerId'"
            f" --output text)"
            f" && echo \"SFTP Endpoint: ${{SERVER_ID}}.server.transfer.{region}.amazonaws.com\""
        )

        Worker.execute_generic_shell_commands(
            [cmd],
            title="SFTP Transfer Family endpoint",
        )

    # ---- EC2 --------------------------------------------------------------

    @staticmethod
    def ec2_allocate_eip():
        """Allocate an Elastic IP for SFTP."""
        if not AwsWorker._check_env():
            return

        project = AwsWorker._get_env("CANOPY_PROJECT_NAME")
        env = AwsWorker._get_env("CANOPY_ENV")
        profile = AwsWorker._get_env("AWS_PROFILE")

        tag_spec = (
            f"ResourceType=elastic-ip,Tags="
            f"[{{Key=Name,Value={project}-sftp-{env}}},"
            f"{{Key=projectname,Value={project}}},"
            f"{{Key=environment,Value={env}}}]"
        )

        cmd = (
            f"aws ec2 allocate-address"
            f" --domain vpc"
            f" --profile {profile}"
            f" --tag-specifications '{tag_spec}'"
        )

        console.print("[yellow]Note the AllocationId from the output (format: eipalloc-xxxxxxxx)[/yellow]")
        console.print()

        Worker.execute_generic_shell_commands(
            [cmd],
            title=f"Allocate Elastic IP for '{project}-sftp-{env}'",
        )

    @staticmethod
    def ec2_describe_eip():
        """List Elastic IPs tagged with this project's projectname/environment tags.

        Useful after allocate-eip: shows AllocationId (the value to paste into
        ElasticIPAllocationId in the param file) alongside PublicIp and Name.
        """
        if not AwsWorker._check_env():
            return

        project = AwsWorker._get_env("CANOPY_PROJECT_NAME")
        env = AwsWorker._get_env("CANOPY_ENV")
        profile = AwsWorker._get_env("AWS_PROFILE")

        cmd = (
            f"aws ec2 describe-addresses"
            f" --filters \"Name=tag:projectname,Values={project}\""
            f"           \"Name=tag:environment,Values={env}\""
            f" --query 'Addresses[*].{{Name:Tags[?Key==`Name`]|[0].Value,"
            f"AllocationId:AllocationId,"
            f"PublicIp:PublicIp,"
            f"AssociationId:AssociationId}}'"
            f" --output table"
            f" --no-cli-pager"
            f" --profile {profile}"
        )

        Worker.execute_generic_shell_commands(
            [cmd],
            title=f"Elastic IPs tagged projectname='{project}', environment='{env}'",
        )

    # ---- ECS --------------------------------------------------------------

    @staticmethod
    def ecs_deploy(service: str, tag: str = None, dry_run: bool = False):
        """Build + push a service image and trigger ECS deployment via BuildEcsWorker.

        Replaces the retired canopy-deployment-scripts/deploy.py. Covers all eight
        services (user-service, submission-service, report-service, download-service,
        entity-service, search-service, ui, keycloak) with the same pipeline:
        verify → Maven (backend) → ECR login → docker build+push → ECS UpdateService
        (first-run-aware).
        """
        from edu.stanford.cmed.devcli.worker.BuildEcsWorker import BuildEcsWorker
        BuildEcsWorker.deploy(service, tag=tag, dry_run=dry_run)

    @staticmethod
    def ecs_list_services():
        """List ECS services in the project cluster."""
        if not AwsWorker._check_env():
            return

        project = AwsWorker._get_env("CANOPY_PROJECT_NAME")
        env = AwsWorker._get_env("CANOPY_ENV")
        profile = AwsWorker._get_env("AWS_PROFILE")

        cluster = f"{project}-Services-{env}"

        cmd = (
            f"aws ecs list-services"
            f" --cluster {cluster}"
            f" --no-cli-pager"
            f" --profile {profile}"
        )

        Worker.execute_generic_shell_commands(
            [cmd],
            title=f"ECS services in cluster '{cluster}'",
        )

    # ---- Lambda -----------------------------------------------------------

    @staticmethod
    def lambda_list():
        """List Lambda functions matching the project name."""
        if not AwsWorker._check_env():
            return

        project = AwsWorker._get_env("CANOPY_PROJECT_NAME")
        profile = AwsWorker._get_env("AWS_PROFILE")

        cmd = (
            f"aws lambda list-functions"
            f" --query \"Functions[?contains(FunctionName, \\`{project}\\`)].FunctionName\""
            f" --no-cli-pager"
            f" --profile {profile}"
        )

        Worker.execute_generic_shell_commands(
            [cmd],
            title=f"Lambda functions matching '{project}'",
        )

    @staticmethod
    def lambda_deploy(target: str, dry_run: bool = False):
        """Build + upload a Lambda artifact via BuildLambdaWorker.

        Replaces the retired scripts:
          - canopy-development/opensearch/opensearch_reindex/deploy_lambda.py
            (target = opensearch-reindex)
          - the manual mvn + aws s3 cp sequence for canopy-service-email
            (target = email-service)
        """
        from edu.stanford.cmed.devcli.worker.BuildLambdaWorker import BuildLambdaWorker
        BuildLambdaWorker.deploy(target, dry_run=dry_run)

    @staticmethod
    def lambda_create_layer(name: str = "dependency-layer", dry_run: bool = False):
        """Build + publish the ARM64 Python 3.11 dependency layer via BuildLambdaWorker.

        Replaces the retired script
        canopy-development/opensearch/opensearch_reindex/create_layer.py.
        """
        from edu.stanford.cmed.devcli.worker.BuildLambdaWorker import BuildLambdaWorker
        BuildLambdaWorker.create_layer(name=name, dry_run=dry_run)

    @staticmethod
    def lambda_invoke(function_suffix: str):
        """Invoke a Lambda function and show the response inline."""
        if not AwsWorker._check_env():
            return

        project = AwsWorker._get_env("CANOPY_PROJECT_NAME")
        profile = AwsWorker._get_env("AWS_PROFILE")

        function_name = f"{project}-{function_suffix}"

        cmd = (
            f"aws lambda invoke"
            f" --function-name {function_name}"
            f" --payload '{{}}'"
            f" --cli-binary-format raw-in-base64-out"
            f" --profile {profile}"
            f" /dev/stdout"
        )

        Worker.execute_generic_shell_commands(
            [cmd],
            title=f"Invoking '{function_name}'",
        )

    # ---- Secrets Manager --------------------------------------------------

    @staticmethod
    def secrets_describe():
        """Describe the application secret for the project."""
        if not AwsWorker._check_env():
            return

        project = AwsWorker._get_env("CANOPY_PROJECT_NAME")
        env = AwsWorker._get_env("CANOPY_ENV")
        profile = AwsWorker._get_env("AWS_PROFILE")

        secret_id = f"{project}_application_{env}"

        cmd = (
            f"aws secretsmanager describe-secret"
            f" --secret-id {secret_id}"
            f" --no-cli-pager"
            f" --profile {profile}"
        )

        Worker.execute_generic_shell_commands(
            [cmd],
            title=f"Secret '{secret_id}'",
        )

    # ---- OpenSearch -------------------------------------------------------

    @staticmethod
    def opensearch_endpoint():
        """Show the OpenSearch VPC endpoint for the project."""
        if not AwsWorker._check_env():
            return

        project = AwsWorker._get_env("CANOPY_PROJECT_NAME")
        env = AwsWorker._get_env("CANOPY_ENV")
        profile = AwsWorker._get_env("AWS_PROFILE")

        domain = f"{project}-opensearch-{env}"

        cmd = (
            f"aws opensearch describe-domain"
            f" --domain-name {domain}"
            f" --query 'DomainStatus.Endpoints.vpc'"
            f" --output text"
            f" --no-cli-pager"
            f" --profile {profile}"
        )

        Worker.execute_generic_shell_commands(
            [cmd],
            title=f"OpenSearch VPC endpoint for '{domain}'",
        )

    # ---- SES --------------------------------------------------------------

    @staticmethod
    def ses_dkim(identity: str = None):
        """Show DKIM CNAME records to add to DNS for an SES identity.

        If ``identity`` is omitted, reads ``SenderDomain`` from the param file.
        Prints a two-column table of host + value for each of the three DKIM
        CNAMEs, plus the current verification status.
        """
        if not AwsWorker._check_env():
            return

        if not identity:
            identity = AwsWorker._param_value("SenderDomain")
            if not identity:
                console.print(
                    Panel(
                        "[red]No identity given and SenderDomain is empty in the param file."
                        "\n[yellow]Pass an identity as argument (canopycli aws ses dkim egyedia.com)"
                        " or set SenderDomain in your aws-parameters-*.json.",
                        title="Error",
                        title_align="left",
                    ),
                    style=Style(color="red"),
                )
                return

        profile = AwsWorker._get_env("AWS_PROFILE")
        region = AwsWorker._get_env("AWS_REGION") or "us-east-1"

        cmd = [
            "aws", "ses", "get-identity-dkim-attributes",
            "--identities", identity,
            "--profile", profile,
            "--region", region,
            "--output", "json",
            "--no-cli-pager",
        ]

        try:
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        except FileNotFoundError:
            console.print("[red]aws CLI not found on PATH.")
            return
        except subprocess.CalledProcessError as exc:
            console.print(
                Panel(
                    f"[red]aws ses get-identity-dkim-attributes failed (exit {exc.returncode}):\n"
                    f"[yellow]{(exc.stderr or exc.stdout or '').strip()}",
                    title="Error",
                    title_align="left",
                ),
                style=Style(color="red"),
            )
            return

        try:
            attrs = json.loads(result.stdout).get("DkimAttributes", {}).get(identity, {})
        except json.JSONDecodeError:
            console.print(f"[red]Could not parse AWS CLI output:\n{result.stdout}")
            return

        if not attrs:
            console.print(
                Panel(
                    f"[red]SES has no DKIM attributes for identity [bold]{identity}[/bold]."
                    f"\n[yellow]Likely the identity wasn't created yet — deploy the SES stack first.",
                    title="Error",
                    title_align="left",
                ),
                style=Style(color="red"),
            )
            return

        tokens = attrs.get("DkimTokens", []) or []
        status = attrs.get("DkimVerificationStatus", "Unknown")
        enabled = attrs.get("DkimEnabled", False)

        table = Table(
            "Type",
            "Host",
            "Value",
            title=f"DKIM CNAME records for '{identity}' — add all three to your DNS zone",
        )
        for token in tokens:
            table.add_row(
                "CNAME",
                f"{token}._domainkey.{identity}",
                f"{token}.dkim.amazonses.com",
            )
        table.style = Style(color="green")
        console.print(table)

        status_color = {
            "Success": "green",
            "Pending": "yellow",
            "Failed": "red",
            "NotStarted": "yellow",
            "TemporaryFailure": "yellow",
        }.get(status, "yellow")
        console.print(
            f"[bold]DkimEnabled:[/bold] {enabled}   "
            f"[bold]DkimVerificationStatus:[/bold] [{status_color}]{status}[/{status_color}]"
        )
        if status != "Success":
            console.print(
                "[dim]Once all three CNAMEs resolve in public DNS, SES flips the status to Success "
                "(usually minutes, sometimes up to 72 hours).[/dim]"
            )

    @staticmethod
    def ses_verification(identity: str = None):
        """Show the overall VerificationStatus for an SES identity (email or domain).

        If ``identity`` is omitted, reads ``SupportEmail`` from the param file.
        Use this for email identities; for domain identities, DKIM status from
        ``ses_dkim`` is more informative.
        """
        if not AwsWorker._check_env():
            return

        if not identity:
            identity = AwsWorker._param_value("SupportEmail")
            if not identity:
                console.print(
                    Panel(
                        "[red]No identity given and SupportEmail is empty in the param file."
                        "\n[yellow]Pass an identity as argument (canopycli aws ses verification someone@example.com)"
                        " or set SupportEmail in your aws-parameters-*.json.",
                        title="Error",
                        title_align="left",
                    ),
                    style=Style(color="red"),
                )
                return

        profile = AwsWorker._get_env("AWS_PROFILE")
        region = AwsWorker._get_env("AWS_REGION") or "us-east-1"

        cmd = [
            "aws", "ses", "get-identity-verification-attributes",
            "--identities", identity,
            "--profile", profile,
            "--region", region,
            "--output", "json",
            "--no-cli-pager",
        ]

        try:
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        except FileNotFoundError:
            console.print("[red]aws CLI not found on PATH.")
            return
        except subprocess.CalledProcessError as exc:
            console.print(
                Panel(
                    f"[red]aws ses get-identity-verification-attributes failed (exit {exc.returncode}):\n"
                    f"[yellow]{(exc.stderr or exc.stdout or '').strip()}",
                    title="Error",
                    title_align="left",
                ),
                style=Style(color="red"),
            )
            return

        try:
            attrs = json.loads(result.stdout).get("VerificationAttributes", {}).get(identity, {})
        except json.JSONDecodeError:
            console.print(f"[red]Could not parse AWS CLI output:\n{result.stdout}")
            return

        if not attrs:
            console.print(
                Panel(
                    f"[red]SES has no verification attributes for identity [bold]{identity}[/bold]."
                    f"\n[yellow]Likely the identity wasn't created yet — deploy the SES stack first.",
                    title="Error",
                    title_align="left",
                ),
                style=Style(color="red"),
            )
            return

        status = attrs.get("VerificationStatus", "Unknown")
        token = attrs.get("VerificationToken")

        status_color = {
            "Success": "green",
            "Pending": "yellow",
            "Failed": "red",
            "NotStarted": "yellow",
            "TemporaryFailure": "yellow",
        }.get(status, "yellow")

        console.print(
            Panel(
                f"[bold]Identity:[/bold] {identity}\n"
                f"[bold]VerificationStatus:[/bold] [{status_color}]{status}[/{status_color}]"
                + (f"\n[dim]Token: {token}[/dim]" if token else ""),
                title="SES identity verification status",
                title_align="left",
            ),
            style=Style(color="green" if status == "Success" else "yellow"),
        )

        if status != "Success":
            console.print(
                "[dim]For an [bold]email[/bold] identity, check the inbox — AWS sent a 'Verify your email' "
                "link that must be clicked. For a [bold]domain[/bold] identity, use "
                "[bold]canopycli aws ses dkim[/bold] to get the DKIM CNAMEs and add them to DNS.[/dim]"
            )

    # ---- Browser-open helpers --------------------------------------------

    # Short-name → URL-path-suffix mapping. Keep lowercase-hyphenated and obvious.
    _OPEN_TARGETS = {
        "keycloak-admin": "/admin/master/console/",
        "keycloak-realm": "/admin/CANOPY/console/",
        "app": "/",
    }

    @staticmethod
    def _param_value(key: str) -> str:
        """Read a single key from the Parameters block of CANOPY_AWS_PARAMETER_FILE.
        Returns empty string if the file is missing / unreadable / the key is absent."""
        param_path = AwsWorker._get_env("CANOPY_AWS_PARAMETER_FILE")
        if not param_path or not os.path.isfile(param_path):
            return ""
        try:
            with open(param_path, "r") as f:
                params = json.load(f).get("Parameters", {})
            return params.get(key) or ""
        except (json.JSONDecodeError, OSError):
            return ""

    @staticmethod
    def _public_hostname() -> str:
        """PublicHostname from the param file, with any trailing slash stripped."""
        return AwsWorker._param_value("PublicHostname").rstrip("/")

    @staticmethod
    def open_url(target: str):
        """Open ${PublicHostname}<suffix> for the given short target in the default browser."""
        if not AwsWorker._check_env():
            return

        if target not in AwsWorker._OPEN_TARGETS:
            console.print(
                Panel(
                    f"[red]Unknown target: [bold]{target}[/bold]"
                    f"\n[yellow]Available: " + ", ".join(AwsWorker._OPEN_TARGETS.keys()),
                    title="Error",
                    title_align="left",
                ),
                style=Style(color="red"),
            )
            return

        public_host = AwsWorker._public_hostname()
        if not public_host:
            console.print(
                Panel(
                    "[red]PublicHostname is not set in the param file."
                    "\n[yellow]Check CANOPY_AWS_PARAMETER_FILE and the 'PublicHostname' key.",
                    title="Error",
                    title_align="left",
                ),
                style=Style(color="red"),
            )
            return

        url = f"{public_host}{AwsWorker._OPEN_TARGETS[target]}"

        console.print(
            Panel(
                f"[yellow] Target : [bold]{target}[/bold]\n"
                f" URL    : [cyan]{url}[/cyan]",
                title="Opening in default browser",
                title_align="left",
            ),
            style=Style(color="yellow"),
        )

        if not webbrowser.open(url):
            console.print(
                "[red]Could not launch a browser. Open this URL manually: "
                f"[cyan]{url}[/cyan]"
            )
