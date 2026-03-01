#!/bin/sh

# < id_ed25519.pub
docker compose exec -T ssh-server sh /home/setup_proxy_user.sh $1 <&0
