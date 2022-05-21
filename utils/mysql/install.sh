#!/usr/bin/env bash

rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
yum install mysql-server -y
