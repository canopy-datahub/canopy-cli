import abc
from abc import ABC

from rich.panel import Panel
from rich.progress import Progress
from rich.style import Style

from org.bmirdatahub.model.PlanTask import PlanTask
from org.bmirdatahub.model.PrePostType import PrePostType


class TaskExecutor(ABC):

    def __init__(self):
        super().__init__()

    @abc.abstractmethod
    def execute(self, plan: PlanTask, job_progress: Progress, dry_run: bool):
        pass

    @staticmethod
    def display_header(task: PlanTask, job_progress: Progress, color: str, title: str):
        msg = task.name + (" ➡️  " + str(task.repo.pre_post_type) if task.repo.pre_post_type != PrePostType.NONE else "")
        msg += "\n" + "️ ➡️  " + task.repo.get_fqn()
        job_progress.print(Panel(msg, style=Style(color=color), title=title))
