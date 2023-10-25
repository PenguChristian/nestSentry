FROM node:18-alpine3.18 As development

WORKDIR /usr/src/app

COPY . .
RUN yarn

CMD ["yarn", "start:dev"]

# ##################################### build
FROM node:18-alpine3.18 As build

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./
COPY --chown=node:node --from=development /usr/src/app/node_modules ./node_modules
COPY --chown=node:node . .

RUN yarn run build

ENV NODE_ENV production

USER node

# ##################################### testing
FROM node:18-alpine3.18 As testing

USER node
WORKDIR /usr/src/app/dist

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./
COPY --chown=node:node .env ./.env

CMD [ "node", "main.js" ]

# ##################################### production
FROM node:18-alpine3.18 As production

USER node
WORKDIR /usr/src/app/dist

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./
COPY --chown=node:node .env ./.env

CMD [ "node", "main.js" ]
