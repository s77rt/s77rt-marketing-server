#!/usr/bin/env bash

wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
chmod +x mariadb_repo_setup
./mariadb_repo_setup

yum install MariaDB-server -y
