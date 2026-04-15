import json
import os

from jsonpath_ng import parse
from lxml import etree
from rich.console import Console
from rich.table import Table, Column

from edu.stanford.cmed.devcli.model.ArtifactEntryReport import ArtifactEntryReport
from edu.stanford.cmed.devcli.model.ArtifactStatus import ArtifactStatus
from edu.stanford.cmed.devcli.model.RepoRelation import RepoRelation
from edu.stanford.cmed.devcli.model.RepoRelationType import RepoRelationType
from edu.stanford.cmed.devcli.model.RepoType import RepoType
from edu.stanford.cmed.devcli.model.VersionReport import VersionReport
from edu.stanford.cmed.devcli.model.VersionType import VersionType
from edu.stanford.cmed.devcli.util.Const import Const
from edu.stanford.cmed.devcli.util.GlobalContext import GlobalContext
from edu.stanford.cmed.devcli.util.Util import Util
from edu.stanford.cmed.devcli.worker.Worker import Worker

console = Console()


class VersionWorker(Worker):

    def __init__(self):
        super().__init__()

    def check_versions(self):
        table = Table("Repo",
                      Column(header="Dir"),
                      Column(header="Type", justify="center"),
                      Column(header="File"),
                      Column(header="Version type"),
                      Column(header="Version value"),
                      Column(header="Status"))

        report = VersionReport()
        for repo in GlobalContext.repos.get_list_all():
            self.get_version_report(repo, report)

        report.summarize()

        last_repo_name = None
        for entry in report.entries:
            if last_repo_name != entry.repo.name:
                table.add_section()
            table.add_row(entry.repo.name, entry.dir_suffix, str(entry.repo.repo_type), entry.file_name,
                          str(entry.version_type), entry.version, entry.status)
            last_repo_name = entry.repo.name

        table.caption = report.get_caption()
        console.print(table)
        Util.write_rich_app_file('last_version_check.rich.txt', table)

    def get_version_report(self, repo, report: VersionReport):
        if repo.repo_type == RepoType.JAVA_WRAPPER or repo.repo_type == RepoType.JAVA:
            self.analyze_java_wrapper(repo, report)
        elif repo.repo_type == RepoType.ANGULAR_JS or repo.repo_type == RepoType.ANGULAR:
            self.analyze_angular_js(repo, report)
        elif repo.repo_type == RepoType.EMBER:
            self.analyze_ember(repo, report)
        elif repo.repo_type == RepoType.ANGULAR_DIST:
            self.analyze_angular_dist(repo, report)
        elif repo.repo_type == RepoType.TYPESCRIPT:
            self.analyze_typescript(repo, report)
        elif repo.repo_type == RepoType.REACT:
            self.analyze_react(repo, report)
        elif repo.repo_type == RepoType.MULTI or repo.repo_type == RepoType.PYTHON or repo.repo_type == RepoType.MKDOCS \
                or repo.repo_type == RepoType.CONTENT_DELIVERY or repo.repo_type == RepoType.PHP or repo.repo_type == RepoType.MISC:
            VersionWorker.mark_empty(repo, report)
        elif repo.repo_type == RepoType.DEVELOPMENT:
            self.mark_empty(repo, report)
        else:
            VersionWorker.mark_unknown(repo, report)

    def analyze_java_wrapper(self, repo, report: VersionReport):
        root_dir = Util.get_wd(repo)
        self.analyze_pom_recursively(repo, root_dir, 0, report)

    def analyze_pom_recursively(self, repo, root_dir, depth, report: VersionReport):
        pom_path = os.path.join(root_dir, Const.FILE_POM_XML)
        url = ''
        try:
            tree = etree.parse(pom_path)
        except Exception as e:
            dir_suffix = Util.get_repo_suffix(repo)
            entry = ArtifactEntryReport(repo, dir_suffix, url)
            entry.set_status(ArtifactStatus.ERROR)
            report.add(repo, dir_suffix, Const.FILE_POM_XML, VersionType.POM_OWN, 'MISSING')
            return

        dir_suffix = root_dir[len(Util.app_home):]

        res = self.get_spath(tree, '/x:project/x:version')
        if len(res) == 1:
            report.add(repo, dir_suffix, Const.FILE_POM_XML, VersionType.POM_OWN, res[0].text)

        res = self.get_spath(tree, '/x:project/x:parent/x:version')
        if len(res) == 1:
            report.add(repo, dir_suffix, Const.FILE_POM_XML, VersionType.POM_PARENT, res[0].text)

        res = self.get_spath(tree, '/x:project/x:properties/x:devcli.version')
        if len(res) == 1:
            report.add(repo, dir_suffix, Const.FILE_POM_XML, VersionType.POM_PROPERTIES, res[0].text)

        res = self.get_spath(tree, '/x:project/x:modules/x:module')
        if len(res) > 0:
            for module in res:
                if not module.text.startswith('..'):
                    self.analyze_pom_recursively(repo, os.path.join(root_dir, module.text), depth + 1, report)

    @staticmethod
    def get_spath(tree, path):
        return tree.xpath(path, namespaces={'x': 'http://maven.apache.org/POM/4.0.0'})

    @staticmethod
    def get_json_path(json_data, json_path):
        jsonpath_expression = parse(json_path)
        match = jsonpath_expression.find(json_data)
        if len(match) == 1:
            return match[0].value

    @staticmethod
    def mark_unknown(repo, report):
        dir_suffix = Util.get_repo_suffix(repo)
        report.add(repo, dir_suffix, '', VersionType.UNKNOWN, '')

    @staticmethod
    def mark_empty(repo, report: VersionReport):
        dir_suffix = Util.get_repo_suffix(repo)
        report.add(repo, dir_suffix, '', VersionType.EMPTY, '')

    def analyze_angular_js(self, repo, report: VersionReport):
        root_dir = Util.get_wd(repo)
        dir_suffix = Util.get_repo_suffix(repo)

        self.analyze_package_and_lock(repo, report, root_dir, dir_suffix)

        source_of_relations = GlobalContext.repos.get_relations(repo, RepoRelationType.IS_SOURCE_OF)
        for source_of_relation in source_of_relations:
            if RepoRelation.TARGET_SUB_FOLDER in source_of_relation.parameters:
                dist_subfolder = source_of_relation.parameters[RepoRelation.TARGET_SUB_FOLDER]

                if VersionType.DIST_NPM_PACKAGE_OWN in repo.version_list:
                    package_json_path = os.path.join(root_dir, dist_subfolder, Const.FILE_PACKAGE_JSON)
                    with open(package_json_path, 'r') as json_file:
                        json_data = json.load(json_file)
                        version = self.get_json_path(json_data, '$.version')
                        report.add(repo, dir_suffix, Const.FILE_PACKAGE_JSON, VersionType.DIST_NPM_PACKAGE_OWN, version)

                if VersionType.DIST_NPM_PACKAGE_LOCK_OWN in repo.version_list or VersionType.DIST_NPM_PACKAGE_LOCK_PACKAGES_OWN in repo.version_list:
                    package_json_lock_path = os.path.join(root_dir, dist_subfolder, Const.FILE_PACKAGE_LOCK_JSON)
                    with open(package_json_lock_path, 'r') as json_file:
                        json_data = json.load(json_file)

                        if VersionType.PACKAGE_LOCK_OWN in repo.version_list:
                            version = self.get_json_path(json_data, '$.version')
                            report.add(repo, dir_suffix, Const.FILE_PACKAGE_LOCK_JSON,
                                       VersionType.DIST_NPM_PACKAGE_LOCK_OWN, version)

                        if VersionType.PACKAGE_LOCK_PACKAGES_OWN in repo.version_list:
                            version_pack = self.get_json_path(json_data, '$.packages[""].version')
                            report.add(repo, dir_suffix, Const.FILE_PACKAGE_LOCK_JSON,
                                       VersionType.DIST_NPM_PACKAGE_LOCK_PACKAGES_OWN, version_pack)

    def analyze_angular_dist(self, repo, report: VersionReport):
        root_dir = Util.get_wd(repo)
        dir_suffix = root_dir[len(Util.app_home):]

        self.analyze_package_and_lock(repo, report, root_dir, dir_suffix)

    def analyze_typescript(self, repo, report: VersionReport):
        root_dir = Util.get_wd(repo)
        dir_suffix = root_dir[len(Util.app_home):]

        self.analyze_package_and_lock(repo, report, root_dir, dir_suffix)

    def analyze_react(self, repo, report: VersionReport):
        root_dir = Util.get_wd(repo)
        dir_suffix = root_dir[len(Util.app_home):]

        self.analyze_package_and_lock(repo, report, root_dir, dir_suffix)

    def analyze_ember(self, repo, report: VersionReport):
        root_dir = Util.get_wd(repo)
        dir_suffix = Util.get_repo_suffix(repo)

        self.analyze_package_and_lock(repo, report, root_dir, dir_suffix)

    def analyze_package_and_lock(self, repo, report: VersionReport, root_dir: str, dir_suffix: str):
        if VersionType.PACKAGE_OWN in repo.version_list:
            package_json_path = os.path.join(root_dir, Const.FILE_PACKAGE_JSON)
            with open(package_json_path, 'r') as json_file:
                json_data = json.load(json_file)
                version = self.get_json_path(json_data, '$.version')
                report.add(repo, dir_suffix, Const.FILE_PACKAGE_JSON, VersionType.PACKAGE_OWN, version)

        if VersionType.PACKAGE_LOCK_OWN in repo.version_list or VersionType.PACKAGE_LOCK_PACKAGES_OWN in repo.version_list:
            package_json_lock_path = os.path.join(root_dir, Const.FILE_PACKAGE_LOCK_JSON)
            with open(package_json_lock_path, 'r') as json_file:
                json_data = json.load(json_file)

                if VersionType.PACKAGE_LOCK_OWN in repo.version_list:
                    version = self.get_json_path(json_data, '$.version')
                    report.add(repo, dir_suffix, Const.FILE_PACKAGE_LOCK_JSON, VersionType.PACKAGE_LOCK_OWN, version)

                if VersionType.PACKAGE_LOCK_PACKAGES_OWN in repo.version_list:
                    version_pack = self.get_json_path(json_data, '$.packages[""].version')
                    report.add(repo, dir_suffix, Const.FILE_PACKAGE_LOCK_JSON, VersionType.PACKAGE_LOCK_PACKAGES_OWN,
                               version_pack)
