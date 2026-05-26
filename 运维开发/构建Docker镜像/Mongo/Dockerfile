############################################################
# Dockerfile to build MongoDB container images
# Based on Ubuntu
############################################################
FROM ubuntu:20.04
# 指定作者信息
# MAINTAINER alfred
LABEL maintainer="jusheng_yao@outlook.com"

ENV TIME_ZONE Asia/Shanghai

RUN apt-get update

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10

RUN echo 'deb dist 10gen' | tee /etc/apt/sources.list.d/mongodb.list

RUN apt-get update  &&  apt-get install -y mongodb-10gen

RUN mkdir -p /data/mongodb

EXPOSE 27017

CMD ["--port 27017"]

ENTRYPOINT usr/bin/mongod
