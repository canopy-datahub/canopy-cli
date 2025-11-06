import typer

from org.bmirdatahub.worker.CleanMavenWorker import CleanMavenWorker

app = typer.Typer(no_args_is_help=True)


@app.command("all")
def clean_all():
    CleanMavenWorker.all()


@app.command("project")
def project():
    CleanMavenWorker.project()


@app.command("repos")
def repos():
    CleanMavenWorker.repos()
