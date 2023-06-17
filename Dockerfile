FROM node:17-alpine AS build
RUN apk add --no-cache python3 g++ make
RUN ln -s /usr/bin/python3 /usr/bin/python
WORKDIR /build/
COPY package* ./
RUN npm install
COPY . .
RUN npm run build

RUN if [[ ! -e revcord.sqlite ]]; then touch revcord.sqlite; fi
RUN if [[ -e revcord.sqlite ]]; then chmod -R 777 revcord.sqlite; fi

FROM node:17-alpine AS prod
WORKDIR /app
COPY --from=build /build .
RUN if [[ ! -e revcord.sqlite ]]; then touch revcord.sqlite; fi
RUN if [[ -e revcord.sqlite ]]; then chmod -R 777 revcord.sqlite; fi
RUN timeout 20 npm start
RUN npm stop

RUN npm install sqlite3 dotenv
RUN rm -rf node_modules
CMD ["npm", "start"]
