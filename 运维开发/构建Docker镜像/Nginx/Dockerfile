############################################################
# Dockerfile to build nginx container images
############################################################
FROM nginx

# 指定作者信息
# MAINTAINER alfred
LABEL maintainer="jusheng_yao@outlook.com"

ENV RUN_USER nginx

ENV RUN_GROUP nginx

ENV DATA_DIR /opt/web

ENV LOG_DIR /opt/log/nginx

RUN mkdir /opt/log/nginx -p

RUN chown nginx.nginx -R /opt/log/nginx

ADD web /opt/web

ADD nginx.conf /etc/nginx/nginx.conf

ADD default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

ENTRYPOINT nginx -g "daemon off;"
