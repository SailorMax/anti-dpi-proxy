FROM node:25-alpine

WORKDIR /opt/proxy-chain
COPY /app/ /opt/proxy-chain/
RUN npm install -C ./ --production --no-optional

CMD ["node", "/opt/proxy-chain/server.js"]
