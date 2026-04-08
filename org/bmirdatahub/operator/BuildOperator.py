from rich.console import Console

from org.bmirdatahub.model.PlanTask import PlanTask
from org.bmirdatahub.model.RepoType import RepoType
from org.bmirdatahub.model.TaskType import TaskType
from org.bmirdatahub.operator.Operator import Operator
from org.bmirdatahub.taskfactory.BuildShellTaskFactory import BuildShellTaskFactory
from org.bmirdatahub.util.Util import Util

console = Console()


class BuildOperator(Operator):

    def __init__(self):
        super().__init__()

    @staticmethod
    def expand(task: PlanTask):
        repo_list = [task.repo]
        repo_list_flat = Util.get_flat_repo_list(repo_list)
        build_frontends = True
        for repo in repo_list_flat:
            if repo.repo_type == RepoType.JAVA_WRAPPER:
                shell_wrapper = PlanTask("Build java wrapper project", TaskType.SHELL_WRAPPER, repo)
                shell_wrapper.add_task_as_task(BuildShellTaskFactory.maven_clean_install_skip_tests(repo))
                task.add_task_as_task(shell_wrapper)
            elif repo.repo_type == RepoType.JAVA:
                shell_wrapper = PlanTask("Build java project", TaskType.SHELL_WRAPPER, repo)
                shell_wrapper.add_task_as_task(BuildShellTaskFactory.maven_clean_install_skip_tests(repo))
                task.add_task_as_task(shell_wrapper)
            elif repo.repo_type == RepoType.ANGULAR:
                if build_frontends:
                    shell_wrapper = PlanTask("Build angular project", TaskType.SHELL_WRAPPER, repo)
                    shell_wrapper.add_task_as_task(BuildShellTaskFactory.npm_install_legacy_ng_build(repo))
                else:
                    shell_wrapper = PlanTask("Build angular project - skipped because of lobal setting",
                                             TaskType.SHELL_WRAPPER,
                                             repo)
                    shell_wrapper.add_task_as_task(BuildShellTaskFactory.noop(repo))
                task.add_task_as_task(shell_wrapper)
            elif repo.repo_type == RepoType.ANGULAR_DIST:
                shell_wrapper = PlanTask("Build angular dist project", TaskType.SHELL_WRAPPER, repo)
                shell_wrapper.add_task_as_task(BuildShellTaskFactory.noop(repo))
                task.add_task_as_task(shell_wrapper)
            elif repo.repo_type == RepoType.ANGULAR_JS:
                if build_frontends:
                    shell_wrapper = PlanTask("Build angularJS project", TaskType.SHELL_WRAPPER, repo)
                    shell_wrapper.add_task_as_task(BuildShellTaskFactory.npm_install(repo))
                else:
                    shell_wrapper = PlanTask("Build angularJS project - skipped because of global setting",
                                             TaskType.SHELL_WRAPPER, repo)
                    shell_wrapper.add_task_as_task(BuildShellTaskFactory.noop(repo))
                task.add_task_as_task(shell_wrapper)
            elif repo.repo_type == RepoType.TYPESCRIPT:
                shell_wrapper = PlanTask("Build TypeScript project", TaskType.SHELL_WRAPPER, repo)
                if not repo.skip_npm_install:
                    shell_wrapper.add_task_as_task(BuildShellTaskFactory.npm_install(repo))
                shell_wrapper.add_task_as_task(BuildShellTaskFactory.npm_run_build(repo))
                task.add_task_as_task(shell_wrapper)
            elif repo.repo_type == RepoType.REACT:
                shell_wrapper = PlanTask("Build React project", TaskType.SHELL_WRAPPER, repo)
                if not repo.skip_npm_install:
                    shell_wrapper.add_task_as_task(BuildShellTaskFactory.npm_install(repo))
                shell_wrapper.add_task_as_task(BuildShellTaskFactory.npm_run_build(repo))
                task.add_task_as_task(shell_wrapper)
            else:
                not_handled = PlanTask("Skip repo", TaskType.NOOP, repo)
                not_handled.add_task_as_task(BuildShellTaskFactory.noop(repo))
                task.add_task_as_task(not_handled)
