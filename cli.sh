#!/bin/bash
DATAHUB_CLI_CWD=$PWD
pushd $CANOPY_HOME/canopy-cli > /dev/null
source .venv/bin/activate;
if [ "$1" = 'build' ] && [ "$2" = 'this' ]; then
  python "$CANOPY_HOME/canopy-cli/cli.py" "$@" --wd="$DATAHUB_CLI_CWD"
elif [ "$1" = 'deploy' ] && [ "$2" = 'this' ]; then
  python "$CANOPY_HOME/canopy-cli/cli.py" "$@" --wd="$DATAHUB_CLI_CWD"
else
  python "$CANOPY_HOME/canopy-cli/cli.py" "$@"
fi
popd > /dev/null
NEXT_GIT_FILE=$HOME/.datahub/next_git_repo
if test -f "$NEXT_GIT_FILE"; then
  cd $(cat "$NEXT_GIT_FILE")
  rm "$NEXT_GIT_FILE"
fi
