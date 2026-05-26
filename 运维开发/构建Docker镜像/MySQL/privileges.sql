USE mysql;
-- 因为mysql版本是5.7，因此新建用户为如下命令：
CREATE USER 'docker'@'localhost' IDENTIFIED BY '123456';
CREATE USER 'root'@'%' IDENTIFIED BY '123456';
-- 将docker_mysql数据库的权限授权给创建的docker用户，密码为123456：
GRANT ALL ON docker_mysql.* TO 'docker'@'localhost' IDENTIFIED BY '123456' WITH GRANT OPTION;
GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '123456' WITH GRANT OPTION;
-- 这一条命令一定要有：
FLUSH PRIVILEGES;
