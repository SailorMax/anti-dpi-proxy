#!/bin/sh
SCRIPT_DIR=$(dirname $(readlink -f "$0"))

# choose config files
CFG_DIR="/opt/adp-conf/"
GET_ACTUAL_CFG_FILENAME() {
	local FILENAME=${CFG_DIR}$1
	[ -f ${FILENAME} ] && echo "${FILENAME}" || echo "${FILENAME}.default"
}

# read conf
DISPUTED_DOMAINS=$(cat $(GET_ACTUAL_CFG_FILENAME 'disputed_domains.txt') | sed -e '/^[[:space:]]*$/d' -e '/^#/d')
DISPUTED_IPS=$(cat $(GET_ACTUAL_CFG_FILENAME 'disputed_ips.txt') | sed -e '/^[[:space:]]*$/d' -e '/^#/d')
EXT_PROXY_WHITELIST=$(cat $(GET_ACTUAL_CFG_FILENAME 'ext_proxy_whitelist.txt') | sed -e '/^[[:space:]]*$/d' -e '/^#/d')

# prepare env-variables
export DNSMASQ_STR=$(echo -n "$DISPUTED_DOMAINS" | tr '\n' '/')
export DOMAINS_JS_LIST=$(echo -n "$DISPUTED_DOMAINS" | sed 's/\(.*\)/"\1",/g')
export IPS_JS_LIST=$(echo -n "$DISPUTED_IPS" | sed 's/\(.*\)/"\1",/g')
export EXT_PROXY_WHITELIST_JS_LIST=$(echo -n "$EXT_PROXY_WHITELIST" | sed 's/\(.*\)/"\1",/g')

# replace env-variables and create config files
case $1 in
	"pac")
		mkdir -p /var/www/static
		( echo "cat <<EOF" ; cat $SCRIPT_DIR/pac-files/proxy_chooser.pac.tpl ; echo EOF ) | sh > /var/www/static/proxy_chooser.pac
		;;
	"dnsproxy")
		( echo "cat <<EOF" ; cat ${CFG_DIR}dnsproxy.yaml.tpl ; echo EOF ) | sh > /opt/dnsproxy/config.yaml
		;;
	"proxy-chain")
		cp -f $(GET_ACTUAL_CFG_FILENAME 'ext_proxies.txt') /opt/proxy-chain/ext_proxies.txt
		cp -f $(GET_ACTUAL_CFG_FILENAME 'ext_proxy_whitelist.txt') /opt/proxy-chain/ext_proxy_whitelist.txt
		ls -l
		cat /opt/proxy-chain/ext_proxies.txt
		;;
	*)
		echo "Nothing to do"
		;;
esac
