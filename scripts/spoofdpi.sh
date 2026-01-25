#!/bin/sh

# change DNS to dns-proxy
DNS_PROXY_IP=$(nslookup dns-proxy | awk '/^Address: / { print $2 }' | head -1)
if [ $? -eq 0 ]; then
	echo "found dns-proxy with IP ${DNS_PROXY_IP}"
else
	echo "dns-proxy container not found"
	exit 1
fi

# run server
exec ./spoofdpi --dns-addr ${DNS_PROXY_IP}:53 --dns-mode udp $*
