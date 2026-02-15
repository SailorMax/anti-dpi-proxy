#!/bin/sh
SCRIPT_DIR=$(dirname $(readlink -f "$0"))

# choose config files
CFG_DIR="/opt/adp-conf/"
GET_ACTUAL_CFG_FILENAME() {
	local FILENAME=${CFG_DIR}$1
	[ -f ${FILENAME} ] && echo "${FILENAME}" || echo "${FILENAME}.default"
}

# read conf
DOMAINS_FOR_DPI_PROXY=$(cat $(GET_ACTUAL_CFG_FILENAME 'domains_for_dpi_proxy.txt') | sed -e '/^[[:space:]]*$/d' -e '/^#/d')
DOMAINS_FOR_EXT_PROXY=$(cat $(GET_ACTUAL_CFG_FILENAME 'domains_for_ext_proxy.txt') | sed -e '/^[[:space:]]*$/d' -e '/^#/d')

# prepare env-variables
export DNSMASQ_STR=$(echo -n "$DOMAINS_FOR_DPI_PROXY" | grep -v '/' | tr -d '\r' | tr '\n' '/')
export DPI_PROXY_DOMAINS_JS_LIST=$(echo -n "$DOMAINS_FOR_DPI_PROXY" | sed 's/\(.*\)/"\1",/g')
export EXT_PROXY_DOMAINS_JS_LIST=$(echo -n "$DOMAINS_FOR_EXT_PROXY" | sed 's/\(.*\)/"\1",/g')

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
		cp -f $(GET_ACTUAL_CFG_FILENAME 'domains_for_ext_proxy.txt') /opt/proxy-chain/domains_for_ext_proxy.txt
		;;
	"ssh-proxy")
		cp -f $(GET_ACTUAL_CFG_FILENAME 'ssh_proxy.conf') ~/.ssh/config
		cp -f ${CFG_DIR}.ssh/* ~/.ssh/
		ls -l ~/.ssh/
		;;
	*)
		echo "Nothing to do"
		;;
esac
