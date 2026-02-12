from org.bmirdatahub.model.ArtifactType import ArtifactType
from org.bmirdatahub.model.Repo import Repo
from org.bmirdatahub.model.RepoType import RepoType
from org.bmirdatahub.model.Repos import Repos
from org.bmirdatahub.model.VersionType import VersionType as V
from org.bmirdatahub.util.Const import Const


class ReposFactory:
    git_base = Const.GIT_BASE

    def __init__(self):
        super().__init__()

    @staticmethod
    def build_repos():
        repos = Repos()

        repos.add_repo(Repo("datahub-cli", RepoType.PYTHON, ArtifactType.NONE, [], allow_different_version=True))
        repos.add_repo(Repo("datahub-cloud-replication", RepoType.DEVELOPMENT, ArtifactType.NONE, [], allow_different_version=True))
        repos.add_repo(Repo("datahub-deployment-scripts", RepoType.DEVELOPMENT, ArtifactType.NONE, [], allow_different_version=True))
        repos.add_repo(Repo("datahub-development", RepoType.DEVELOPMENT, ArtifactType.NONE, [], allow_different_version=True))
        repos.add_repo(Repo("datahub-docs", RepoType.DEVELOPMENT, ArtifactType.NONE, [], allow_different_version=True))

        # repos.add_repo(Repo("datahub-parent", RepoType.JAVA_WRAPPER, ArtifactType.MAVEN, [V.POM_OWN, V.POM_PROPERTIES]))
        # repos.add_repo(Repo("datahub-libraries", RepoType.JAVA_WRAPPER, ArtifactType.MAVEN, [V.POM_OWN, V.POM_PARENT]))
        repos.add_repo(Repo("datahub-project", RepoType.JAVA_WRAPPER, ArtifactType.MAVEN, [V.POM_OWN]))

        # repos.add_repo(Repo("datahub-lib-keycloak-auth", RepoType.JAVA, ArtifactType.MAVEN, [V.POM_OWN], is_library=True, allow_different_version=True))

        repos.add_repo(Repo("datahub-service-download", RepoType.JAVA, ArtifactType.MAVEN, [V.POM_OWN], is_microservice=True, allow_different_version=True))
        repos.add_repo(Repo("datahub-service-email", RepoType.JAVA, ArtifactType.MAVEN, [V.POM_OWN], is_microservice=True, allow_different_version=True))
        repos.add_repo(Repo("datahub-service-entity", RepoType.JAVA, ArtifactType.MAVEN, [V.POM_OWN], is_microservice=True, allow_different_version=True))
        repos.add_repo(Repo("datahub-service-report", RepoType.JAVA, ArtifactType.MAVEN, [V.POM_OWN], is_microservice=True, allow_different_version=True))
        repos.add_repo(Repo("datahub-service-search", RepoType.JAVA, ArtifactType.MAVEN, [V.POM_OWN], is_microservice=True, allow_different_version=True))
        repos.add_repo(Repo("datahub-service-submission", RepoType.JAVA, ArtifactType.MAVEN, [V.POM_OWN], is_microservice=True, allow_different_version=True))
        repos.add_repo(Repo("datahub-service-user", RepoType.JAVA, ArtifactType.MAVEN, [V.POM_OWN], is_microservice=True, allow_different_version=True))

        repos.add_repo(Repo("datahub-ui-main", RepoType.REACT, ArtifactType.NPM, [V.PACKAGE_OWN], is_frontend=True, allow_different_version=True))

        return repos
