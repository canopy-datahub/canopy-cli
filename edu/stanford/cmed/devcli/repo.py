import typer

from edu.stanford.cmed.devcli.worker.RepoWorker import RepoWorker

app = typer.Typer(no_args_is_help=True)


@app.command("config", help="Show configured repos (in edu/devcli/config/ReposFactory.py)")
def repo_config():
    RepoWorker.repo_config()
