FROM golang:alpine AS builder
WORKDIR /go

# use http for compatibility with WSL (OpenSSL >=3.4) [we can't reduce base image here, because of required go version for spoofdpi]
RUN sed -i 's|https://|http://|g' /etc/apk/repositories \
    && apk update && apk add ca-certificates \
	&& go install -ldflags '-w -s -extldflags "-static"' -v -tags timetzdata github.com/xvzc/spoofdpi/cmd/spoofdpi@latest

FROM busybox:stable-musl
WORKDIR /
COPY --from=builder /go/bin/spoofdpi .
COPY --from=builder /etc/ssl/certs /etc/ssl/certs
RUN ln -s /etc/ssl/certs/ca-certificates.crt /etc/ssl/cert.pem

ENTRYPOINT ["./spoofdpi"]
