#!/bin/sh

# < id_ed25519.pub
docker compose exec -T ssh-server /home/create_proxy_user.sh $1 <&0
