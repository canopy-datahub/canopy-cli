from rich.console import Console
from rich.progress import Progress

from edu.stanford.cmed.devcli.model.PlanTask import PlanTask
from edu.stanford.cmed.devcli.taskexecutor.TaskExecutor import TaskExecutor

console = Console()


class DeployTaskExecutor(TaskExecutor):

    def __init__(self):
        super().__init__()

    def execute(self, task: PlanTask, job_progress: Progress, dry_run: bool):
        super().display_header(task, job_progress, 'cyan', "Deploy task executor #" + str(task.node_id))
