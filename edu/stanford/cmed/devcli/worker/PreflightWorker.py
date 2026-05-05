"""
Preflight checks for `canopycli aws` deploys.

Walks every CloudFormation module the install would push, extracts each
explicitly-named resource, resolves its name against the param file and
environment, then runs two checks per resource:

  1. NAME SANITY — length + character-set + AWS-specific quirks. Catches the
     common foot-gun where a long ProjectName overflows tight resource-name
     limits (OpenSearch's 28-char ceiling is the main one).

  2. EXISTENCE — describe the resource via the AWS CLI. If it already exists
     in the target account/region, the install will fail; user must delete
     (or wait, for pending-deletion secrets) before retrying.

Also probes every CloudFormation stack itself, so leftover ROLLBACK_COMPLETE
stacks from a half-failed previous deploy are reported up front.

Invoked from AwsWorker via `canopycli aws preflight`.
"""

from __future__ import annotations

import json
import os
import re
import subprocess
import sys
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Callable, Dict, List, Optional, Tuple

import yaml
from rich.console import Console
from rich.markup import escape as rich_escape
from rich.panel import Panel
from rich.style import Style
from rich.table import Table

console = Console()


# ---------------------------------------------------------------------------
# Stacks the install deploys. Mirrors AwsWorker.STACKS — kept here to avoid a
# circular import. If the install set ever changes, update both lists.
# ---------------------------------------------------------------------------

STACKS: List[Tuple[str, str]] = [
    ("Bootstrap", "modules/Bootstrap.yaml"),
    ("Networking", "modules/Networking.yaml"),
    ("S3", "modules/S3.yaml"),
    ("LoadBalancer", "modules/LoadBalancer.yaml"),
    ("RDS", "modules/RDS.yaml"),
    ("CloudWatch", "modules/CloudWatch.yaml"),
    ("SQS", "modules/SQS.yaml"),
    ("ECR", "modules/ECR.yaml"),
    ("OpenSearch", "modules/OpenSearch.yaml"),
    ("SecretsManager", "modules/SecretsManager.yaml"),
    ("Lambda", "modules/Lambda.yaml"),
    ("ECS", "modules/ECS.yaml"),
    ("ECS-Keycloak", "modules/ECS-Keycloak.yaml"),
    ("SES", "modules/SES.yaml"),
    ("EventBridge", "modules/EventBridge.yaml"),
    ("TransferFamily", "modules/TransferFamily.yaml"),
]


# ---------------------------------------------------------------------------
# CFN intrinsic-function loader. PyYAML chokes on `!Sub` etc. unless we
# register constructors. We model each as a small object so the resolver can
# walk them; only !Sub and !Ref produce a fully-rendered string. !GetAtt /
# !ImportValue / !Join are treated as "unresolvable" for name fields.
# ---------------------------------------------------------------------------


class _Intrinsic:
    def __init__(self, tag: str, value):
        self.tag = tag
        self.value = value

    def __repr__(self):
        return f"<{self.tag} {self.value!r}>"


def _intrinsic_constructor(tag: str):
    def _c(loader, node):
        if isinstance(node, yaml.ScalarNode):
            return _Intrinsic(tag, loader.construct_scalar(node))
        if isinstance(node, yaml.SequenceNode):
            return _Intrinsic(tag, loader.construct_sequence(node, deep=True))
        if isinstance(node, yaml.MappingNode):
            return _Intrinsic(tag, loader.construct_mapping(node, deep=True))
        return _Intrinsic(tag, None)

    return _c


class _CfnLoader(yaml.SafeLoader):
    pass


for _tag in (
    "!Ref", "!Sub", "!GetAtt", "!Join", "!Select", "!Split",
    "!FindInMap", "!ImportValue", "!Equals", "!And", "!Or", "!Not",
    "!If", "!Condition", "!GetAZs", "!Base64", "!Cidr", "!Transform",
):
    _CfnLoader.add_constructor(_tag, _intrinsic_constructor(_tag.lstrip("!")))


# ---------------------------------------------------------------------------
# Resolver — turn an _Intrinsic (or scalar) into a final string, given the
# parameter map. Unresolvable references return None.
# ---------------------------------------------------------------------------


_PSEUDO_PARAMS = {"AWS::Region", "AWS::AccountId", "AWS::StackName",
                  "AWS::Partition", "AWS::URLSuffix", "AWS::NoValue"}

# When a Sub string contains `${LogicalId.Attribute}`, CFN's resolution depends
# on the sibling resource's deploy-time attributes. For a small set of well-
# known cases the attribute is provably equal to the resource's own explicit
# `*Name` property. Map (resource_type, attribute) -> name_property so the
# resolver can chase those references without actually deploying.
_GETATT_NAME_ALIASES: Dict[Tuple[str, str], str] = {
    ("AWS::ElasticLoadBalancingV2::TargetGroup", "TargetGroupName"): "Name",
    ("AWS::ElasticLoadBalancingV2::LoadBalancer", "LoadBalancerName"): "Name",
    ("AWS::ECR::Repository", "RepositoryName"): "RepositoryName",
    ("AWS::S3::Bucket", "BucketName"): "BucketName",
    ("AWS::SQS::Queue", "QueueName"): "QueueName",
    ("AWS::Logs::LogGroup", "LogGroupName"): "LogGroupName",
    ("AWS::IAM::Role", "RoleName"): "RoleName",
}


def _resolve(value, params: Dict[str, str],
             siblings: Optional[Dict[str, str]] = None) -> Optional[str]:
    """Render a CFN value to a string. Returns None if it depends on
    !GetAtt / !ImportValue / !Join (unsupported), or a missing parameter.
    `siblings` maps `LogicalId` and `LogicalId.Attribute` keys to already-
    resolved names from the same template (see _resolve_template)."""
    if isinstance(value, str):
        return value
    if not isinstance(value, _Intrinsic):
        return None

    if value.tag == "Ref":
        key = value.value
        if key in _PSEUDO_PARAMS:
            return params.get(key, f"<{key}>")
        if siblings and key in siblings:
            return siblings[key]
        return params.get(key)

    if value.tag == "Sub":
        # !Sub "literal-${X}-${Y}" — string form.
        # !Sub [str, {X: ..., Y: ...}] — list form (rare in our templates).
        if isinstance(value.value, list):
            tmpl = value.value[0]
            local = value.value[1] if len(value.value) > 1 else {}
            return _expand_sub(tmpl, params, local, siblings)
        if isinstance(value.value, str):
            return _expand_sub(value.value, params, {}, siblings)
        return None

    # !Join, !GetAtt, !ImportValue, etc — all unresolvable for name purposes.
    return None


_SUB_PLACEHOLDER = re.compile(r"\$\{([^}]+)\}")


def _expand_sub(template: str, params: Dict[str, str],
                local: Dict[str, object],
                siblings: Optional[Dict[str, str]] = None) -> Optional[str]:
    out = []
    last = 0
    for m in _SUB_PLACEHOLDER.finditer(template):
        out.append(template[last:m.start()])
        key = m.group(1)
        if key in local:
            sub_val = _resolve(local[key], params, siblings)
            if sub_val is None:
                return None
            out.append(sub_val)
        elif key in _PSEUDO_PARAMS:
            out.append(params.get(key, f"<{key}>"))
        elif key in params:
            out.append(params[key])
        elif siblings and key in siblings:
            # `${LogicalId}` or `${LogicalId.Attribute}` — sibling reference.
            out.append(siblings[key])
        else:
            return None  # unresolved Sub variable
        last = m.end()
    out.append(template[last:])
    return "".join(out)


def _eval_condition(value, params: Dict[str, str]) -> bool:
    """Evaluate a CloudFormation Condition against resolved parameters.
    Handles the intrinsics canopy templates actually use: !Equals, !Not,
    !And, !Or, plus !Ref to a parameter. If we can't decide, default to
    True so we don't accidentally swallow a real conflict."""
    if value is None:
        return True
    if isinstance(value, bool):
        return value
    if isinstance(value, _Intrinsic):
        if value.tag == "Equals" and isinstance(value.value, list) and len(value.value) == 2:
            a = _resolve(value.value[0], params)
            b = _resolve(value.value[1], params)
            return a == b
        if value.tag == "Not" and isinstance(value.value, list) and len(value.value) == 1:
            return not _eval_condition(value.value[0], params)
        if value.tag == "And" and isinstance(value.value, list):
            return all(_eval_condition(v, params) for v in value.value)
        if value.tag == "Or" and isinstance(value.value, list):
            return any(_eval_condition(v, params) for v in value.value)
        if value.tag == "Condition" and isinstance(value.value, str):
            # Reference to another named condition — caller doesn't supply
            # the conditions table, so we conservatively return True.
            return True
    return True


_PLACEHOLDER_RE = re.compile(r"replaceme|REPLACEME", re.IGNORECASE)


# ---------------------------------------------------------------------------
# Parameter-value sanity rules. Some AWS resources reject passwords or other
# values that don't meet specific complexity rules — those rejections happen
# only at deploy time, often 10+ minutes in. Catch them up-front.
# ---------------------------------------------------------------------------


def _check_complex_password(value: str) -> List[str]:
    """AWS OpenSearch / RDS Aurora master-password rule: ≥1 upper, ≥1 lower,
    ≥1 digit, ≥1 special. OpenSearch rejects passwords that don't satisfy
    this with `Invalid request: The master user password must contain at
    least one uppercase letter, one lowercase letter, one number, and one
    special character.` Returns a list of issue messages (empty = OK)."""
    issues = []
    if len(value) < 8:
        issues.append("must be at least 8 characters")
    if not re.search(r"[A-Z]", value):
        issues.append("must contain at least one uppercase letter")
    if not re.search(r"[a-z]", value):
        issues.append("must contain at least one lowercase letter")
    if not re.search(r"\d", value):
        issues.append("must contain at least one digit")
    if not re.search(r"[^A-Za-z0-9]", value):
        issues.append("must contain at least one special character")
    return issues


# Per-parameter rules. Each entry is (param_key, label, validator).
PARAM_RULES: List[Tuple[str, str, Callable[[str], List[str]]]] = [
    ("OpenSearchPassword", "OpenSearch master password",
     _check_complex_password),
    # Add more here as we hit them — DbMasterPassword and KeycloakAdminPassword
    # are commonly affected too.
]


def _resolve_cluster_ref(value, params: Dict[str, str],
                         siblings: Dict[str, str]) -> Optional[str]:
    """Best-effort resolve an ECS service's `Cluster` property to a cluster
    name. Handles literal strings, !Ref to a sibling cluster, !GetAtt
    SomeCluster.Arn (where the LogicalId is a sibling), and !Sub. Cross-
    stack !ImportValue is not resolved here — fallback to global cluster
    enumeration handles that case."""
    if value is None:
        return None
    if isinstance(value, str):
        # Literal cluster name or ARN — extract the trailing cluster name.
        if value.startswith("arn:aws:ecs:"):
            return value.rsplit("/", 1)[-1]
        return value
    if isinstance(value, _Intrinsic):
        if value.tag == "Ref":
            key = value.value
            return siblings.get(key) or params.get(key)
        if value.tag == "GetAtt":
            target = value.value
            if isinstance(target, list) and target:
                return siblings.get(target[0])
            if isinstance(target, str):
                return siblings.get(target.split(".", 1)[0])
        if value.tag == "Sub":
            return _resolve(value, params, siblings)
    return None


def _resolve_template_names(resources: Dict[str, dict],
                            params: Dict[str, str]) -> Dict[str, str]:
    """For one template's `Resources` map, build a `siblings` dict mapping
    both `LogicalId` and `LogicalId.Attribute` to resolved names — for every
    resource whose name we can render from params alone, plus a second pass
    for resources whose names reference siblings already resolved in pass 1.
    """
    siblings: Dict[str, str] = {}
    # Pass 1: resources whose name depends only on params.
    for logical_id, body in resources.items():
        rtype = body.get("Type")
        spec = REGISTRY.get(rtype)
        if not spec:
            continue
        props = (body.get("Properties") or {})
        if spec.name_prop not in props:
            continue
        rendered = _resolve(props[spec.name_prop], params, siblings=None)
        if rendered is None:
            continue
        siblings[logical_id] = rendered
        # Register every known GetAtt alias for this type.
        for (rt, attr), name_prop in _GETATT_NAME_ALIASES.items():
            if rt == rtype and name_prop == spec.name_prop:
                siblings[f"{logical_id}.{attr}"] = rendered

    # Pass 2: resources whose name references siblings now resolved.
    progress = True
    while progress:
        progress = False
        for logical_id, body in resources.items():
            if logical_id in siblings:
                continue
            rtype = body.get("Type")
            spec = REGISTRY.get(rtype)
            if not spec:
                continue
            props = (body.get("Properties") or {})
            if spec.name_prop not in props:
                continue
            rendered = _resolve(props[spec.name_prop], params, siblings)
            if rendered is None:
                continue
            siblings[logical_id] = rendered
            for (rt, attr), name_prop in _GETATT_NAME_ALIASES.items():
                if rt == rtype and name_prop == spec.name_prop:
                    siblings[f"{logical_id}.{attr}"] = rendered
            progress = True
    return siblings


# ---------------------------------------------------------------------------
# Per-type rules. Each entry says:
#   name_prop  — the YAML property that holds the explicit physical name.
#                If None, the resource is auto-named and we skip it (CFN
#                will pick a unique suffix; can't conflict by name).
#   validate   — function that returns a list of issues (empty = OK).
#   probe_cmd  — function that returns the `aws ...` arg list to check
#                whether the resource exists.
#   probe_parse — function (rc, stdout, stderr) -> "exists"/"absent"/"warn"
#                + optional detail string.
# ---------------------------------------------------------------------------


@dataclass
class NameIssue:
    severity: str   # "error" | "warn"
    message: str


def _len(min_, max_):
    def check(name: str) -> List[NameIssue]:
        if len(name) < min_:
            return [NameIssue("error", f"too short ({len(name)} < {min_})")]
        if len(name) > max_:
            return [NameIssue("error",
                              f"too long ({len(name)} > {max_}); shorten ProjectName/Environment")]
        return []
    return check


def _re(pattern: str, why: str):
    rx = re.compile(pattern)

    def check(name: str) -> List[NameIssue]:
        if not rx.fullmatch(name):
            return [NameIssue("error", f"{why} (does not match `{pattern}`)")]
        return []
    return check


def _all(*fns):
    def check(name: str) -> List[NameIssue]:
        issues: List[NameIssue] = []
        for fn in fns:
            issues.extend(fn(name))
        return issues
    return check


def _validate_s3_bucket(name: str) -> List[NameIssue]:
    issues: List[NameIssue] = []
    if not (3 <= len(name) <= 63):
        issues.append(NameIssue("error", f"length {len(name)} not in 3..63"))
    if not re.fullmatch(r"[a-z0-9.\-]+", name):
        issues.append(NameIssue("error", "must be lowercase a-z 0-9 . -"))
    if not name or not (name[0].isalnum() and name[-1].isalnum()):
        issues.append(NameIssue("error", "must start and end with a letter or digit"))
    if ".." in name or ".-" in name or "-." in name:
        issues.append(NameIssue("error", "no `..`, `.-`, or `-.` allowed"))
    if re.fullmatch(r"\d+\.\d+\.\d+\.\d+", name):
        issues.append(NameIssue("error", "must not be IP-formatted"))
    for prefix in ("xn--", "sthree-", "amzn-s3-demo-"):
        if name.startswith(prefix):
            issues.append(NameIssue("error", f"must not start with `{prefix}`"))
    for suffix in ("-s3alias", "--ol-s3", ".mrap", "--x-s3"):
        if name.endswith(suffix):
            issues.append(NameIssue("error", f"must not end with `{suffix}`"))
    return issues


def _validate_ecr_repo(name: str) -> List[NameIssue]:
    issues = _len(2, 256)(name)
    if not re.fullmatch(r"[a-z0-9]+(?:[._\-/][a-z0-9]+)*", name):
        issues.append(NameIssue("error",
                                "must match `[a-z0-9]+(?:[._/-][a-z0-9]+)*`"))
    return issues


def _validate_opensearch(name: str) -> List[NameIssue]:
    issues = _len(3, 28)(name)
    if not re.fullmatch(r"[a-z][a-z0-9\-]*", name):
        issues.append(NameIssue("error",
                                "must start with lowercase letter; lowercase + digits + hyphens only"))
    return issues


def _validate_rds_id(name: str) -> List[NameIssue]:
    issues = _len(1, 63)(name)
    if not re.fullmatch(r"[A-Za-z][A-Za-z0-9\-]*", name):
        issues.append(NameIssue("error", "must start with a letter; alnum + hyphens"))
    if "--" in name:
        issues.append(NameIssue("error", "no consecutive hyphens"))
    if name.endswith("-"):
        issues.append(NameIssue("error", "must not end with a hyphen"))
    return issues


def _validate_email_or_domain(name: str) -> List[NameIssue]:
    if "@" in name:
        # naive RFC 5321: local-part@domain
        if not re.fullmatch(r"[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}", name):
            return [NameIssue("error", "not a valid email address")]
        return []
    # domain
    if not re.fullmatch(r"[A-Za-z0-9](?:[A-Za-z0-9\-]{0,61}[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9\-]{0,61}[A-Za-z0-9])?)+", name):
        return [NameIssue("error", "not a valid domain or email")]
    return []


# ---------------------------------------------------------------------------
# Probe specs — return an `aws` arg list, plus an interpreter that classifies
# the result. NotFound exceptions per service vary, so we match by exit code
# + stderr substring.
# ---------------------------------------------------------------------------


@dataclass
class ProbeResult:
    status: str           # "exists" | "absent" | "warn"
    detail: str = ""


def _probe_subprocess(args: List[str], region: str, profile: str) -> Tuple[int, str, str]:
    cmd = ["aws", *args, "--profile", profile, "--region", region,
           "--output", "json", "--no-cli-pager"]
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, check=False)
        return r.returncode, r.stdout, r.stderr
    except FileNotFoundError:
        return 127, "", "aws CLI not found on PATH"


def _probe_stack(name: str, region: str, profile: str) -> ProbeResult:
    rc, out, err = _probe_subprocess(
        ["cloudformation", "describe-stacks", "--stack-name", name],
        region, profile,
    )
    if rc == 0:
        try:
            stacks = json.loads(out).get("Stacks", [])
            if stacks:
                status = stacks[0].get("StackStatus", "?")
                # ROLLBACK_COMPLETE / *_FAILED stacks must be deleted first.
                bad = ("ROLLBACK_COMPLETE", "CREATE_FAILED", "ROLLBACK_FAILED",
                       "DELETE_FAILED")
                if status in bad:
                    return ProbeResult("exists", f"stuck in {status} — must delete")
                return ProbeResult("exists", f"current status {status}")
        except json.JSONDecodeError:
            pass
        return ProbeResult("exists")
    if "does not exist" in err or "ValidationError" in err:
        return ProbeResult("absent")
    return ProbeResult("warn", err.strip().splitlines()[-1] if err else f"exit {rc}")


def _probe_s3(name: str, region: str, profile: str) -> ProbeResult:
    rc, out, err = _probe_subprocess(["s3api", "head-bucket", "--bucket", name],
                                     region, profile)
    if rc == 0:
        # Check if it's our bucket or someone else's.
        rc2, out2, err2 = _probe_subprocess(
            ["s3api", "get-bucket-acl", "--bucket", name], region, profile)
        if rc2 == 0:
            return ProbeResult("exists", "in this account")
        return ProbeResult("exists", "name taken (different account or no access)")
    if "Not Found" in err or "404" in err or "NoSuchBucket" in err:
        return ProbeResult("absent")
    if "Forbidden" in err or "403" in err:
        return ProbeResult("exists", "name globally taken (different account)")
    return ProbeResult("warn", err.strip().splitlines()[-1] if err else f"exit {rc}")


def _probe_rds(name: str, region: str, profile: str) -> ProbeResult:
    rc, _, err = _probe_subprocess(
        ["rds", "describe-db-instances", "--db-instance-identifier", name],
        region, profile)
    if rc == 0:
        return ProbeResult("exists")
    if "DBInstanceNotFound" in err or "not found" in err.lower():
        return ProbeResult("absent")
    return ProbeResult("warn", err.strip().splitlines()[-1] if err else f"exit {rc}")


def _probe_secret(name: str, region: str, profile: str) -> ProbeResult:
    rc, out, err = _probe_subprocess(
        ["secretsmanager", "describe-secret", "--secret-id", name],
        region, profile)
    if rc == 0:
        try:
            data = json.loads(out)
            if "DeletedDate" in data:
                return ProbeResult(
                    "exists", f"PENDING DELETION until {data.get('DeletedDate', '?')} — restore or wait")
            return ProbeResult("exists")
        except json.JSONDecodeError:
            return ProbeResult("exists")
    if "ResourceNotFoundException" in err:
        return ProbeResult("absent")
    return ProbeResult("warn", err.strip().splitlines()[-1] if err else f"exit {rc}")


def _probe_iam_role(name: str, region: str, profile: str) -> ProbeResult:
    rc, _, err = _probe_subprocess(["iam", "get-role", "--role-name", name],
                                   region, profile)
    if rc == 0:
        return ProbeResult("exists")
    if "NoSuchEntity" in err:
        return ProbeResult("absent")
    return ProbeResult("warn", err.strip().splitlines()[-1] if err else f"exit {rc}")


def _probe_ecr(name: str, region: str, profile: str) -> ProbeResult:
    rc, _, err = _probe_subprocess(
        ["ecr", "describe-repositories", "--repository-names", name],
        region, profile)
    if rc == 0:
        return ProbeResult("exists")
    if "RepositoryNotFoundException" in err:
        return ProbeResult("absent")
    return ProbeResult("warn", err.strip().splitlines()[-1] if err else f"exit {rc}")


def _probe_lambda(name: str, region: str, profile: str) -> ProbeResult:
    rc, _, err = _probe_subprocess(
        ["lambda", "get-function", "--function-name", name], region, profile)
    if rc == 0:
        return ProbeResult("exists")
    if "ResourceNotFoundException" in err:
        return ProbeResult("absent")
    return ProbeResult("warn", err.strip().splitlines()[-1] if err else f"exit {rc}")


def _probe_ecs_cluster(name: str, region: str, profile: str) -> ProbeResult:
    rc, out, err = _probe_subprocess(
        ["ecs", "describe-clusters", "--clusters", name], region, profile)
    if rc == 0:
        try:
            clusters = json.loads(out).get("clusters", [])
            for c in clusters:
                if c.get("clusterName") == name and c.get("status") != "INACTIVE":
                    return ProbeResult("exists", f"status {c.get('status')}")
        except json.JSONDecodeError:
            pass
        return ProbeResult("absent")
    return ProbeResult("warn", err.strip().splitlines()[-1] if err else f"exit {rc}")


def _probe_ecs_service(service: str, cluster: Optional[str],
                       all_clusters: List[str],
                       region: str, profile: str) -> ProbeResult:
    """Probe an ECS service. Services aren't account-unique — they're scoped
    to a cluster, so describe-services needs --cluster. We use the cluster
    parsed from the service's `Cluster` property when available; otherwise
    fall back to trying every cluster collected from the install."""
    candidates: List[str] = []
    if cluster:
        candidates.append(cluster)
    for c in all_clusters:
        if c not in candidates:
            candidates.append(c)
    if not candidates:
        return ProbeResult("warn", "no cluster context available")

    last_err = ""
    all_clusters_missing = True   # only stays True if every candidate is absent
    for c in candidates:
        rc, out, err = _probe_subprocess(
            ["ecs", "describe-services",
             "--cluster", c, "--services", service],
            region, profile)
        if rc != 0:
            last_err = err
            # ClusterNotFoundException = the cluster itself doesn't exist,
            # which means no service can exist in it either — keep looking
            # at remaining candidates without escalating to a warning.
            if "ClusterNotFoundException" not in err:
                all_clusters_missing = False
            continue
        # Cluster exists; describe-services succeeded.
        all_clusters_missing = False
        try:
            services = json.loads(out).get("services", [])
            for s in services:
                if s.get("serviceName") == service and s.get("status") != "INACTIVE":
                    return ProbeResult("exists",
                                       f"in cluster {c} (status {s.get('status')})")
        except json.JSONDecodeError:
            continue
    # Reached only if no candidate cluster contained the service.
    if all_clusters_missing:
        return ProbeResult("absent", "(parent cluster doesn't exist yet)")
    if last_err:
        return ProbeResult("warn",
                           last_err.strip().splitlines()[-1])
    return ProbeResult("absent")


def _probe_opensearch(name: str, region: str, profile: str) -> ProbeResult:
    rc, _, err = _probe_subprocess(
        ["opensearch", "describe-domain", "--domain-name", name],
        region, profile)
    if rc == 0:
        return ProbeResult("exists")
    if "ResourceNotFoundException" in err:
        return ProbeResult("absent")
    return ProbeResult("warn", err.strip().splitlines()[-1] if err else f"exit {rc}")


def _probe_sqs(name: str, region: str, profile: str) -> ProbeResult:
    rc, _, err = _probe_subprocess(
        ["sqs", "get-queue-url", "--queue-name", name], region, profile)
    if rc == 0:
        return ProbeResult("exists")
    if "NonExistentQueue" in err or "AWS.SimpleQueueService" in err:
        return ProbeResult("absent")
    return ProbeResult("warn", err.strip().splitlines()[-1] if err else f"exit {rc}")


def _probe_log_group(name: str, region: str, profile: str) -> ProbeResult:
    rc, out, err = _probe_subprocess(
        ["logs", "describe-log-groups", "--log-group-name-prefix", name],
        region, profile)
    if rc == 0:
        try:
            groups = json.loads(out).get("logGroups", [])
            for g in groups:
                if g.get("logGroupName") == name:
                    return ProbeResult("exists")
        except json.JSONDecodeError:
            pass
        return ProbeResult("absent")
    return ProbeResult("warn", err.strip().splitlines()[-1] if err else f"exit {rc}")


def _probe_eventbridge_rule(name: str, region: str, profile: str) -> ProbeResult:
    rc, _, err = _probe_subprocess(
        ["events", "describe-rule", "--name", name], region, profile)
    if rc == 0:
        return ProbeResult("exists")
    if "ResourceNotFoundException" in err:
        return ProbeResult("absent")
    return ProbeResult("warn", err.strip().splitlines()[-1] if err else f"exit {rc}")


def _probe_alb(name: str, region: str, profile: str) -> ProbeResult:
    rc, _, err = _probe_subprocess(
        ["elbv2", "describe-load-balancers", "--names", name], region, profile)
    if rc == 0:
        return ProbeResult("exists")
    if "LoadBalancerNotFound" in err:
        return ProbeResult("absent")
    return ProbeResult("warn", err.strip().splitlines()[-1] if err else f"exit {rc}")


def _probe_target_group(name: str, region: str, profile: str) -> ProbeResult:
    rc, _, err = _probe_subprocess(
        ["elbv2", "describe-target-groups", "--names", name], region, profile)
    if rc == 0:
        return ProbeResult("exists")
    if "TargetGroupNotFound" in err:
        return ProbeResult("absent")
    return ProbeResult("warn", err.strip().splitlines()[-1] if err else f"exit {rc}")


def _probe_ses_identity(name: str, region: str, profile: str) -> ProbeResult:
    rc, out, err = _probe_subprocess(
        ["ses", "get-identity-verification-attributes",
         "--identities", name], region, profile)
    if rc == 0:
        try:
            attrs = json.loads(out).get("VerificationAttributes", {})
            if name in attrs:
                return ProbeResult(
                    "exists", f"verification {attrs[name].get('VerificationStatus','?')}")
        except json.JSONDecodeError:
            pass
        return ProbeResult("absent")
    return ProbeResult("warn", err.strip().splitlines()[-1] if err else f"exit {rc}")


# ---------------------------------------------------------------------------
# Resource registry
# ---------------------------------------------------------------------------


@dataclass
class TypeSpec:
    name_prop: str                                 # YAML property holding the name
    validate: Callable[[str], List[NameIssue]]
    probe: Callable[[str, str, str], ProbeResult]
    label: str = ""                                # short label for display


REGISTRY: Dict[str, TypeSpec] = {
    "AWS::S3::Bucket": TypeSpec(
        "BucketName", _validate_s3_bucket, _probe_s3, "S3 bucket"),
    "AWS::RDS::DBInstance": TypeSpec(
        "DBInstanceIdentifier", _validate_rds_id, _probe_rds, "RDS instance"),
    "AWS::SecretsManager::Secret": TypeSpec(
        "Name",
        _all(_len(1, 512),
             _re(r"[A-Za-z0-9/_+=.@\-]+", "secret name charset")),
        _probe_secret, "Secret"),
    "AWS::IAM::Role": TypeSpec(
        "RoleName",
        _all(_len(1, 64), _re(r"[\w+=,.@\-]+", "IAM role charset")),
        _probe_iam_role, "IAM role"),
    "AWS::ECR::Repository": TypeSpec(
        "RepositoryName", _validate_ecr_repo, _probe_ecr, "ECR repo"),
    "AWS::Lambda::Function": TypeSpec(
        "FunctionName",
        _all(_len(1, 64), _re(r"[a-zA-Z0-9\-_]+", "Lambda name charset")),
        _probe_lambda, "Lambda fn"),
    "AWS::ECS::Cluster": TypeSpec(
        "ClusterName",
        _all(_len(1, 255), _re(r"[a-zA-Z0-9_\-]+", "ECS cluster charset")),
        _probe_ecs_cluster, "ECS cluster"),
    "AWS::OpenSearchService::Domain": TypeSpec(
        "DomainName", _validate_opensearch, _probe_opensearch, "OpenSearch domain"),
    "AWS::SQS::Queue": TypeSpec(
        "QueueName",
        _all(_len(1, 80), _re(r"[a-zA-Z0-9_\-]+(\.fifo)?", "SQS name charset")),
        _probe_sqs, "SQS queue"),
    "AWS::Logs::LogGroup": TypeSpec(
        "LogGroupName",
        _all(_len(1, 512), _re(r"[a-zA-Z0-9_/.#\-]+", "log-group charset")),
        _probe_log_group, "Log group"),
    "AWS::Events::Rule": TypeSpec(
        "Name",
        _all(_len(1, 64), _re(r"[a-zA-Z0-9_\-.]+", "EventBridge rule charset")),
        _probe_eventbridge_rule, "Event rule"),
    "AWS::ElasticLoadBalancingV2::LoadBalancer": TypeSpec(
        "Name",
        _all(_len(1, 32), _re(r"[a-zA-Z0-9\-]+", "ALB charset; no leading/trailing hyphen")),
        _probe_alb, "Load balancer"),
    "AWS::ElasticLoadBalancingV2::TargetGroup": TypeSpec(
        "Name",
        _all(_len(1, 32), _re(r"[a-zA-Z0-9\-]+", "target-group charset")),
        _probe_target_group, "Target group"),
    "AWS::SES::EmailIdentity": TypeSpec(
        "EmailIdentity", _validate_email_or_domain, _probe_ses_identity, "SES identity"),
    # ECS::Service uses ServiceName but also requires Cluster context for
    # probe — dispatched separately in the probe loop, not via this stub.
    "AWS::ECS::Service": TypeSpec(
        "ServiceName",
        _all(_len(1, 255), _re(r"[a-zA-Z0-9_\-]+", "ECS service charset")),
        lambda *_a, **_k: ProbeResult("warn", "no cluster resolved"),
        "ECS service"),
}


# ---------------------------------------------------------------------------
# Walk + report
# ---------------------------------------------------------------------------


@dataclass
class Finding:
    stack: str
    type: str
    logical_id: str
    name: Optional[str]
    issues: List[NameIssue] = field(default_factory=list)
    probe: Optional[ProbeResult] = None
    note: str = ""        # for unresolved / skipped resources
    context: Dict[str, str] = field(default_factory=dict)
    # context["cluster"] for ECS::Service findings, etc.


class PreflightWorker:

    @staticmethod
    def preflight(skip_probe: bool = False) -> None:
        # ---- env + param file --------------------------------------------
        required = ["CANOPY_PROJECT_NAME", "CANOPY_ENV",
                    "CANOPY_AWS_PARAMETER_FILE", "CANOPY_CLOUD_REPLICATION",
                    "AWS_PROFILE"]
        env_vals = {k: os.environ.get(k, "") for k in required}
        missing = [k for k, v in env_vals.items() if not v]
        if missing:
            console.print(Panel(
                "[red]Missing environment variables: " + ", ".join(missing)
                + "\n[yellow]Source your set-canopy-env.sh first.",
                title="Error", title_align="left"),
                style=Style(color="red"))
            sys.exit(2)

        project = env_vals["CANOPY_PROJECT_NAME"]
        env = env_vals["CANOPY_ENV"]
        region = os.environ.get("AWS_REGION") or "us-east-1"
        profile = env_vals["AWS_PROFILE"]
        templates_dir = Path(env_vals["CANOPY_CLOUD_REPLICATION"])
        param_path = Path(env_vals["CANOPY_AWS_PARAMETER_FILE"])

        if not param_path.is_file():
            console.print(f"[red]Parameter file not found: {param_path}")
            sys.exit(2)
        try:
            raw_params: Dict[str, str] = json.loads(param_path.read_text()).get(
                "Parameters", {})
        except json.JSONDecodeError as exc:
            console.print(f"[red]Could not parse {param_path}: {exc}")
            sys.exit(2)

        # Some sites keep the parameter file in template form with `<<X>>`
        # placeholders that get filled at deploy time by `set-canopy-env.sh`.
        # Resolve those against the current environment so preflight can run
        # even before the file has been finalised.
        params: Dict[str, str] = {}
        ph = re.compile(r"<<([A-Z_][A-Z0-9_]*)>>")
        for k, v in raw_params.items():
            if isinstance(v, str):
                params[k] = ph.sub(
                    lambda m: os.environ.get(m.group(1), m.group(0)), v)
            else:
                params[k] = v

        # Fold pseudo params + env so the resolver can render `${AWS::Region}` etc.
        params.setdefault("AWS::Region", region)
        params.setdefault("AWS::Partition", "aws")
        # Account id is fetched lazily only if needed; placeholder otherwise.
        params.setdefault("AWS::AccountId", "")

        console.print(Panel(
            f"[yellow] Project : {project}\n"
            f" Env     : {env}\n"
            f" Region  : {region}\n"
            f" Profile : {profile}\n"
            f" Params  : {param_path}\n"
            f" Modules : {templates_dir}",
            title="Preflight", title_align="left"),
            style=Style(color="yellow"))

        # ---- walk modules ------------------------------------------------
        findings: List[Finding] = []
        # Stack-name probes first so they sort to the top.
        for stack_name, _ in STACKS:
            full = f"{project}-{stack_name}-{env}"
            f = Finding(stack=stack_name, type="AWS::CloudFormation::Stack",
                        logical_id="(stack itself)", name=full)
            f.issues = _all(_len(1, 128),
                            _re(r"[A-Za-z][A-Za-z0-9\-]*",
                                "stack name must start with letter, alnum + hyphens"))(full)
            findings.append(f)

        for stack_name, rel_path in STACKS:
            tpl_path = templates_dir / rel_path
            if not tpl_path.is_file():
                findings.append(Finding(stack=stack_name, type="?",
                                        logical_id="(template missing)",
                                        name=None,
                                        note=f"file not found: {tpl_path}"))
                continue
            with tpl_path.open() as f:
                try:
                    doc = yaml.load(f, Loader=_CfnLoader) or {}
                except yaml.YAMLError as exc:
                    findings.append(Finding(stack=stack_name, type="?",
                                            logical_id="(parse error)",
                                            name=None,
                                            note=str(exc).splitlines()[0]))
                    continue
            resources = doc.get("Resources", {}) or {}
            conditions = doc.get("Conditions", {}) or {}
            # Resolve all sibling names within this template up-front so
            # `${OtherLogicalId.SomeNameAttribute}` references can render.
            siblings = _resolve_template_names(resources, params)
            for logical_id, body in resources.items():
                rtype = body.get("Type")
                spec = REGISTRY.get(rtype)
                if not spec:
                    continue   # auto-named or not interesting
                # Honour `Condition:` — skip resources that CFN won't create.
                cond_name = body.get("Condition")
                if cond_name and not _eval_condition(
                        conditions.get(cond_name), params):
                    continue
                props = body.get("Properties", {}) or {}
                if spec.name_prop not in props:
                    # Property not set => CFN auto-names it; can't conflict.
                    continue
                rendered = _resolve(props[spec.name_prop], params, siblings)
                if rendered is None:
                    findings.append(Finding(
                        stack=stack_name, type=rtype, logical_id=logical_id,
                        name=None,
                        note=f"could not resolve {spec.name_prop} (uses unsupported intrinsic or missing param)"))
                    continue
                f = Finding(stack=stack_name, type=rtype,
                            logical_id=logical_id, name=rendered)
                f.issues = spec.validate(rendered)
                # Flag any unfilled placeholders that slipped through the
                # parameter file (e.g. `replaceme-support@example.com`).
                # These pass syntactic validation but the deploy will create
                # something useless. Severity: warn (visible, doesn't block).
                if _PLACEHOLDER_RE.search(rendered):
                    f.issues.append(NameIssue(
                        "warn",
                        "contains 'replaceme' — likely an unset parameter; "
                        "edit ${CANOPY_AWS_PARAMETER_FILE} and re-source set-canopy-env.sh"))
                # ECS::Service: try to identify which cluster it lives in so
                # the probe can pass --cluster to describe-services.
                if rtype == "AWS::ECS::Service":
                    cluster = _resolve_cluster_ref(
                        props.get("Cluster"), params, siblings)
                    if cluster:
                        f.context["cluster"] = cluster
                findings.append(f)

        # ---- parameter-value sanity ---------------------------------------
        # Catch values that AWS will reject at deploy time (e.g. weak
        # OpenSearch master password). These show up as findings of type
        # `Parameter` so they appear in the report next to resource issues.
        for key, label, validator in PARAM_RULES:
            val = params.get(key)
            if not val or _PLACEHOLDER_RE.search(val):
                # Skip — the placeholder warning on resources covers this.
                continue
            problems = validator(val)
            if problems:
                f = Finding(stack="(parameters)", type="Parameter",
                            logical_id=key, name="(value redacted)")
                for msg in problems:
                    f.issues.append(NameIssue("error", f"{label}: {msg}"))
                findings.append(f)

        # ---- probe -------------------------------------------------------
        if not skip_probe:
            # Collect every ECS cluster name we resolved across all templates
            # — used as fallback context for ECS::Service probes whose
            # cluster reference came via !ImportValue across stacks.
            known_clusters = [
                f.name for f in findings
                if f.type == "AWS::ECS::Cluster" and f.name
            ]
            # Build the work list so we can show "[N/total]".
            todo = [
                f for f in findings
                if f.name is not None
                and not any(i.severity == "error" for i in f.issues)
            ]
            total = len(todo)
            console.print(
                f"\n[bold]Probing AWS for {total} resources…[/bold] "
                f"[dim](one describe-* call per resource; ~0.5–2s each)[/dim]")
            t_start = time.monotonic()
            for idx, f in enumerate(todo, start=1):
                short_type = f.type.replace("AWS::", "")
                # Print the in-progress line, transient: rewrite it after the
                # probe returns with the result.
                with console.status(
                        f"[cyan][{idx:>2}/{total}][/cyan] "
                        f"{short_type} [bold]{rich_escape(f.name)}[/bold]…",
                        spinner="dots"):
                    t0 = time.monotonic()
                    if f.type == "AWS::CloudFormation::Stack":
                        f.probe = _probe_stack(f.name, region, profile)
                    elif f.type == "AWS::ECS::Service":
                        f.probe = _probe_ecs_service(
                            f.name, f.context.get("cluster"),
                            known_clusters, region, profile)
                    else:
                        spec = REGISTRY.get(f.type)
                        if spec:
                            f.probe = spec.probe(f.name, region, profile)
                    dt = time.monotonic() - t0
                # Now print the durable result line.
                if f.probe is None:
                    badge = "[dim]· skipped[/dim]"
                elif f.probe.status == "absent":
                    badge = "[green]✓ absent[/green]"
                elif f.probe.status == "exists":
                    badge = "[red]✗ EXISTS[/red]" + (
                        f" — {rich_escape(f.probe.detail)}"
                        if f.probe.detail else "")
                else:
                    badge = (
                        f"[yellow]⚠ {rich_escape(f.probe.detail or 'check failed')}"
                        f"[/yellow]"
                    )
                console.print(
                    f"  [cyan][{idx:>2}/{total}][/cyan] "
                    f"{short_type:<28s} {rich_escape(f.name):<40s} "
                    f"{badge} [dim]({dt:.1f}s)[/dim]"
                )
            console.print(
                f"[dim]Probed {total} resources in "
                f"{time.monotonic() - t_start:.1f}s.[/dim]"
            )
        else:
            console.print("\n[dim]Skipping AWS probes (--skip-probe).[/dim]")

        # ---- report ------------------------------------------------------
        # Prefer the param-file ProjectName (the value CFN will actually use)
        # over the env var; they normally agree, but the param file wins.
        effective_project = params.get("ProjectName", project)
        PreflightWorker._render_report(findings, effective_project, env)

        # ---- exit code ---------------------------------------------------
        had_error = any(
            (f.probe and f.probe.status == "exists")
            or any(i.severity == "error" for i in f.issues)
            for f in findings
        )
        sys.exit(1 if had_error else 0)

    # ---------------------------------------------------------------------

    @staticmethod
    def _render_report(findings: List[Finding], project: str, env: str) -> None:
        # Group by stack.
        by_stack: Dict[str, List[Finding]] = {}
        for f in findings:
            by_stack.setdefault(f.stack, []).append(f)

        n_resources = sum(1 for f in findings if f.name)
        n_name_errors = sum(1 for f in findings
                            if any(i.severity == "error" for i in f.issues))
        n_name_warns = sum(1 for f in findings
                           if any(i.severity == "warn" for i in f.issues))
        n_exists = sum(1 for f in findings
                       if f.probe and f.probe.status == "exists")
        n_warn = sum(1 for f in findings
                     if f.probe and f.probe.status == "warn")
        n_unresolved = sum(1 for f in findings if f.name is None and f.note)

        for stack, items in by_stack.items():
            t = Table(title=f"[bold]{stack}[/bold]", title_justify="left",
                      show_lines=False)
            t.add_column("Type", style="cyan")
            t.add_column("Logical ID")
            t.add_column("Resolved name")
            t.add_column("Sanity")
            t.add_column("AWS")
            for f in items:
                short_type = f.type.replace("AWS::", "") if f.type else "?"
                if f.name is None:
                    t.add_row(short_type, f.logical_id, "[dim]-[/dim]",
                              "[yellow]?[/yellow]",
                              f"[yellow]{rich_escape(f.note)}[/yellow]")
                    continue
                sanity_cell = "[green]OK[/green]"
                if f.issues:
                    sanity_cell = "\n".join(
                        f"[red]✗[/red] {rich_escape(i.message)}"
                        if i.severity == "error"
                        else f"[yellow]⚠[/yellow] {rich_escape(i.message)}"
                        for i in f.issues
                    )
                if f.probe is None:
                    aws_cell = "[dim]-[/dim]"
                elif f.probe.status == "absent":
                    aws_cell = "[green]✓ absent[/green]"
                elif f.probe.status == "exists":
                    aws_cell = "[red]✗ EXISTS[/red]" + (
                        f" — {rich_escape(f.probe.detail)}" if f.probe.detail else "")
                else:
                    aws_cell = (
                        f"[yellow]⚠ {rich_escape(f.probe.detail or 'check failed')}[/yellow]"
                    )
                t.add_row(short_type, f.logical_id, rich_escape(f.name),
                          sanity_cell, aws_cell)
            console.print()
            console.print(t)

        # Headroom hint: how much room is left on ProjectName before any
        # length rule trips. Useful when planning a longer name later.
        headroom = PreflightWorker._project_headroom(project, findings)
        console.print()
        has_blockers = bool(n_name_errors or n_exists)
        has_warnings = bool(n_name_warns or n_warn)
        if has_blockers:
            panel_color = "red"
        elif has_warnings:
            panel_color = "yellow"
        else:
            panel_color = "green"

        console.print(Panel(
            f"[bold]Resources checked:[/bold] {n_resources}\n"
            f"[bold]Name errors:[/bold]      {'[red]' if n_name_errors else '[green]'}{n_name_errors}[/]\n"
            f"[bold]Name warnings:[/bold]    {'[yellow]' if n_name_warns else '[green]'}{n_name_warns}[/]\n"
            f"[bold]Already in AWS:[/bold]   {'[red]' if n_exists else '[green]'}{n_exists}[/]\n"
            f"[bold]Probe warnings:[/bold]   {'[yellow]' if n_warn else '[green]'}{n_warn}[/]\n"
            f"[bold]Unresolved names:[/bold] {n_unresolved}\n"
            f"[bold]ProjectName headroom:[/bold] {headroom}",
            title=f"Summary — project={project} env={env}",
            title_align="left",
            style=Style(color=panel_color),
        ))

        if has_blockers:
            console.print(
                "[red]Preflight failed.[/red] Resolve the issues above before running "
                "[bold]canopycli aws cloudformation deploy[/bold].")
        elif has_warnings:
            console.print(
                "[yellow]Preflight clean of blockers, but warnings above need review.[/yellow] "
                "Deploy will succeed, but some resources may be functionally wrong "
                "(e.g. unfilled `replaceme-…` placeholders).")
        else:
            console.print(
                "[green]Preflight clean.[/green] Install should not collide with existing resources.")

    @staticmethod
    def _project_headroom(project: str, findings: List[Finding]) -> str:
        """How many more characters could ProjectName grow before busting any
        length rule. Useful pre-flight for naming a longer project."""
        from collections import namedtuple
        # For each finding, count the chars in the resolved name attributable
        # to ProjectName, then compute (max_len - current_len) / occurrences.
        worst = None  # (slack, type, name)
        plen = len(project)
        if plen == 0:
            return "n/a"
        for f in findings:
            if not f.name:
                continue
            spec = REGISTRY.get(f.type)
            if not spec:
                if f.type == "AWS::CloudFormation::Stack":
                    max_len = 128
                else:
                    continue
            else:
                # Cheap heuristic: re-validate at increasing lengths.
                max_len = PreflightWorker._max_len_for(f.type)
                if not max_len:
                    continue
            # how many times does `project` appear in the rendered name?
            occurrences = f.name.count(project) if project in f.name else 0
            if occurrences == 0:
                continue
            slack = (max_len - len(f.name)) // occurrences
            if worst is None or slack < worst[0]:
                worst = (slack, f.type.replace("AWS::", ""), f.name)
        if worst is None:
            return "n/a"
        slack, kind, name = worst
        if slack < 0:
            return f"[red]{slack}[/red] (over-budget; tightest: {kind} {name})"
        if slack < 4:
            return f"[yellow]{slack}[/yellow] chars (tightest: {kind} {name})"
        return f"[green]{slack}[/green] chars (tightest: {kind} {name})"

    @staticmethod
    def _max_len_for(rtype: str) -> int:
        return {
            "AWS::S3::Bucket": 63,
            "AWS::RDS::DBInstance": 63,
            "AWS::SecretsManager::Secret": 512,
            "AWS::IAM::Role": 64,
            "AWS::ECR::Repository": 256,
            "AWS::Lambda::Function": 64,
            "AWS::ECS::Cluster": 255,
            "AWS::ECS::Service": 255,
            "AWS::OpenSearchService::Domain": 28,
            "AWS::SQS::Queue": 80,
            "AWS::Logs::LogGroup": 512,
            "AWS::Events::Rule": 64,
            "AWS::ElasticLoadBalancingV2::LoadBalancer": 32,
            "AWS::ElasticLoadBalancingV2::TargetGroup": 32,
        }.get(rtype, 0)
