import typer

from edu.stanford.cmed.devcli import start_frontend, start_microservice
from edu.stanford.cmed.devcli.worker.StartFrontendWorker import StartFrontendWorker
from edu.stanford.cmed.devcli.worker.StartInfrastructureWorker import StartInfrastructureWorker
from edu.stanford.cmed.devcli.worker.StartMicroserviceWorker import StartMicroserviceWorker

app = typer.Typer(no_args_is_help=True)
app.add_typer(start_frontend.app, name="frontend")
app.add_typer(start_microservice.app, name="microservice")


@app.command("all")
def all_all():
    StartInfrastructureWorker.all()
    StartMicroserviceWorker.all()
    StartFrontendWorker.all()


@app.command("infra")
def infra_all():
    StartInfrastructureWorker.all()


@app.command("microservices")
def microservice_all():
    StartMicroserviceWorker.all()


@app.command("java")
def java_all():
    StartMicroserviceWorker.all()


@app.command("frontends")
def frontend_all():
    StartFrontendWorker.all()


@app.command("uis")
def ui_all():
    StartFrontendWorker.all()


@app.command("kk")
def infra_kk():
    StartInfrastructureWorker.keycloak()


@app.command("keycloak")
def infra_keycloak():
    infra_kk()


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
