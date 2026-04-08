from rich.console import Console

from org.bmirdatahub.util.GlobalContext import GlobalContext
from org.bmirdatahub.util.Util import Util
from org.bmirdatahub.worker.Worker import Worker

console = Console()


class StopMicroserviceWorker(Worker):

    def __init__(self):
        super().__init__()

    @staticmethod
    def all():
        if GlobalContext.get_use_osa():
            Worker.execute_generic_shell_commands(
                ["osascript " + Util.get_osa_script_path('stop-services.scpt')],
                title="Stopping Services",
            )
        else:
            Worker.execute_generic_shell_commands(
                ["source " + Util.get_bash_script_path('stop-services.sh')],
                title="Stopping Services",
            )

    @staticmethod
    def download():
        StopMicroserviceWorker._stop("download")

    @staticmethod
    def email():
        StopMicroserviceWorker._stop("email")

    @staticmethod
    def entity():
        StopMicroserviceWorker._stop("entity")

    @staticmethod
    def report():
        StopMicroserviceWorker._stop("report")

    @staticmethod
    def search():
        StopMicroserviceWorker._stop("search")

    @staticmethod
    def submission():
        StopMicroserviceWorker._stop("submission")

    @staticmethod
    def user():
        StopMicroserviceWorker._stop("user")

    @staticmethod
    def _stop(service_name: str):
        title = f"Stopping {service_name.capitalize()} Service"
        if GlobalContext.get_use_osa():
            script = f"stop-service-{service_name}.scpt"
            Worker.execute_generic_shell_commands(
                ["osascript " + Util.get_osa_script_path(script)],
                title=title,
            )
        else:
            script = f"stop-service-{service_name}.sh"
            Worker.execute_generic_shell_commands(
                ["source " + Util.get_bash_script_path(script)],
                title=title,
            )
