from rich.console import Console

from org.bmirdatahub.util.GlobalContext import GlobalContext
from org.bmirdatahub.util.Util import Util
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

    @staticmethod
    def repos():
        for repo in GlobalContext.repos.get_java():
            Worker.execute_generic_shell_commands(
                ["mvn clean"],
                title="Maven clean for " + repo.name + "",
                cwd=Util.get_wd(repo)
            )
