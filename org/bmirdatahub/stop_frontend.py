import typer

from org.bmirdatahub.worker.StopFrontendWorker import StopFrontendWorker

app = typer.Typer(no_args_is_help=True)


@app.command("main")
def main():
    StopFrontendWorker.main()


@app.command("all")
def frontend_all():
    StopFrontendWorker.all()
