#!/bin/sh

if [ "$#" -eq 0 ]; then
	echo "Require 1 argument: username"
	exit 1
fi

passwd $1

EXT_SHADOW_PATH="/root/external/shadow"
mv -f ${EXT_SHADOW_PATH} ${EXT_SHADOW_PATH}.prev
cp /etc/shadow ${EXT_SHADOW_PATH}

echo "done."
