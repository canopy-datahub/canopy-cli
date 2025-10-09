from org.bmirdatahub.model.CheckRunning import CheckRunning
from org.bmirdatahub.model.Servers import Servers


class ServersFactory:

    def __init__(self):
        super().__init__()

    @staticmethod
    def build_servers():
        servers = Servers()
        servers.add_microservice('download', 6, 'Download', 'api/download/v1')
        servers.add_microservice('email', 5, 'Email', 'api/email/v1')
        servers.add_microservice('entity', 0, 'Entity', 'api/entity/v1')
        servers.add_microservice('report', 4, 'Report', 'api/report/v1')
        servers.add_microservice('search', 1, 'Search', 'api/search/v1')
        servers.add_microservice('submission', 3, 'Submission', 'api/submission-service/v1')
        servers.add_microservice('user', 2,'User', 'api/user/v1')

        servers.add_infra('Postgres', 5432, check_running=CheckRunning.OPEN_PORT)
        servers.add_infra('OpenSearch-REST', 9200)
        servers.add_infra('Keycloak', 8180)

        servers.add_frontend('main', 3000)

        return servers
