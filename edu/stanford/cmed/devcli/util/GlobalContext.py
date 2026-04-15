from rich.console import Console

from CliSettings import CliSettings
from edu.stanford.cmed.devcli.config.ReposFactory import ReposFactory
from edu.stanford.cmed.devcli.config.ServersFactory import ServersFactory
from edu.stanford.cmed.devcli.model.TaskType import TaskType
from edu.stanford.cmed.devcli.util.Util import Util

console = Console()

UTF_8 = 'utf-8'


class GlobalContext(object):
    repos = ReposFactory.build_repos()
    servers = ServersFactory.build_servers()
    task_type = None
    task_operators = {}
    task_executors = {}

    def __new__(cls):
        if not hasattr(cls, 'instance'):
            cls.instance = super(GlobalContext, cls).__new__(cls)
            cls.instance.init_task_operators()
            cls.instance.init_task_executors()
        return cls.instance

    def __init__(self):
        Util.check_app_home()

    @classmethod
    def mark_global_task_type(cls, task_type: TaskType):
        cls.task_type = task_type

    @classmethod
    def init_task_operators(cls):
        from edu.stanford.cmed.devcli.operator.BuildOperator import BuildOperator
        from edu.stanford.cmed.devcli.operator.DeployOperator import DeployOperator
        cls.task_operators = {
            TaskType.BUILD: BuildOperator(),
            TaskType.DEPLOY: DeployOperator(),
        }

    @classmethod
    def init_task_executors(cls):
        from edu.stanford.cmed.devcli.taskexecutor.BuildTaskExecutor import BuildTaskExecutor
        from edu.stanford.cmed.devcli.taskexecutor.DeployTaskExecutor import DeployTaskExecutor
        from edu.stanford.cmed.devcli.taskexecutor.ShellWrapperTaskExecutor import ShellWrapperTaskExecutor
        from edu.stanford.cmed.devcli.taskexecutor.ShellTaskExecutor import ShellTaskExecutor
        from edu.stanford.cmed.devcli.taskexecutor.NoopTaskExecutor import NoopTaskExecutor
        cls.task_executors = {
            TaskType.BUILD: BuildTaskExecutor(),
            TaskType.DEPLOY: DeployTaskExecutor(),
            TaskType.SHELL_WRAPPER: ShellWrapperTaskExecutor(),
            TaskType.SHELL: ShellTaskExecutor(),
            TaskType.NOOP: NoopTaskExecutor()
        }

    @classmethod
    def get_task_operator(cls, task_type):
        if task_type in cls.task_operators:
            return cls.task_operators[task_type]
        else:
            return None

    @classmethod
    def get_task_executor(cls, task_type):
        if task_type in cls.task_executors:
            return cls.task_executors[task_type]
        else:
            return None

    @classmethod
    def fail_on_error(cls):
        return CliSettings.do_fail_on_error

    @classmethod
    def mark_do_not_fail(cls):
        CliSettings.do_fail_on_error = False

    @classmethod
    def get_shell(cls):
        return CliSettings.shell_path

    @classmethod
    def get_sed_replace_in_place(cls):
        return CliSettings.get_sed_replace_in_place()

    @classmethod
    def get_use_osa(cls):
        return CliSettings.get_use_osa()
