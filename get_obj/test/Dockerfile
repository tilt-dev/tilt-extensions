FROM node:18-alpine
WORKDIR /app

COPY ./app/ ./
RUN npm ci

CMD [ "node", "index.js" ]