################################################################################################################
# Desc:    python3 base on centos7
# Author:  Jusheng Yao
# Usage:
#   Build:   docker build -t centos7 .
#   Run:     docker run -itd --name centos7 --restart always --privileged=true /usr/sbin/init
#   Enter:   docker exec -it centos7 /bin/bash
################################################################################################################
FROM centos:7.6.1810
# 指定作者信息
# MAINTAINER alfred
LABEL maintainer="jusheng_yao@outlook.com"

ENV TIME_ZONE Asia/Shanghai

# 设置工作目录
WORKDIR /home

ARG user
ARG pwd

# install sshd ...
RUN yum install -q -y openssh openssh-askpass openssh-server openssh-clients net-tools vim ntpdate supervisor \
  && yum -y passwd sudo \
  && yum clean all

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

RUN adduser ${user} && /bin/echo "${user}:${pwd}" | chpasswd
RUN echo "$user ALL=(ALL:ALL) ALL" >> /etc/sudoers
RUN ntpdate cn.ntp.org.cn
RUN chkconfig sshd on

COPY requirements.txt /opt
#ADD .  /opt/project/

RUN set -ex \
  # 预安装所需组件
  && yum install -y wget tar libffi-devel zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gcc make initscripts \
  && wget https://www.python.org/ftp/python/3.8.10/Python-3.8.10.tgz \
  && tar -zxvf Python-3.8.10.tgz \
  && cd Python-3.8.10 \
  && ./configure prefix=/usr/local/python3 \
  && make \
  && make install \
  && make clean \
  && rm -rf /Python-3.8.10* \
  && yum install -y epel-release \
  && yum install -y python3-pip
# 设置默认为python3
RUN set -ex \
  # 备份旧版本python
  # && mv /usr/bin/python /usr/bin/python27 \
  # && mv /usr/bin/pip /usr/bin/pip27 \
  # 配置默认为python3
  && ln -s /usr/local/python3/bin/python3.8 /usr/bin/python3 \
  && ln -s /usr/local/python3/bin/pip3 /usr/bin/pip3
# 修复因修改python版本导致yum失效问题
RUN set -ex \
  && sed -i "s#/usr/bin/python#/usr/bin/python2.7#" /usr/bin/yum \
  && sed -i "s#/usr/bin/python#/usr/bin/python2.7#" /usr/libexec/urlgrabber-ext-down \
  && yum install -y deltarpm
# 基础环境配置
RUN set -ex \
  # 修改系统时区为东八区
  && rm -rf /etc/localtime \
  && ln -s /usr/share/zoneinfo/$TIME_ZONE /etc/localtime \
  && yum install -y vim \
  # 安装定时任务组件
  && yum -y install cronie

# install nodejs npm (clean: rm -fv /etc/yum.repos.d/nodesource*)
#RUN curl -sL https://raw.github.com/creationix/nvm/master/install.sh | bash -
#RUN nvm install stable
RUN rm -fv /etc/yum.repos.d/nodesource*
RUN curl -sL https://rpm.nodesource.com/setup_16.x | bash -
RUN yum install -y epel-release deltarpm nodejs
RUN npm config set registry https://registry.npm.taobao.org --global && \
    npm config set disturl https://npm.taobao.org/dist --global
RUN npm install -g pm2

# 支持中文
RUN yum install kde-l10n-Chinese -y
RUN localedef -c -f UTF-8 -i zh_CN zh_CN.utf8
ENV LC_ALL zh_CN.UTF-8

# 更新pip版本
RUN pip3 config set global.index-url http://mirrors.aliyun.com/pypi/simple \
    && pip3 config set install.trusted-host mirrors.aliyun.com
RUN pip3 install --upgrade pip

# 安装依赖
RUN yum install -y dos2unix
RUN dos2unix /opt/requirements.txt
# 方法1
#RUN pip3 install -Ur /opt/requirements.txt
# 方法2 - 不中断执行 (bat脚本)
# RUN FOR /F "delims=~" %f in (/opt/requirements.txt) DO pip3 install --no-cache-dir -U "%f"
#RUN FOR /F "delims=~" %f in (/opt/requirements.txt) DO conda install --yes "%f"
# 方法3 - 不中断执行
RUN while read var; do [[ $var =~ ^#.* || $var == "" ]] && continue || pip3 install --no-cache-dir -U $var; done < /opt/requirements.txt
#RUN while read var; do [[ $var =~ ^#.* || $var == "" ]] && continue || conda install --yes $var; done < /opt/requirements.txt

# CMD ["pm2", "start", "server.py", "--no-daemon", "-x", "--interpreter", "python3"]

USER ${user}

EXPOSE 22 80 443 8000
