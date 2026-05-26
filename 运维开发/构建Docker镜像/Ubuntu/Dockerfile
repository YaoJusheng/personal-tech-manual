################################################################################################################
# Desc:    python3 base on ubuntu:20.04
#          构建镜像: alpine、slim、slim-buster、buster
# Author:  Jusheng Yao
# Usage:
#   Build:   docker build -t ubuntu:20.04 .
#   Run:     docker run -itd --name ubuntu20.04 --restart always --privileged=true /usr/sbin/init
#   Enter:   docker exec -it ubuntu20.04 /bin/bash
################################################################################################################
FROM ubuntu:20.04

# MAINTAINER yaojusheng
LABEL maintainer="jusheng_yao@outlook.com"

ARG user
ARG pwd

# 改变用户的UID和GID
# RUN usermod -u 1000 ${user} && usermod -G 1000 ${user}
# 指定容器起来的登录用户
USER ${user}

# 设置工作目录
WORKDIR /opt
ENV TZ=Asia/Shanghai \
    DEBIAN_FRONTEND=noninteractive

COPY requirements.txt /opt

#RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list

RUN apt-get clean &&  apt update -y && apt upgrade -y
RUN apt install -y build-essential zlib1g-dev libbz2-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev wget
RUN apt install -y vim iotop unzip zip make tcpdump telnet traceroute lrzsz tree curl iputils-ping net-tools
RUN apt install -y iproute2  ntpdate  nfs-kernel-server nfs-common openssl libpcre3 libpcre3-dev gcc openssh-server

RUN apt-get update -y && apt-get upgrade -y && apt-get clean && apt-get autoclean
RUN apt-get install -y apt-utils tzdata \
    && ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone

RUN apt-get install -y locales
RUN locale-gen zh_CN  && locale-gen zh_CN.utf8
ENV LC_ALL=zh_CN.UTF-8 LANGUAGE=zh_CN.UTF-8

RUN apt-get install -y libmysqlclient-dev python3-dev libpython3-dev python3-pip

RUN apt update
RUN apt-get install -y gcc make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev

# 安装依赖
RUN apt-get update && apt-get install -y sudo passwd adduser
RUN apt-get install openssh-client openssh-server -y

# 添加用户：赋予sudo权限，指定密码
RUN useradd --create-home --no-log-init --shell /bin/bash ${user} \
    && adduser ${user} sudo \
    && echo "${user}:${pwd}" | chpasswd
# generate rsa
RUN rm -f /etc/ssh/ssh_host_rsa_key && ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N ""
RUN rm -f /etc/ssh/ssh_host_ecdsa_key && ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ""
RUN rm -f /etc/ssh/ssh_host_dsa_key && ssh-keygen -q -t dsa -f /etc/ssh/ssh_host_dsa_key -N ""
RUN rm -f /etc/ssh/ssh_host_ed25519_key && ssh-keygen -q -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""

# modify ssh configuration
RUN sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config \
  && sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config \
  && sed -i 's/#UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g' /etc/ssh/sshd_config
RUN echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config \
  && echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

# 手动安装: 3.6.8
# RUN wget https://www.python.org/ftp/python/3.6.8/Python-3.6.8.tgz
# RUN tar -xzf Python-3.6.8.tgz

# RUN cd Python-3.6.8 && ./configure --enable-optimizations --prefix=/usr/local/bin/python3.6 && make && make install

# RUN ln -s -f /usr/local/bin/python3.6/bin/python3.6 /usr/bin/python3.6
# RUN ln -s -f /usr/local/bin/python3.6/bin/pip3.6 /usr/bin/pip3.6
# RUN ln -s -f /usr/bin/pip3.6 /usr/bin/pip3
# RUN ln -s -f /usr/bin/python3.6 /usr/bin/python3

# RUN cp /usr/lib/python3/dist-packages/lsb_release.py /usr/local/lib/python3.6/

# 自动安装: 3.6
RUN apt update
RUN apt-get install -y software-properties-common  && add-apt-repository ppa:deadsnakes/ppa
RUN apt update && apt install -y python3.6

# 优先级修改
RUN update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1

RUN apt-get install -y nodejs npm && npm config set registry https://registry.npm.taobao.org --global \
    && npm config set disturl https://npm.taobao.org/dist --global \
    && npm install pm2 -g

# RUN python3 -m ensurepip
RUN python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel --index-url https://mirrors.aliyun.com/pypi/simple/

RUN pip3 config set global.index-url http://mirrors.aliyun.com/pypi/simple \
    && pip3 config set install.trusted-host mirrors.aliyun.com

# 安装依赖
RUN apt install -y dos2unix
RUN dos2unix /opt/requirements.txt
# 方法1
#RUN pip3 install -Ur /opt/requirements.txt
# 方法2 - 不中断执行 (bat脚本)
# RUN FOR /F "delims=~" %f in (/opt/requirements.txt) DO pip3 install --no-cache-dir -U "%f"
#RUN FOR /F "delims=~" %f in (/opt/requirements.txt) DO conda install --yes "%f"
# 方法3 - 不中断执行
RUN while read var; do [[ $var =~ ^#.* || $var == "" ]] && continue || pip3 install --no-cache-dir -U $var; done < /opt/requirements.txt
#RUN while read var; do [[ $var =~ ^#.* || $var == "" ]] && continue || conda install --yes $var; done < /opt/requirements.txt

RUN apt-get clean autoclean -y

EXPOSE 22 80 443 8080
