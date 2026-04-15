from edu.stanford.cmed.devcli.model.Plan import Plan
from edu.stanford.cmed.devcli.model.TaskType import TaskType
from edu.stanford.cmed.devcli.planner.Planner import Planner
from edu.stanford.cmed.devcli.util.GlobalContext import GlobalContext
from edu.stanford.cmed.devcli.util.Util import Util


class BuildPlanner(Planner):

    def __init__(self):
        super().__init__()

    @staticmethod
    def parent(plan: Plan):
        plan.add_task(
            "Build parent",
            TaskType.BUILD,
            GlobalContext.repos.get_parent()
        )

    @staticmethod
    def project(plan: Plan):
        plan.add_task(
            "Build project",
            TaskType.BUILD,
            GlobalContext.repos.get_project()
        )

    @staticmethod
    def frontends(plan: Plan):
        plan.add_task(
            "Build frontends",
            TaskType.BUILD,
            GlobalContext.repos.get_frontends()
        )

    @staticmethod
    def this(plan: Plan, wd: str):
        for repo in GlobalContext.repos.get_list_all():
            if Util.get_wd(repo).lower() == wd.lower():
                plan.add_task(
                    "Build current repo",
                    TaskType.BUILD,
                    [repo]
                )
