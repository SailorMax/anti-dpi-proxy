FROM node:alpine3.21
WORKDIR /app
RUN wget -O app.zip https://codeload.github.com/hectorm/demergi/zip/refs/heads/master \
	&& unzip app.zip \
	&& mv demergi-master/* ./ \
	&& npm ci

ENTRYPOINT ["./bin/demergi.js"]
