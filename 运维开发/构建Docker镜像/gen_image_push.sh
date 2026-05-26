#!/bin/bash
echo ' ================ 开始构建 python3.8-demo image. ================'

# shellcheck disable=SC2046
cd $(dirname "$0") || exit
dir=$(pwd)
echo " 目录：$dir"

if [ ! "$1" ]; then
  section="testing"
else
  section=$1
fi

if [ ! "$2" ]; then
  version="default"
else
  version=$2
fi

image_name="python3.8-demo:$section-$version"
echo " ############################################################"
echo " # docker execute process version($section-$version)..."
echo " ############################################################"
gen_result=$(docker build -f Dockerfile --target "$section" --tag "$image_name" .)

# shellcheck disable=SC2181
if [ $? -ne 0 ]; then
  echo "$gen_result"
  echo " 构建 python3.8-demo image faided."
else
  echo "$gen_result"
  echo " 构建 python3.8-demo image successfully."

  echo " ############################################################"
  echo " # push python3.8-demo image process ..."
  echo " ############################################################"

  # shellcheck disable=SC2002
  # registry=$(cat /root/.docker/config.json | grep registry.cn-hangzhou.aliyuncs.com)
  registry=$(cat ~/.docker/config.json | grep registry.cn-hangzhou.aliyuncs.com)  # mac

  if [ ! "$registry" ]; then
    docker login --username=alfred001_yao registry.cn-hangzhou.aliyuncs.com
    status=$?
  else
    status=0
  fi
  # shellcheck disable=SC2181
  if [ $status -eq 0 ]; then
    echo " 登录成功！准备推送..."
    tagVer="registry.cn-hangzhou.aliyuncs.com/python-test/python3.8-scripts-demo:$section-$version"
    docker tag "$image_name" "$tagVer"
    docker push "$tagVer"
    echo " ############################################################"

    # shellcheck disable=SC2320
    if [ $? -ne 0 ]; then
      echo " 镜像版本 $image_name push failed."
    else
      echo " 镜像版本 $image_name push successfully."
    fi
  else
    echo " 登录失败，无法推送！"
  fi
fi
# [执行-example]：
# 执行脚本 镜像版本
# bash ./gen_image_push.sh testing 2.0
