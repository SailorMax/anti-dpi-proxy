#!/bin/sh
SCRIPT_DIR=$(dirname $(readlink -f "$0"))

# read conf
DISPUTED_DOMAINS=$(cat /opt/adp-conf/disputed_domains.txt | sed -e '/^[[:space:]]*$/d' -e '/^#/d')
DISPUTED_IPS=$(cat /opt/adp-conf/disputed_ips.txt | sed -e '/^[[:space:]]*$/d' -e '/^#/d')
EXT_PROXY_WHITELIST=$([ -f '/opt/adp-conf/ext_proxy_whitelist.txt' ] && cat /opt/adp-conf/ext_proxy_whitelist.txt | sed -e '/^[[:space:]]*$/d' -e '/^#/d')

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
      ( echo "cat <<EOF" ; cat /opt/adp-conf/dnsproxy.yaml.tpl ; echo EOF ) | sh > /opt/dnsproxy/config.yaml
      ;;
   *)
     echo "Nothing to do"
     ;;
esac
