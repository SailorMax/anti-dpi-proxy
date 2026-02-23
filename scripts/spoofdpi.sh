#!/bin/sh
SCRIPT_DIR=$(dirname $(readlink -f "$0"))

# change DNS to dns-proxy
source $SCRIPT_DIR/prepare_configs.sh spoofdpi
if [ "${DNS_PROXY_IP}" == "" ]; then
	echo "dns-proxy container not found"
	exit 1
fi

# run server
exec ./spoofdpi --dns-addr ${DNS_PROXY_IP}:53 --dns-mode udp "$@"
