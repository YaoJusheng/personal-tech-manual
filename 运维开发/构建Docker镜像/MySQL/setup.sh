#!/bin/bash
set -e

#查看mysql服务的状态，方便调试，这条语句可以删除
service mysql status

echo '1.启动mysql...'
#启动mysql
service mysql start
sleep 3
service mysql status

echo '2.开始导入数据...'
#导入数据
mysql < /mysql/schema.sql
echo '3.导入数据完毕...'

sleep 3
service mysql status

#重新设置mysql密码
echo '4.开始设置用户名密码...'
mysql < /mysql/privileges.sql
echo '5.用户密码设置成功...'

#sleep 3
service mysql status
echo '6.mysql容器启动完毕,且数据导入成功.'

tail -f /dev/null
