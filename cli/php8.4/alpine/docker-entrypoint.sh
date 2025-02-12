#!/bin/sh
set -euo pipefail

# first arg is `-f` or `--some-option`
# or if our command is a valid wp-cli subcommand, let's invoke it through wp-cli instead
# (this allows for "docker run wordpress:cli help", etc)
if [ "${1#-}" != "$1" ] || wp help "$1" > /dev/null 2>&1; then
	set -- wp "$@"
fi

exec "$@"
