#!/bin/sh
SCRIPT_DIR=$(dirname $(readlink -f "$0"))

source $SCRIPT_DIR/prepare_configs.sh dnsproxy

# run server
exec /opt/dnsproxy/dnsproxy --config-path=/opt/dnsproxy/config.yaml "$@"
