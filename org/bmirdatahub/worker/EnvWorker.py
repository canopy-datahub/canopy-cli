import os
from typing import List

from rich.console import Console
from rich.style import Style
from rich.table import Table

from org.bmirdatahub.util.Const import Const
from org.bmirdatahub.worker.Worker import Worker

console = Console()

core_list = [
    Const.APP_HOME,
    Const.APP_HOST,
]

APP_ENV_PREFIX = Const.APP_ENV_PREFIX
APP_NAME = Const.APP_NAME


class EnvWorker(Worker):
    def __init__(self):
        super().__init__()

    @staticmethod
    def list():
        cnt = 0
        table = Table("Name", "Value", title=APP_NAME + " environment variables")
        for name, value in sorted(os.environ.items()):
            if name.startswith(APP_ENV_PREFIX):
                table.add_row(name, value)
                cnt += 1
        table.caption = str(cnt) + " variables"
        table.style = Style(color="green")
        console.print(table)

    @staticmethod
    def core():
        table = Table("Name", "Value", title=APP_NAME + " core environment variables")
        EnvWorker.list_specific_vars(table, core_list)

    @staticmethod
    def list_specific_vars(table: Table, var_names: List[str]):
        present_cnt = 0
        missing_cnt = 0
        var_map = {}
        for name, value in sorted(os.environ.items()):
            if name.startswith(APP_ENV_PREFIX):
                var_map[name] = value
        for name in var_names:
            if name in var_map:
                table.add_row("[yellow]" + name, "✅ [green]" + var_map[name])
                present_cnt += 1
            else:
                table.add_row("[yellow]" + name, '❌ [red]MISSING')
                missing_cnt += 1

        caption = str(present_cnt) + " variables present"
        if missing_cnt > 0:
            caption += ", [red]" + str(missing_cnt) + " missing"
        table.caption = caption
        table.style = Style(color="green")
        console.print(table)

    @staticmethod
    def filter(filter_term: str):
        cnt = 0
        table = Table("Name", "Value", title=APP_NAME + " environment variables")
        for name, value in sorted(os.environ.items()):
            if name.startswith(APP_ENV_PREFIX) and filter_term.lower() in name.lower():
                table.add_row(name, value)
                cnt += 1
        table.caption = str(cnt) + " variables"
        table.style = Style(color="green")
        console.print(table)
