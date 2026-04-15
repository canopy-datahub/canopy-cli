# canopy-cli

## About
Canopy-CLI is Canopy's command line interface used to facilitate:
* Development
* Deployment to AWS
* Management of a running remote Canopy installation
* Management of a running local Canopy installation

As such, you should install `canopy-cli` in the context of an existing or a new `Canopy` installation.

This is why we are setting `CANOPY_HOME` and the alias in the script below. You should have these set in your bash profile. 
## How to install

```bash
export CANOPY_HOME='~/CANOPY'

cd ${CANOPY_HOME}
git clone https://github.com/canopy-datahub/canopy-cli

cd canopy-cli
# checkout the develop branch for the latest features
git checkout develop

python -m venv ./.venv
source .venv/bin/activate
pip install -r requirements.txt

alias canopycli='source $CANOPY_HOME/canopy-cli/cli.sh'

cli.py --help
```

## Available commands
`canopy-cli` is executed by running `canopycli` after the alias is set.

The available commands will be listed by executing:
```bash
canopycli
```

## Cheat sheet
The full set of commands and subcommands will be shown as a `pdf` file after executing:
```bash
canopycli cheat
```