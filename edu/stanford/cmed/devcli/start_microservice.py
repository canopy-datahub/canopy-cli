import typer

from edu.stanford.cmed.devcli.worker.StartMicroserviceWorker import StartMicroserviceWorker

app = typer.Typer(no_args_is_help=True)


@app.command("all")
def microservice_all():
    StartMicroserviceWorker.all()


@app.command("download")
def microservice_download():
    StartMicroserviceWorker.download()


@app.command("email")
def microservice_email():
    StartMicroserviceWorker.email()


@app.command("entity")
def microservice_entity():
    StartMicroserviceWorker.entity()


@app.command("report")
def microservice_report():
    StartMicroserviceWorker.report()


@app.command("search")
def microservice_search():
    StartMicroserviceWorker.search()


@app.command("submission")
def microservice_submission():
    StartMicroserviceWorker.submission()


@app.command("user")
def microservice_user():
    StartMicroserviceWorker.user()
