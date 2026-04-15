from edu.stanford.cmed.devcli.model.ArtifactType import ArtifactType
from edu.stanford.cmed.devcli.model.Repo import Repo
from edu.stanford.cmed.devcli.model.RepoType import RepoType
from edu.stanford.cmed.devcli.model.Repos import Repos
from edu.stanford.cmed.devcli.model.VersionType import VersionType as V
from edu.stanford.cmed.devcli.util.Const import Const


class ReposFactory:
    git_base = Const.GIT_BASE

    def __init__(self):
        super().__init__()

    @staticmethod
    def build_repos():
        repos = Repos()

        repos.add_repo(Repo("canopy-cli", RepoType.PYTHON, ArtifactType.NONE, [], allow_different_version=True))
        repos.add_repo(Repo("canopy-cloud-replication", RepoType.DEVELOPMENT, ArtifactType.NONE, [], allow_different_version=True))
        repos.add_repo(Repo("canopy-deployment-scripts", RepoType.DEVELOPMENT, ArtifactType.NONE, [], allow_different_version=True))
        repos.add_repo(Repo("canopy-development", RepoType.DEVELOPMENT, ArtifactType.NONE, [], allow_different_version=True))
        repos.add_repo(Repo("canopy-docs", RepoType.DEVELOPMENT, ArtifactType.NONE, [], allow_different_version=True))

        repos.add_repo(Repo("datahub-project", RepoType.JAVA_WRAPPER, ArtifactType.MAVEN, [V.POM_OWN]))

        repos.add_repo(Repo("datahub-service-download", RepoType.JAVA, ArtifactType.MAVEN, [V.POM_OWN], is_microservice=True, allow_different_version=True))
        repos.add_repo(Repo("datahub-service-email", RepoType.JAVA, ArtifactType.MAVEN, [V.POM_OWN], is_microservice=True, allow_different_version=True))
        repos.add_repo(Repo("datahub-service-entity", RepoType.JAVA, ArtifactType.MAVEN, [V.POM_OWN], is_microservice=True, allow_different_version=True))
        repos.add_repo(Repo("datahub-service-report", RepoType.JAVA, ArtifactType.MAVEN, [V.POM_OWN], is_microservice=True, allow_different_version=True))
        repos.add_repo(Repo("datahub-service-search", RepoType.JAVA, ArtifactType.MAVEN, [V.POM_OWN], is_microservice=True, allow_different_version=True))
        repos.add_repo(Repo("datahub-service-submission", RepoType.JAVA, ArtifactType.MAVEN, [V.POM_OWN], is_microservice=True, allow_different_version=True))
        repos.add_repo(Repo("datahub-service-user", RepoType.JAVA, ArtifactType.MAVEN, [V.POM_OWN], is_microservice=True, allow_different_version=True))

        repos.add_repo(Repo("datahub-ui-main", RepoType.REACT, ArtifactType.NPM, [V.PACKAGE_OWN], is_frontend=True, allow_different_version=True))

        return repos
