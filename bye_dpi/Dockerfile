FROM alpine:latest AS builder
WORKDIR /app
RUN apk add make gcc musl-dev linux-headers \
	&& wget -O app.zip https://codeload.github.com/hufrea/byedpi/zip/refs/heads/main \
	&& unzip app.zip \
	&& cd byedpi-main/ \
	&& make

#FROM alpine:latest
FROM busybox:stable-musl
WORKDIR /
COPY --from=builder /lib/ld-musl-* /lib/
COPY --from=builder /app/byedpi-main/ciadpi .

ENTRYPOINT ["./ciadpi"]
