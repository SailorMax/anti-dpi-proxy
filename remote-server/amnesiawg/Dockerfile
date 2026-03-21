# based on  https://github.com/amnezia-vpn/amneziawg-go
FROM golang:1.24.4 as awg
RUN apt update && apt install ca-certificates \
	&& go install -ldflags '-linkmode external -extldflags "-fno-PIC -static"' -v github.com/amnezia-vpn/amneziawg-go@latest

FROM alpine:3.19
ARG AWGTOOLS_RELEASE="1.0.20250901"

RUN apk --no-cache add iproute2 iptables bash \
    && cd /usr/bin/ \
    && wget https://github.com/amnezia-vpn/amneziawg-tools/releases/download/v${AWGTOOLS_RELEASE}/alpine-3.19-amneziawg-tools.zip \
    && unzip -j alpine-3.19-amneziawg-tools.zip \
    && chmod +x /usr/bin/awg /usr/bin/awg-quick \
    && ln -s /usr/bin/awg /usr/bin/wg \
    && ln -s /usr/bin/awg-quick /usr/bin/wg-quick
COPY --from=awg /go/bin/amneziawg-go /usr/bin/amneziawg-go

ENTRYPOINT ["/usr/bin/amneziawg-go", "-f", "wg0"]
