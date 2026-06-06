FROM alpine:3.21
RUN apk add openssh shadow

COPY ./shared/home/setup_proxy_user.sh /home/
COPY ./shared/home/passwd_proxy_user.sh /home/

# Create in /etc/ssh/ ssh_host_*_key* files
RUN ssh-keygen -A

ENTRYPOINT ["/usr/sbin/sshd", "-D"]
