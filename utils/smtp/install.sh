#!/usr/bin/env bash

yum remove sendmail -y
yum install opensmtpd postfix cyrus-sasl cyrus-sasl-plain -y
