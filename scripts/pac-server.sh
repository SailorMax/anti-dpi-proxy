#!/bin/sh
SCRIPT_DIR=$(dirname $(readlink -f "$0"))

$SCRIPT_DIR/prepare_configs.sh pac

# run server
exec /bin/httpd -f -p 8082 -h /var/www/static -u www-data $*
