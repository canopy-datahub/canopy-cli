import typer

from edu.stanford.cmed.devcli.worker.StartFrontendWorker import StartFrontendWorker

app = typer.Typer(no_args_is_help=True)


@app.command("main")
def main():
    StartFrontendWorker.main()


@app.command("all")
def frontend_all():
    StartFrontendWorker.all()
