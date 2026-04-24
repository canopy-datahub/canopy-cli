"""
canopycli init — sub-command group for bootstrapping configuration files.

  canopycli init cli      → CANOPY_HOME config (aws-parameters, set-canopy-env.sh,
                            canopy-profile-native-develop.sh) — the original behaviour
                            of the single `canopycli init` command.
  canopycli init ui-env   → datahub-ui-main/.env.${CANOPY_ENV}, populated from the
                            param file.
"""

import typer

from edu.stanford.cmed.devcli.worker.InitWorker import InitWorker
from edu.stanford.cmed.devcli.worker.InitUiEnvWorker import InitUiEnvWorker

app = typer.Typer(no_args_is_help=True)


@app.command("cli", help="Initialize CANOPY_HOME with required configuration files")
def init_cli():
    InitWorker.init()


@app.command(
    "ui-env",
    help=(
        "Generate datahub-ui-main/.env.${CANOPY_ENV} from .env.example, "
        "pre-filling values from the aws-parameters file."
    ),
)
def init_ui_env(
    force: bool = typer.Option(False, "--force", help="Overwrite an existing .env.${CANOPY_ENV} file"),
):
    InitUiEnvWorker.init(force=force)
