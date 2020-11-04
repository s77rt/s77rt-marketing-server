#!/usr/bin/env bash

systemctl start mysqld
sleep 2
systemctl stop mysqld
sleep 2
mysqld --skip-grant-tables --user=mysql &
sleep 3
mysql -uroot -e "FLUSH PRIVILEGES;SET GLOBAL validate_password.policy=LOW;ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';DELETE FROM mysql.user WHERE User='';DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');DROP DATABASE IF EXISTS test;DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';FLUSH PRIVILEGES;DROP DATABASE IF EXISTS ${MW_DB_NAME};CREATE DATABASE ${MW_DB_NAME} /*\!40100 DEFAULT CHARACTER SET utf8 */;DROP USER IF EXISTS '${MW_DB_USERNAME}';DROP USER IF EXISTS '${MW_DB_USERNAME}'@'localhost';CREATE USER '${MW_DB_USERNAME}'@'localhost' IDENTIFIED BY '${MW_DB_PASSWORD}';GRANT ALL PRIVILEGES ON ${MW_DB_NAME}.* TO '${MW_DB_USERNAME}'@'localhost';FLUSH PRIVILEGES;"
pkill -u mysql
sleep 2
systemctl start mysqld
sleep 2
