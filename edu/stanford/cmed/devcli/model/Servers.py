from rich.console import Console

from edu.stanford.cmed.devcli.model.CheckRunning import CheckRunning
from edu.stanford.cmed.devcli.model.Server import Server
from edu.stanford.cmed.devcli.model.ServerTag import ServerTag
from edu.stanford.cmed.devcli.model.ServerType import ServerType

console = Console()


class Servers:
    def __init__(self):
        self.map = {}

    def add_microservice(self, name: str, port_offset: int, display_name=None, health_prefix=None):
        server = Server(name,
                        server_type=ServerType.MICROSERVICE,
                        tag=ServerTag.MICROSERVICE,
                        port=8080 + port_offset,
                        admin_port=9100 + port_offset,
                        stop_port=9200 + port_offset,
                        check_running=CheckRunning.HEALTH_CHECK,
                        display_name=display_name,
                        health_prefix=health_prefix
                        )
        self.map[name] = server

    def add_infra(self, name: str, port: int, check_running: CheckRunning = CheckRunning.RESPONSE):
        server = Server(name,
                        server_type=ServerType.INFRASTRUCTURE,
                        tag=ServerTag.INFRASTRUCTURE,
                        port=port,
                        check_running=check_running
                        )
        self.map[name] = server

    def add_frontend(self, name, port: int, display_name=None):
        server = Server(name,
                        server_type=ServerType.FRONTEND,
                        tag=ServerTag.FRONTEND,
                        port=port,
                        check_running=CheckRunning.RESPONSE,
                        display_name=display_name
                        )
        self.map[name] = server

    def add_frontend_non_essential(self, name, port: int):
        server = Server(name,
                        server_type=ServerType.FRONTEND,
                        tag=ServerTag.FRONTEND_NON_ESSENTIAL,
                        port=port,
                        check_running=CheckRunning.RESPONSE
                        )
        self.map[name] = server

    def add_dashboard(self, name, port: int):
        server = Server(name,
                        server_type=ServerType.DASHBOARD,
                        tag=ServerTag.DASHBOARD,
                        port=port,
                        check_running=CheckRunning.RESPONSE
                        )
        self.map[name] = server
