# datahub-cli
## About
DataHub CLI is DataHub's command line interface used to facilitate:
* Development
* Managing a running DataHub server

As such, you should install `datahub-cli` in the context of an existing or a new `DataHub` installation.

This is why we are setting `DATAHUB_HOME` and the alias in the script below. You should have these set in your bash profile. 
## How to install

```bash
export DATAHUB_HOME='/Users/datahub-dev/DATAHUB/'

cd ${DATAHUB_HOME}
git clone https://github.com/bmir-datahub/datahub-cli

cd datahub-cli
git checkout develop

python -m venv ./.venv
source .venv/bin/activate
pip install -r requirements.txt

alias dhcli='source $DATAHUB_HOME/datahub-cli/cli.sh'

cli.py --help
```

## Available commands
`datahub-cli` is executed by running `dhcli` after the alias is set.

The available commands will be listed by executing:
```bash
dhcli
```

## Cheat sheet
The full set of commands and subcommands will be shown as a `pdf` file after executing:
```bash
dhcli cheat
```

![DATAHUB CLI commands](assets/docs/datahub-cli.png?raw=true "DATAHUB CLI commands")