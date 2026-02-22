FROM alpine:latest
RUN apk add --update openssh

COPY ./container/home/create_proxy_user.sh /home/

# Do we need it here or in entrypoint-script?
RUN ssh-keygen -A

ENTRYPOINT ["/usr/sbin/sshd", "-D"]
