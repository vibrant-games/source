FROM node:16.5.0-alpine3.13

WORKDIR /opt/node/bin

COPY source/* /opt/node/bin/
COPY config/* /opt/node/config/

RUN npm ci
RUN npm audit

EXPOSE 8081

ENTRYPOINT node /opt/node/bin/index.js
