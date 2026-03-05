#!/bin/sh

if [ "$#" -eq 0 ]; then
	echo "Require 1 argument: username"
	echo "(optional) and public certificate in stdin"
	exit 1
fi

USER_HOME_DIR="/home/$1"

echo -n "Creating user $1... "
#useradd --shell=/bin/true $1
adduser -D -s /bin/true $1 users
usermod -p '*' $1
echo "ok"

echo -n "Creating home directory... "
[ -d $USER_HOME_DIR/.ssh/ ] || mkdir -p ${USER_HOME_DIR}/.ssh/
chown $1:users ${USER_HOME_DIR}/.ssh
chmod 500 ${USER_HOME_DIR}/.ssh
echo "ok"

echo -n "Creating ~/.ssh/authorized_keys... "
touch ${USER_HOME_DIR}/.ssh/authorized_keys
chown $1:users ${USER_HOME_DIR}/.ssh/authorized_keys
chmod 400 ${USER_HOME_DIR}/.ssh/authorized_keys
echo "ok"

if read -t 0; then
	echo -n "Fill ~/.ssh/authorized_keys... "
	cp /dev/stdin ${USER_HOME_DIR}/.ssh/authorized_keys
	echo "ok"
else
	echo "Stdin is empty => ~/.ssh/authorized_keys is empty."
fi

EXT_PASSWD_PATH="/root/external-etc/passwd"
EXT_SHADOW_PATH="/root/external-etc/shadow"
mv -f ${EXT_PASSWD_PATH} ${EXT_PASSWD_PATH}.prev
cp /etc/passwd ${EXT_PASSWD_PATH}
mv -f ${EXT_SHADOW_PATH} ${EXT_SHADOW_PATH}.prev
cp /etc/shadow ${EXT_SHADOW_PATH}

echo "(!) hint: to setup password, run '/home/passwd_proxy_user.sh $1' in the container."
echo "done."
