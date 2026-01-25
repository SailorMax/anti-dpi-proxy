#!/bin/sh

# change DNS to dns-proxy
DNS_PROXY_IP=$(nslookup dns-proxy | awk '/^Address: / { print $2 }' | head -1)
if [ $? -eq 0 ]; then
	echo "found dns-proxy with IP ${DNS_PROXY_IP}"
else
	echo "dns-proxy container not found"
	exit 1
fi
cat /etc/resolv.conf | sed "/^nameserver /i nameserver ${DNS_PROXY_IP}" > /etc/resolv.conf.new
cp /etc/resolv.conf /etc/resolv.conf.default
cat /etc/resolv.conf.new > /etc/resolv.conf

# run server
exec ./ciadpi $*
