#!/bin/sh
SCRIPT_DIR=$(dirname $(readlink -f "$0"))

$SCRIPT_DIR/prepare_configs.sh ssh-proxy

# check settings
cat ~/.ssh/config | grep 'Hostname ${'
if [ $? -eq '0' ]; then
	echo "(!)WARNING: Looks like ssh-proxy was not configured."
	exit 0
fi

# run server
set -Eeo pipefail
exec ssh -D 0.0.0.0:1081 -N -C "$@" remote-ssh-proxy-alias
