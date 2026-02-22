FROM node:alpine
RUN apk add --update openssh

ENTRYPOINT "ssh -D 0.0.0.0:1081 -N -C -i ~/.ssh/id_ed25519"
