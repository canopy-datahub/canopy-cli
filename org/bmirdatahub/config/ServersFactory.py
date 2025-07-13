from org.bmirdatahub.model.CheckRunning import CheckRunning
from org.bmirdatahub.model.Servers import Servers


class ServersFactory:

    def __init__(self):
        super().__init__()

    @staticmethod
    def build_servers():
        servers = Servers()
        servers.add_microservice('download', 1)
        servers.add_microservice('email', 2)
        servers.add_microservice('entity', 3)
        servers.add_microservice('report', 4)
        servers.add_microservice('search', 5)
        servers.add_microservice('submission', 6)
        servers.add_microservice('user', 7)

        servers.add_infra('Postgres', 5432, check_running=CheckRunning.OPEN_PORT)
        servers.add_infra('OpenSearch-REST', 9200)
        servers.add_infra('OpenSearch-Transport', 9300, check_running=CheckRunning.OPEN_PORT)
        servers.add_infra('Keycloak', 8080)

        servers.add_frontend('main', 4200)

        return servers
