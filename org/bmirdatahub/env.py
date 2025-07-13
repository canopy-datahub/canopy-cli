import typer

from org.bmirdatahub.util.Const import Const
from org.bmirdatahub.worker.EnvWorker import EnvWorker

app = typer.Typer(no_args_is_help=True)

APP_NAME = Const.APP_NAME


@app.command("list", help="Lists all " + APP_NAME + " environment variables")
def env_list():
    EnvWorker.list()


@app.command("core", help="Lists core " + APP_NAME + " environment variables")
def env_core():
    EnvWorker.core()


@app.command("filter", help="Lists " + APP_NAME + " environment variables that contain the passed filter term")
def env_filter(filter_term: str = typer.Argument('', help="Environment variable name to search for")):
    EnvWorker.filter(filter_term)
