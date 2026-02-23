#!/bin/sh
SCRIPT_DIR=$(dirname $(readlink -f "$0"))

# change DNS to dns-proxy
source $SCRIPT_DIR/prepare_configs.sh bye_dpi
if [ "${DNS_PROXY_IP}" == "" ]; then
	echo "dns-proxy container not found"
	exit 1
fi

cat /etc/resolv.conf | sed "/^nameserver /i nameserver ${DNS_PROXY_IP}" > /etc/resolv.conf.new
cp /etc/resolv.conf /etc/resolv.conf.default
cat /etc/resolv.conf.new > /etc/resolv.conf

# run server
exec ./ciadpi "$@"
