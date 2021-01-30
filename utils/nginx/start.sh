#!/usr/bin/env bash

systemctl stop httpd
systemctl disable httpd

systemctl enable nginx
systemctl restart nginx
