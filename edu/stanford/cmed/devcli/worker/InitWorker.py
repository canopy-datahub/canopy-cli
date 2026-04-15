import getpass
import os
import shutil

from rich.console import Console
from rich.panel import Panel
from rich.style import Style

from edu.stanford.cmed.devcli.util.Util import Util
from edu.stanford.cmed.devcli.worker.Worker import Worker

console = Console()


class InitWorker(Worker):

    def __init__(self):
        super().__init__()

    @staticmethod
    def init():
        home = Util.app_home
        user = getpass.getuser()

        target_files = {
            'aws-parameters': {
                'target': os.path.join(home, f'aws-parameters-dev-{user}.json'),
                'source': os.path.join(home, 'canopy-cloud-replication', 'file-templates', 'aws-parameters-dev.json'),
            },
            'canopy-profile': {
                'target': os.path.join(home, 'canopy-profile-native-develop.sh'),
                'source': os.path.join(home, 'canopy-development', 'file-templates', 'canopy-profile-native-develop.sh'),
            },
            'set-canopy-env': {
                'target': os.path.join(home, 'set-canopy-env.sh'),
                'source': os.path.join(home, 'canopy-cloud-replication', 'file-templates', 'set-canopy-env.sh'),
            },
        }

        missing = {}
        for key, paths in target_files.items():
            if not os.path.exists(paths['target']):
                missing[key] = paths

        if not missing:
            console.print(Panel(
                f"All init files are already in place for user [bold]{user}[/bold].\n\n"
                f"  ✓ aws-parameters-dev-{user}.json\n"
                f"  ✓ canopy-profile-native-develop.sh\n"
                f"  ✓ set-canopy-env.sh",
                title="[bold green]Init",
                title_align="left",
                style=Style(color="green"),
            ))
            return

        copied = []
        errors = []

        for key, paths in missing.items():
            source = paths['source']
            target = paths['target']
            if not os.path.exists(source):
                errors.append(f"Source template not found: {source}")
                continue
            shutil.copy2(source, target)
            copied.append((key, target))

        if errors:
            for err in errors:
                console.print(Panel(
                    err,
                    title="[bold red]Error",
                    title_align="left",
                    style=Style(color="red"),
                ))
            return

        # If set-canopy-env.sh was copied, personalize it for the current user
        if 'set-canopy-env' in missing:
            env_file = target_files['set-canopy-env']['target']
            content = Util.read_file(env_file)
            if content:
                content = content.replace('-user.json', f'-{user}.json')
                content = content.replace('AWS_PROFILE=canopy-dev', f'AWS_PROFILE=canopy-{user}-dev')
                Util.write_file(env_file, content)

        copied_msg = "\n".join([f"  → {path}" for _, path in copied])
        console.print(Panel(
            f"Files copied for user [bold]{user}[/bold]:\n\n{copied_msg}",
            title="[bold green]Init - Files Copied",
            title_align="left",
            style=Style(color="green"),
        ))

        if any(key == 'aws-parameters' for key, _ in copied):
            console.print(Panel(
                f"[bold]Please update the values in [yellow]aws-parameters-dev-{user}.json[/yellow] "
                f"before installing the rest of the components.[/bold]",
                title="[bold yellow]Action Required",
                title_align="left",
                style=Style(color="yellow"),
            ))
