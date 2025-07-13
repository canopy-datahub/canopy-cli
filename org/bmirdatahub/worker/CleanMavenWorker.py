from rich.console import Console

from org.bmirdatahub.worker.Worker import Worker

console = Console()


class CleanMavenWorker(Worker):

    def __init__(self):
        super().__init__()

    @staticmethod
    def all():
        Worker.execute_generic_shell_commands(
            ["rm -rf ~/.m2/repository/"],
            title="Removing all local maven repository content",
        )

    @staticmethod
    def project():
        Worker.execute_generic_shell_commands(
            ["rm -rf ~/.m2/repository/ex/org/"],
            title="Removing ex.org local maven repository content",
        )
