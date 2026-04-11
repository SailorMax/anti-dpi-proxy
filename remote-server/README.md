# SSH-server:
1. `adduser admin-username sudo` and test it (optionally put in /etc/sudoers.d/username string 'username ALL=(ALL) NOPASSWD: ALL')
2. setup 'PermitRootLogin no' in /etc/ssh/sshd_config
3. `apt install fail2ban docker.io docker-compose`
4. `docker compose up`

## Setup client:
1. create keys: conf/.ssh/keygen.sh
2. setup client user on server: `docker compose exec -it ssh-server /home/create_proxy_user.sh username < id_ed25519.pub`
3. setup socks5://ssh-proxy:1080 in conf/ext_proxies.txt

manual test:
1. run proxy: `ssh -vvv -D 0.0.0.0:1081 -N -C -i ./id_ed25519 username@127.0.0.1 -p 443`
2. use proxy: `curl -v -x socks5://127.0.0.1:1081 'https://checkip.amazonaws.com'`


# MTProto-server:
1. start the server
2. register it with telegram bot: https://t.me/mtproxybot
3. set received secret in the Telegram client
4. setup received tag into local .env-file as MTPROTO_TAG


### hints
to access to server by certificate: 
- `cat ~/my-certificate.pub >> ~/.ssh/authorized_keys`

create optimal secure keys:
- `ssh-keygen -t ed25519 -b 256` [-f ./id_ed25519]
- `ssh-keygen -t rsa -b 4096` [-f ./id_rsa4096]

monitor programs:
- `htop`
- `glances`
- `btop`
