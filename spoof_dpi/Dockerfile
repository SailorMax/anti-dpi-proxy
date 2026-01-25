FROM golang:alpine AS builder
WORKDIR /go

# sometimes image has not required certificates :/ => use http
RUN sed -i 's|https://|http://|g' /etc/apk/repositories \
	&& apk update && apk add ca-certificates \
	&& go install -ldflags '-w -s -extldflags "-static"' -tags timetzdata github.com/xvzc/SpoofDPI/cmd/spoofdpi@latest

FROM busybox:stable-musl
WORKDIR /
COPY --from=builder /go/bin/spoofdpi .
COPY --from=builder /etc/ssl/certs /etc/ssl/certs
RUN ln -s /etc/ssl/certs/ca-certificates.crt /etc/ssl/cert.pem

ENTRYPOINT ["./spoofdpi"]
