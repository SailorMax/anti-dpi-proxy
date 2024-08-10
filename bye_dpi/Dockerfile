FROM alpine:latest AS builder
WORKDIR /app
RUN apk add make gcc musl-dev \
	&& wget -O app.zip https://codeload.github.com/hufrea/byedpi/zip/refs/heads/main \
	&& unzip app.zip \
	&& cd byedpi-main/ \
	&& make

FROM busybox:stable-musl
WORKDIR /
COPY --from=builder /lib/ld-musl-x86_64.so.1 /lib/ld-musl-x86_64.so.1
COPY --from=builder /app/byedpi-main/ciadpi .

ENTRYPOINT ["./ciadpi"]
