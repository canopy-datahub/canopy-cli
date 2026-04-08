import typer

from org.bmirdatahub.worker.StopMicroserviceWorker import StopMicroserviceWorker

app = typer.Typer(no_args_is_help=True)


@app.command("all")
def microservice_all():
    StopMicroserviceWorker.all()


@app.command("download")
def microservice_download():
    StopMicroserviceWorker.download()


@app.command("email")
def microservice_email():
    StopMicroserviceWorker.email()


@app.command("entity")
def microservice_entity():
    StopMicroserviceWorker.entity()


@app.command("report")
def microservice_report():
    StopMicroserviceWorker.report()


@app.command("search")
def microservice_search():
    StopMicroserviceWorker.search()


@app.command("submission")
def microservice_submission():
    StopMicroserviceWorker.submission()


@app.command("user")
def microservice_user():
    StopMicroserviceWorker.user()
