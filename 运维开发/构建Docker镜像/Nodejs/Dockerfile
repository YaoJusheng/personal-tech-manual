####################################################
# create node container image for development env
####################################################
FROM node:14.16-alpine As development

MAINTAINER yaojusheng
LABEL maintainer="jusheng_yao@outlook.com"

WORKDIR /usr/src/project

COPY package*.json ./

RUN apk --update add git && apk --update add curl

RUN npm config set sass_binary_site=https://npm.taobao.org/mirrors/node-sass

RUN npm install --only=development

RUN rm -rf /tmp/* /var/cache/apk/* \
    && npm install \
    && npm install -g pm2

COPY . .

#CMD ["npm", "run", "build"]

####################################################
# create node container image for production env
####################################################
FROM node:14.16-alpine as production

MAINTAINER yaojusheng
LABEL maintainer="jusheng_yao@outlook.com"

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

WORKDIR /usr/src/project

COPY package*.json ./

RUN apk --update add git && apk --update add curl

RUN npm config set sass_binary_site=https://npm.taobao.org/mirrors/node-sass

RUN npm install --only=production

RUN rm -rf /tmp/* /var/cache/apk/* \
    && npm install \
    && npm install -g pm2

COPY --from=development /usr/src/project/ .

#CMD ["node", "dist/main"]
