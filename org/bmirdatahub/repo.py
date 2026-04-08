import typer

from org.bmirdatahub.worker.RepoWorker import RepoWorker

app = typer.Typer(no_args_is_help=True)


@app.command("config", help="Show configured repos (in org/bmirdatahub/config/ReposFactory.py)")
def repo_config():
    RepoWorker.repo_config()
