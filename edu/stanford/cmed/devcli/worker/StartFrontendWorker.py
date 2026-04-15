from rich.console import Console

from edu.stanford.cmed.devcli.util.GlobalContext import GlobalContext
from edu.stanford.cmed.devcli.util.Util import Util
from edu.stanford.cmed.devcli.worker.Worker import Worker

console = Console()


class StartFrontendWorker(Worker):

    def __init__(self):
        super().__init__()

    @staticmethod
    def main():
        if GlobalContext.get_use_osa():
            Worker.execute_generic_shell_commands(
                ["osascript " + Util.get_osa_script_path('start-ui-main-new-tab.scpt')],
                title="Launching Main Frontend in new tab",
            )
        else:
            Worker.execute_generic_shell_commands(
                ["source " + Util.get_bash_script_path('start-ui-main.sh')],
                title="Launching Main Frontend",
            )

    @staticmethod
    def all():
        StartFrontendWorker.main()
