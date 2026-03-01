#!/bin/sh

# sync users
[ -f /root/external-etc/passwd ] && cp -f /root/external-etc/passwd /etc/passwd
[ -f /root/external-etc/shadow ] && cp -f /root/external-etc/shadow /etc/shadow

KEY_FILES_MASK='ssh_host_*_key*'
if [ -z "$(ls /root/external-etc/ssh/${KEY_FILES_MASK} 2>/dev/null)" ]; then
	echo "(!) Server key-files not found in external directory => create and copy new keys to external directory"
	rm /etc/ssh/${KEY_FILES_MASK}
	ssh-keygen -A
	cp /etc/ssh/${KEY_FILES_MASK} /root/external-etc/ssh/
else
	echo "Server key-files found in external directory => copy to current container"
	cp -f /root/external-etc/ssh/${KEY_FILES_MASK} /etc/ssh/
	chmod 600 /etc/ssh/${KEY_FILES_MASK}
	chmod 644 /etc/ssh/${KEY_FILES_MASK}.pub
fi

# run server
exec /usr/sbin/sshd -D "$@"
