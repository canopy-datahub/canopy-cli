from rich.console import Console

from edu.stanford.cmed.devcli.util.Util import Util
from edu.stanford.cmed.devcli.worker.Worker import Worker

console = Console()


class StopFrontendWorker(Worker):

    def __init__(self):
        super().__init__()

    @staticmethod
    def main():
        Worker.execute_generic_shell_commands(
            ["osascript " + Util.get_osa_script_path('stop-ui-main.scpt')],
            title="Stopping Main Frontend",
        )

    @staticmethod
    def all():
        StopFrontendWorker.main()
