#!/usr/bin/env bash

yum install epel-release yum-utils -y
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
rpm -Uvh http://repo.mysql.com/mysql-community-release-el7.rpm
