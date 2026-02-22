#!/bin/sh

# sync users
[ -f /root/external/passwd ] && cp -f /root/external/passwd /etc/passwd
[ -f /root/external/shadow ] && cp -f /root/external/shadow /etc/shadow

# run server
exec /usr/sbin/sshd -D "$@"
