############################################################
# Dockerfile to build MySQL container images
############################################################
FROM mysql:8.0.18

LABEL maintainer="jusheng_yao@outlook.com"

#设置免密登录
ENV MYSQL_ALLOW_EMPTY_PASSWORD yes

#将所需文件放到容器中
COPY setup.sh /mysql/setup.sh
COPY schema.sql /mysql/schema.sql
COPY privileges.sql /mysql/privileges.sql

#设置容器启动时执行的命令
CMD ["sh", "/mysql/setup.sh"]

# 创建镜像
# docker build . -t docker-mysql
