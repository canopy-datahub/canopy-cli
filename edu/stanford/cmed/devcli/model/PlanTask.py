from edu.stanford.cmed.devcli.model.Plan import Plan
from edu.stanford.cmed.devcli.model.Repo import Repo
from edu.stanford.cmed.devcli.model.TaskType import TaskType


class PlanTask(Plan):

    def __init__(self, name: str, task_type: TaskType, repo: Repo, parameters=None):
        super().__init__(name)
        if parameters is None:
            parameters = dict()
        self.task_type = task_type
        self.repo = repo
        self.command_list = None
        self.variables = None
        self.parameters = parameters

    def get_parameter(self, parameter_name):
        if parameter_name in self.parameters:
            return self.parameters[parameter_name]
        else:
            return None
