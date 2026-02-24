FROM alpine:latest
RUN apk add --update openssh shadow

COPY ./ssh-shared/home/setup_proxy_user.sh /home/
COPY ./ssh-shared/home/passwd_proxy_user.sh /home/

# Do we need it here or in entrypoint-script?
RUN ssh-keygen -A

ENTRYPOINT ["/usr/sbin/sshd", "-D"]
