############################################################
# Dockerfile to build python3.8 container images
############################################################
FROM python:3.8-slim-buster AS common_python

LABEL maintainer="jusheng_yao@outlook.com"

#把项目压缩包复制过去 自动解压
ADD service_app.tar.gz /opt/project

#工作目录 启动这个镜像的容器初始目录
WORKDIR /opt/project/service_app

RUN python3 -m pip install --upgrade pip \
  && pip3 config set global.index-url http://mirrors.aliyun.com/pypi/simple \
  && pip3 config set install.trusted-host mirrors.aliyun.com

RUN pip3 install -Ur requirements.txt -i https://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com

# 开放端口 80
EXPOSE 80 8000 8080

#容器启动运行app
CMD ["python3", "server.py", "runserver", "0.0.0.0:80"]
# CMD ["gunicorn","-b", "0.0.0.

################################################################
# Dockerfile to build Python3.8 container images base on alpine
################################################################
#--platform可以用于指定镜像的平台，linux/amd64、linux/arm64 或 windows/amd64
#FROM --platform=linux/arm64 python:3.8
FROM python:3.8-alpine AS alpine_python

LABEL maintainer="jusheng_yao@outlook.com"

#把项目压缩包复制过去 自动解压
ADD ./requirements.txt /opt/project/python_all_scripts/

#工作目录 启动这个镜像的容器初始目录
WORKDIR /opt/project/python_all_scripts

#使用sed工具将字符串dl-cdn.alpinelinux.org替换为mirrors.aliyun.com
#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories

#RUN echo "https://mirrors.ustc.edu.cn/alpine/latest-stable/main" >> /etc/apk/repositories
#RUN echo "https://mirrors.ustc.edu.cn/alpine/latest-stable/community" >> /etc/apk/repositories
#RUN echo "https://mirrors.ustc.edu.cn/alpine/v3.15/main" >> /etc/apk/repositories
RUN echo "https://mirrors.ustc.edu.cn/alpine/v3.15/community" >> /etc/apk/repositories

RUN apk update \
  && apk add --no-cache gcc g++ musl-dev libressl-dev python3-dev linux-headers libffi-dev openssl-dev

RUN apk --no-cache add curl bash bash-doc bash-completion py3-numpy

# 修改时区
RUN apk update \
    && apk add tzdata \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone

RUN python3 -m pip install --upgrade pip setuptools \
  && pip3 config set global.index-url http://mirrors.aliyun.com/pypi/simple \
  && pip3 config set install.trusted-host mirrors.aliyun.com

# 安装依赖
RUN apk --no-cache add dos2unix
RUN dos2unix requirements.txt
# 方法1
#RUN pip3 install --no-cache-dir -Ur requirements.txt -i https://mirrors.aliyun.com/pypi/simple/
# 方法2 - 不中断执行 (bat脚本)
RUN FOR /F "delims=~" %f in (requirements.txt) DO pip3 install --no-cache-dir -U "%f"
#RUN FOR /F "delims=~" %f in (requirements.txt) DO conda install --yes "%f"
# 方法3 - 不中断执行
#RUN while read requirement; do pip3 install --no-cache-dir -U $requirement; done < requirements.txt
#RUN while read requirement; do conda install --yes $requirement; done < requirements.txt

RUN chmod +x bin/*

# 开放端口 80
EXPOSE 80 8000 8080

################################################################
# Dockerfile to build default Python3.8 container images base on alpine
################################################################
#--platform可以用于指定镜像的平台，linux/amd64、linux/arm64 或 windows/amd64
#FROM --platform=linux/arm64 python:3.8
FROM python:3.8-alpine AS default

LABEL maintainer="jusheng_yao@outlook.com"


#工作目录 启动这个镜像的容器初始目录
WORKDIR /home

#使用sed工具将字符串dl-cdn.alpinelinux.org替换为mirrors.aliyun.com
#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories

#RUN echo "https://mirrors.ustc.edu.cn/alpine/latest-stable/main" >> /etc/apk/repositories
RUN echo "https://mirrors.ustc.edu.cn/alpine/v3.15/community" >> /etc/apk/repositories

RUN apk update \
  && apk add --no-cache gcc g++ musl-dev libressl-dev python3-dev linux-headers libffi-dev openssl-dev

RUN apk --no-cache add curl bash bash-doc bash-completion py3-numpy

# 修改时区
RUN apk update \
    && apk add tzdata \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone

RUN python3 -m pip install --upgrade pip setuptools \
  && pip3 config set global.index-url http://mirrors.aliyun.com/pypi/simple \
  && pip3 config set install.trusted-host mirrors.aliyun.com

# 安装依赖
RUN apk --no-cache add dos2unix

RUN pip3 install --no-cache-dir -U gunicorn glances ipython jupyter requests termcolor pipreqs nb_log

# 开放端口 80
EXPOSE 80 443

#容器启动运行app
#CMD ["python3", "server.py", "runserver", "0.0.0.0:80"]
# CMD ["gunicorn","-b", "0.0.0.0:8000", "-w", "4", "-k", "gevent", "--worker-tmp-dir", "/opt/project/service_app", "server:app"]
