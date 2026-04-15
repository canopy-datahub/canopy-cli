from rich.console import Console

from edu.stanford.cmed.devcli.util.Util import Util
from edu.stanford.cmed.devcli.worker.Worker import Worker

console = Console()


class CheatWorker(Worker):

    def __init__(self):
        super().__init__()

    @staticmethod
    def cheat():
        path = Util.get_asset_file_path(['docs', 'canopy-cli.pdf'])
        Worker.execute_generic_shell_commands([
            'open ' + path
        ],
            title="Opening cheatsheet",
        )
