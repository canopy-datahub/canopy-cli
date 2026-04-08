from org.bmirdatahub.model.Plan import Plan
from org.bmirdatahub.model.TaskType import TaskType
from org.bmirdatahub.planner.Planner import Planner
from org.bmirdatahub.util.GlobalContext import GlobalContext
from org.bmirdatahub.util.Util import Util


class DeployPlanner(Planner):

    def __init__(self):
        super().__init__()

    @staticmethod
    def parent(plan: Plan, parameters: dict = None):
        plan.add_task(
            "Deploy parent",
            TaskType.DEPLOY,
            GlobalContext.repos.get_parent(),
            parameters
        )

    @staticmethod
    def project(plan: Plan, parameters: dict = None):
        plan.add_task(
            "Deploy project",
            TaskType.DEPLOY,
            GlobalContext.repos.get_project(),
            parameters
        )

    @staticmethod
    def frontends(plan: Plan, parameters: dict = None):
        plan.add_task(
            "Deploy frontends",
            TaskType.DEPLOY,
            GlobalContext.repos.get_frontends(),
            parameters
        )

    @staticmethod
    def this(plan: Plan, wd: str):
        for repo in GlobalContext.repos.get_list_all():
            if Util.get_wd(repo).lower() == wd.lower():
                plan.add_task(
                    "Deploy current repo",
                    TaskType.DEPLOY,
                    [repo]
                )

    @staticmethod
    def all(plan: Plan):
        DeployPlanner.parent(plan)
        DeployPlanner.project(plan)
        DeployPlanner.frontends(plan)
