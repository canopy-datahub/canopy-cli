"""
Generate canopy-ui-main/.env.${CANOPY_ENV} from .env.example, pre-filling the
NEXT_PUBLIC_* values that the aws-parameters file already knows about.

Invoked via `canopycli init ui-env` (see init.py). The resulting file is the
source of truth for the UI build args when `canopycli aws ecs deploy ui` runs.
"""

import json
import os
import re
from pathlib import Path
from typing import Dict

from rich.console import Console
from rich.panel import Panel
from rich.style import Style
from rich.table import Table

from edu.stanford.cmed.devcli.worker.Worker import Worker

console = Console()


# Relative paths under ${CANOPY_HOME}.
UI_DIR_RELPATH = ("canopy-ui-main",)
EXAMPLE_FILENAME = ".env.example"


# For each .env key, where does the value come from in the aws-parameters JSON?
# If a mapping is missing or the param is empty, the line is left unchanged
# (so comments + empty KEY= lines stay intact and the user can fill them in).
UI_ENV_FROM_PARAM: Dict[str, str] = {
    "NEXT_PUBLIC_BACKEND_URL":        "PublicHostname",
    "NEXT_PUBLIC_KEYCLOAK_URL":       "PublicHostname",
    "NEXT_PUBLIC_KEYCLOAK_REALM":     "KeycloakRealm",
    "NEXT_PUBLIC_KEYCLOAK_CLIENT_ID": "KeycloakClientId",
}

# Hardcoded defaults that don't live in the param file.
UI_ENV_HARDCODED: Dict[str, str] = {
    "NODE_TLS_REJECT_UNAUTHORIZED": "1",
}

# Matches a non-commented assignment line: KEY=... (value may be empty).
_ASSIGN_RE = re.compile(r"^(?P<key>[A-Z][A-Z0-9_]*)\s*=(?P<rest>.*)$")


class InitUiEnvWorker(Worker):
    """Renders .env.${CANOPY_ENV} from .env.example + aws-parameters."""

    @staticmethod
    def init(force: bool = False) -> None:
        canopy_home = os.environ.get("CANOPY_HOME", "")
        canopy_env = os.environ.get("CANOPY_ENV", "")
        missing = [n for n, v in (("CANOPY_HOME", canopy_home), ("CANOPY_ENV", canopy_env)) if not v]
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

        ui_dir = Path(canopy_home, *UI_DIR_RELPATH)
        source = ui_dir / EXAMPLE_FILENAME
        target = ui_dir / f".env.{canopy_env}"

        if not source.is_file():
            console.print(
                Panel(
                    f"[red]Source template not found: {source}"
                    f"\n[yellow]Make sure canopy-ui-main is cloned under CANOPY_HOME.",
                    title="Error",
                    title_align="left",
                ),
                style=Style(color="red"),
            )
            return

        if target.exists() and not force:
            console.print(
                Panel(
                    f"[yellow]Target already exists: {target}\n"
                    f"Pass [bold]--force[/bold] to overwrite.",
                    title="Skipped",
                    title_align="left",
                ),
                style=Style(color="yellow"),
            )
            return

        params = InitUiEnvWorker._load_params()

        rendered_lines, filled, skipped = InitUiEnvWorker._render(
            source.read_text(), params
        )

        try:
            target.write_text("".join(rendered_lines))
        except OSError as exc:
            console.print(f"[red]Failed to write {target}: {exc}[/red]")
            return

        InitUiEnvWorker._print_report(source, target, filled, skipped)

    # ---------------------------------------------------------------- helpers

    @staticmethod
    def _load_params() -> Dict[str, str]:
        """Read the Parameters block from CANOPY_AWS_PARAMETER_FILE. Returns {} on any problem."""
        param_path = os.environ.get("CANOPY_AWS_PARAMETER_FILE", "")
        if not param_path or not Path(param_path).is_file():
            console.print(
                "[yellow]CANOPY_AWS_PARAMETER_FILE not set or not readable — "
                "generated file will keep its .env.example defaults.[/yellow]"
            )
            return {}
        try:
            with open(param_path, "r") as f:
                return json.load(f).get("Parameters", {}) or {}
        except (json.JSONDecodeError, OSError) as exc:
            console.print(
                f"[yellow]Could not parse {param_path}: {exc} — generated file will "
                f"keep its .env.example defaults.[/yellow]"
            )
            return {}

    @staticmethod
    def _render(template_text: str, params: Dict[str, str]):
        """Render the template line-by-line, substituting known keys.

        Comments and blank lines are preserved verbatim. For each `KEY=...` line:
          1. If KEY is in UI_ENV_HARDCODED → replace with the hardcoded value.
          2. Else if KEY is in UI_ENV_FROM_PARAM and the param has a non-empty value
             → replace with that value.
          3. Otherwise leave the line unchanged (empty RHS stays empty, user fills in).
        """
        lines = template_text.splitlines(keepends=True)
        out_lines = []
        filled: list[tuple[str, str, str]] = []     # (key, value, source)
        skipped: list[tuple[str, str]] = []         # (key, reason)

        for line in lines:
            # Preserve comments + blank lines.
            stripped = line.lstrip()
            if not stripped or stripped.startswith("#"):
                out_lines.append(line)
                continue

            m = _ASSIGN_RE.match(line.rstrip("\n"))
            if not m:
                out_lines.append(line)
                continue

            key = m.group("key")
            newline = "\n" if line.endswith("\n") else ""

            if key in UI_ENV_HARDCODED:
                value = UI_ENV_HARDCODED[key]
                out_lines.append(f"{key}={value}{newline}")
                filled.append((key, value, "hardcoded"))
                continue

            param_key = UI_ENV_FROM_PARAM.get(key)
            if param_key:
                value = (params.get(param_key) or "").strip()
                if value:
                    out_lines.append(f"{key}={value}{newline}")
                    filled.append((key, value, f"param:{param_key}"))
                else:
                    out_lines.append(line)
                    skipped.append((key, f"param {param_key} is empty"))
                continue

            # Unknown key — leave as-is (.env.example default wins).
            out_lines.append(line)
            skipped.append((key, "no param mapping (fill in manually if needed)"))

        return out_lines, filled, skipped

    @staticmethod
    def _print_report(source: Path, target: Path, filled, skipped) -> None:
        filled_table = Table("Key", "Value", "Source", title="Filled in")
        for key, value, src in filled:
            # Redact GTAG if it ever ends up auto-filled (currently not mapped, but defensive).
            display = value if "GTAG" not in key else (value[:4] + "****")
            filled_table.add_row(f"[green]{key}[/green]", display, f"[dim]{src}[/dim]")
        filled_table.style = Style(color="green")

        if skipped:
            skipped_table = Table("Key", "Reason", title="Left for you to fill in (if needed)")
            for key, reason in skipped:
                skipped_table.add_row(f"[yellow]{key}[/yellow]", f"[dim]{reason}[/dim]")
            skipped_table.style = Style(color="yellow")

        console.print(
            Panel(
                f"[green]Wrote:[/green] {target}\n"
                f"[dim]source: {source}[/dim]",
                title="init ui-env",
                title_align="left",
            ),
            style=Style(color="green"),
        )
        if filled:
            console.print(filled_table)
        if skipped:
            console.print(skipped_table)
