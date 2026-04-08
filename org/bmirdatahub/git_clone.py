import typer

from org.bmirdatahub.worker.GitWorker import GitWorker

app = typer.Typer(no_args_is_help=True)

git_worker = GitWorker()


@app.command("all")
def clone_all():
    git_worker.clone_all()
