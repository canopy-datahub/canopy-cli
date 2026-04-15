import typer

from edu.stanford.cmed.devcli.worker.ServerWorker import ServerWorker

app = typer.Typer(no_args_is_help=True)


@app.command("status")
def status():
    ServerWorker.status()
