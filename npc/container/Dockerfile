FROM node:16.5.0-alpine3.13

WORKDIR /opt/node/bin

COPY source/* /opt/node/bin/
# No idea why this extra COPY is necessary:
COPY source/services /opt/node/bin/services/
COPY config/* /opt/node/config/

RUN npm ci
RUN npm audit

EXPOSE 8081

RUN echo "You must mount/bind /var/npcs/html"

ENTRYPOINT node /opt/node/bin/index.js
