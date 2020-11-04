#!/usr/bin/env bash

mkdir -p /etc/yum.repos.d/
cp nginx.repo /etc/yum.repos.d/
yum install nginx -y
