#!/bin/sh
SCRIPT_DIR=$(dirname $(readlink -f "$0"))

$SCRIPT_DIR/prepare_configs.sh ssh-proxy

# run server
set -Eeo pipefail
ssh -D 0.0.0.0:1081 -N -C $* remote-ssh-proxy
