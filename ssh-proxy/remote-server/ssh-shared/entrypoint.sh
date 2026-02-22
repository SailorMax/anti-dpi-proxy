#!/bin/sh

# sync users
cp -f /root/external/passwd /etc/passwd
cp -f /root/external/shadow /etc/shadow

# run server
exec /usr/sbin/sshd -D "$@"
