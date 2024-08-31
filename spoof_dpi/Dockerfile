FROM golang:alpine AS builder
WORKDIR /go
RUN go install github.com/xvzc/SpoofDPI/cmd/spoofdpi@latest \
	&& apk update && apk add ca-certificates

FROM busybox:stable-musl
WORKDIR /
COPY --from=builder /go/bin/spoofdpi .
COPY --from=builder /etc/ssl/certs /etc/ssl/certs

ENTRYPOINT ["./spoofdpi"]
