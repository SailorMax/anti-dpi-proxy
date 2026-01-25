#!/bin/sh
set -Eeo pipefail

exec node /opt/proxy-chain/server.js --host=0.0.0.0 --proxies_file=./ext_proxies.txt $*
