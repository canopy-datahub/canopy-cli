from typing import List

from rich.console import Console

from org.bmirdatahub.model.Repo import Repo
from org.bmirdatahub.model.RepoRelation import RepoRelation
from org.bmirdatahub.model.RepoRelationType import RepoRelationType
from org.bmirdatahub.model.RepoType import RepoType

console = Console()


class Repos:
    def __init__(self):
        self.map = {}
        self.relations: List[RepoRelation] = []
        self.use_private_repos = False

    def add_repo(self, repo):
        if repo.is_private and not self.use_private_repos:
            return
        name = repo.name
        if name in self.map:
            console.log("Repo already present in registry:" + name)
        else:
            self.map[name] = repo

    def add_relation(self, relation: RepoRelation):
        self.relations.append(relation)

    def get_relations(self, source_repo: Repo, relation_type: RepoRelationType) -> list[RepoRelation]:
        rels = []
        for rel in self.relations:
            if rel.source_repo.get_fqn() == source_repo.get_fqn() and rel.relation_type == relation_type:
                rels.append(rel)
        return rels

    def get_list_top(self) -> [Repo]:
        return list(self.map.values())

    def get_list_all(self) -> [Repo]:
        repos = []
        for name, repo in self.map.items():
            repos.append(repo)
            if len(repo.sub_repos) > 0:
                for sub_repo in repo.sub_repos:
                    repos.append(sub_repo)
        return repos

    def get_parent(self) -> [Repo]:
        for name, repo in self.map.items():
            if repo.repo_type == RepoType.JAVA_WRAPPER and "parent" in repo.name:
                return [repo]
        return []

    def get_libraries(self) -> [Repo]:
        for name, repo in self.map.items():
            if repo.repo_type == RepoType.JAVA_WRAPPER and "libraries" in repo.name:
                return [repo]
        return []

    def get_project(self) -> [Repo]:
        for name, repo in self.map.items():
            if repo.repo_type == RepoType.JAVA_WRAPPER and "project" in repo.name:
                return [repo]
        return []

    def get_frontends(self) -> [Repo]:
        repos = []
        for name, repo in self.map.items():
            if repo.is_frontend:
                repos.append(repo)
        return repos
