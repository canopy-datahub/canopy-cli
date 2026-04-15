from rich.console import Console

from edu.stanford.cmed.devcli.util.GlobalContext import GlobalContext
from edu.stanford.cmed.devcli.util.Util import Util
from edu.stanford.cmed.devcli.worker.Worker import Worker

console = Console()


class StartMicroserviceWorker(Worker):

    def __init__(self):
        super().__init__()

    @staticmethod
    def all():
        if GlobalContext.get_use_osa():
            Worker.execute_generic_shell_commands(
                ["osascript " + Util.get_osa_script_path('start-services-new-tab.scpt')],
                title="Launching Services in new tab",
            )
        else:
            Worker.execute_generic_shell_commands(
                ["source " + Util.get_bash_script_path('start-services.sh')],
                title="Launching Services",
            )

    @staticmethod
    def download():
        StartMicroserviceWorker._start("download")

    @staticmethod
    def email():
        StartMicroserviceWorker._start("email")

    @staticmethod
    def entity():
        StartMicroserviceWorker._start("entity")

    @staticmethod
    def report():
        StartMicroserviceWorker._start("report")

    @staticmethod
    def search():
        StartMicroserviceWorker._start("search")

    @staticmethod
    def submission():
        StartMicroserviceWorker._start("submission")

    @staticmethod
    def user():
        StartMicroserviceWorker._start("user")

    @staticmethod
    def _start(service_name: str):
        title = f"Launching {service_name.capitalize()} Service"
        if GlobalContext.get_use_osa():
            script = f"start-service-{service_name}-new-tab.scpt"
            Worker.execute_generic_shell_commands(
                ["osascript " + Util.get_osa_script_path(script)],
                title=title + " in new tab",
            )
        else:
            script = f"start-service-{service_name}.sh"
            Worker.execute_generic_shell_commands(
                ["source " + Util.get_bash_script_path(script)],
                title=title,
            )
