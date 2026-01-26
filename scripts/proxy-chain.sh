#!/bin/sh
SCRIPT_DIR=$(dirname $(readlink -f "$0"))

$SCRIPT_DIR/prepare_configs.sh proxy-chain

# run server
set -Eeo pipefail
exec node /opt/proxy-chain/server.js --host=0.0.0.0 --proxies_file=ext_proxies.txt $*
