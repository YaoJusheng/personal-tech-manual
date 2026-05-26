############################################################
# Dockerfile to build Redis container images
############################################################
FROM redis

# MAINTAINER xxx@xxx.com
LABEL maintainer="jusheng_yao@outlook.com"

COPY redis.conf /usr/local/etc/redis/redis.conf

EXPOSE 6379

CMD [ "redis-server", "/usr/local/etc/redis/redis.conf"]

# 构建镜像
# docker build -t redis:latest .
