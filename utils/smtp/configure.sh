#!/usr/bin/env bash

/bin/cp smtpd.conf /etc/sasl2/
echo "$SMTP_PASSWORD" | saslpasswd2 -p -c -u "$SMTP_HOSTNAME" "$SMTP_USERNAME"

postconf -e 'inet_interfaces = loopback-only'
postconf -e 'smtpd_sasl_auth_enable = yes'
postconf -e 'smtpd_sasl_path = smtpd'
postconf -e 'cyrus_sasl_config_path = /etc/sasl2/'

postconf -e 'smtpd_use_tls = yes'
postconf -e 'smtp_tls_security_level = encrypt'

chgrp postfix /etc/sasldb2
