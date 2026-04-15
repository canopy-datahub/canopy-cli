from edu.stanford.cmed.devcli.model.PlanTask import PlanTask
from edu.stanford.cmed.devcli.model.Repo import Repo
from edu.stanford.cmed.devcli.model.TaskType import TaskType


class DeployShellTaskFactory:

    def __init__(self):
        super().__init__()

    @classmethod
    def maven_deploy_skip_tests(cls, repo: Repo) -> PlanTask:
        task = PlanTask("Maven deploy skip tests", TaskType.SHELL, repo)
        task.command_list = ['mvn deploy -DskipTests']
        return task

    @classmethod
    def npm_publish(cls, repo: Repo) -> PlanTask:
        task = PlanTask("NPM publish", TaskType.SHELL, repo)
        task.command_list = ['npm publish']
        return task

    @classmethod
    def npm_install_publish(cls, repo: Repo) -> PlanTask:
        task = PlanTask("NPM install, NPM publish", TaskType.SHELL, repo)
        task.command_list = ['npm install', 'npm publish']
        return task
