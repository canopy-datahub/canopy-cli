import copy
import os
import sys
from math import log2
from typing import List

import rich
from rich.console import Console
from rich.panel import Panel
from rich.style import Style

from org.bmirdatahub.model.PrePostType import PrePostType
from org.bmirdatahub.model.Repo import Repo
from org.bmirdatahub.util.Const import Const

console = Console()


class Util(object):
    NEXT_GIT_FILE = 'next_git_repo'
    LAST_GIT_FILE = 'last_git_repo'
    LAST_PLAN_JSON_FILE = 'last_plan_content.json'
    LAST_PLAN_SCRIPT_FILE = 'last_plan_content.sh'
    LAST_RELEASE_PRE_BRANCH = 'last_release_pre_branch'
    LAST_RELEASE_POST_BRANCH = 'last_release_post_branch'
    LAST_RELEASE_TAG = 'last_release_tag'
    LAST_RELEASE_VERSION = 'last_release_version'
    LAST_RELEASE_NEXT_DEV_VERSION = 'last_release_next_dev_version'

    app_home: str = None

    def __new__(cls):
        if not hasattr(cls, 'instance'):
            cls.instance = super(Util, cls).__new__(cls)
        return cls.instance

    @staticmethod
    def get_wd(repo: Repo):
        return Util.app_home + "/" + repo.get_fqn()

    @staticmethod
    def get_flat_repo_list(repo_list):
        repos = []
        for repo in repo_list:
            repos.append(repo)
            if len(repo.sub_repos) > 0:
                for sub_repo in repo.sub_repos:
                    repos.append(sub_repo)
        return repos

    @staticmethod
    def get_flat_repo_list_pre_post(repo_list: List[Repo]) -> List[Repo]:
        """
        Returns the repos expanded with their sub-repos.
        The parent will be present twice, decorated with ``pre_post_type`` as
            ``PrePostType.PRE`` and ``PrePostType.POST``. The sub will have ``PrePostType.SUB``
        If there is no sub-repo, ``pre_post_type`` will stay ``None``
        Used for release
        :param repo_list: List of repos to be expanded
        :return:
        """
        repos = []
        for repo in repo_list:
            if len(repo.sub_repos) == 0:
                repos.append(repo)
            else:
                pre_repo = copy.copy(repo)
                pre_repo.pre_post_type = PrePostType.PRE
                repos.append(pre_repo)
                for sub_repo in repo.sub_repos:
                    sub_repo_clone = copy.copy(sub_repo)
                    sub_repo_clone.pre_post_type = PrePostType.SUB
                    repos.append(sub_repo_clone)
                post_repo = copy.copy(repo)
                post_repo.pre_post_type = PrePostType.POST
                repos.append(post_repo)
        return repos

    @classmethod
    def check_app_home(cls):
        if Const.APP_HOME in os.environ:
            cls.app_home = os.environ[Const.APP_HOME]
        else:
            err = Const.APP_HOME + ' environment variable is not set. In order to proceed, please set it to an existing folder'
            console.print(Panel(err, title="[bold red]Error", subtitle="[bold red]" + Const.COMMAND_NAME,
                                style=Style(color="yellow")))
            sys.exit(1)

    @classmethod
    def get_osa_script_path(cls, script_name):
        return os.path.join(os.getcwd(), 'scripts', 'osa', script_name)

    @classmethod
    def get_bash_script_path(cls, script_name):
        return os.path.join(os.getcwd(), 'scripts', 'bash', script_name)

    @classmethod
    def get_asset_file_path(cls, asset_path: List[str]):
        return os.path.join(os.getcwd(), 'assets', *asset_path)

    @classmethod
    def write_app_specific_file(cls, file_name: str, content):
        file_path = cls.get_app_file(file_name)
        return cls.write_file(file_path, content)

    @classmethod
    def read_app_specific_file(cls, file_name):
        path = cls.get_app_file(file_name)
        if not os.path.exists(path):
            return None
        with open(path, 'r') as file:
            return file.read().rstrip()

    @classmethod
    def delete_app_specific_file(cls, file_name):
        path = cls.get_app_file(file_name)
        if os.path.exists(path):
            os.remove(path)

    @classmethod
    def get_app_file(cls, file_name):
        parent_path = os.path.expanduser(Const.APP_SETTING_HOME)
        if not os.path.exists(parent_path):
            os.makedirs(parent_path)
        return os.path.join(parent_path, file_name)

    @classmethod
    def read_file(cls, file_path):
        if not os.path.exists(file_path):
            return None
        with open(file_path, 'r') as file:
            return file.read().rstrip()

    @classmethod
    def write_file(cls, file_path: str, content):
        with open(file_path, "w") as file:
            file.write(content)
        return file_path

    @classmethod
    def write_rich_app_file(cls, file_name, rich_object):
        file_path = cls.get_app_file(file_name)
        with open(file_path, "w") as file:
            rich.print(rich_object, file=file)
        return file_path

    @staticmethod
    def get_servers():
        from org.bmirdatahub.util.GlobalContext import GlobalContext
        return GlobalContext.servers.map.values()

    @staticmethod
    def format_file_size(size: int):
        units = ("B", "KiB", "MiB", "GiB", "TiB", "PiB", "EiB", "ZiB", "YiB")
        scaling = round(log2(size) * 4) // 40
        scaling = min(len(units) - 1, scaling)
        return str(round(size / (2 ** (10 * scaling)), 2)) + ' ' + units[scaling]

    @staticmethod
    def get_repo_suffix(repo: Repo):
        root_dir = Util.get_wd(repo)
        return root_dir[len(Util.app_home):]
