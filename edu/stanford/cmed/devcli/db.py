"""
canopycli db ...

Commands for working with the bundled database init scripts in
canopy-cli/assets/db/. The split-* commands wrap the standalone splitter
scripts so contributors can re-run them after re-dumping the database
without remembering script paths.
"""

import subprocess
import sys
from pathlib import Path

import typer

# canopy-cli/edu/stanford/cmed/devcli/db.py
#   parents[0] = devcli, parents[4] = canopy-cli root.
_REPO_ROOT = Path(__file__).resolve().parents[4]
_SCRIPTS_DIR = _REPO_ROOT / "scripts" / "python"
_SPLIT_SCHEMA = _SCRIPTS_DIR / "split_pgdump.py"
_SPLIT_DATA = _SCRIPTS_DIR / "split_pgdump_data.py"
_DEFAULT_OUTDIR = _REPO_ROOT / "assets" / "db" / "postgres" / "init"


app = typer.Typer(no_args_is_help=True)


@app.command(
    "split-schema",
    help="Split a pg_dump schema/DDL file into per-object init/*.sql files",
)
def split_schema(
    input_file: Path = typer.Argument(..., exists=True, readable=True,
                                      help="Path to a pg_dump schema dump"),
    outdir: Path = typer.Option(
        _DEFAULT_OUTDIR, "--outdir", "-o",
        help="Output directory (defaults to assets/db/postgres/init/)",
    ),
):
    _run([sys.executable, str(_SPLIT_SCHEMA), str(input_file), str(outdir)])


@app.command(
    "split-data",
    help="Split a pg_dump data dump (INSERTs) into per-table 7NN_data_*.sql files",
)
def split_data(
    input_file: Path = typer.Argument(..., exists=True, readable=True,
                                      help="Path to a pg_dump data dump"),
    outdir: Path = typer.Option(
        _DEFAULT_OUTDIR, "--outdir", "-o",
        help="Output directory (defaults to assets/db/postgres/init/)",
    ),
    start: int = typer.Option(
        700, "--start",
        help="Starting index for 7NN numbering (use 725, 750, ... for additional dumps)",
    ),
):
    _run([sys.executable, str(_SPLIT_DATA), str(input_file), str(outdir), "--start", str(start)])


def _run(cmd):
    try:
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as exc:
        raise typer.Exit(code=exc.returncode)
