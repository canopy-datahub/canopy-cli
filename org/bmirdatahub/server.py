import typer

from org.bmirdatahub.worker.ServerWorker import ServerWorker

app = typer.Typer(no_args_is_help=True)


@app.command("status")
def status():
    ServerWorker.status()
