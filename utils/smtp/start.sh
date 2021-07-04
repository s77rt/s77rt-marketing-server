#!/usr/bin/env bash

systemctl enable saslauthd
systemctl restart saslauthd

systemctl enable postfix
systemctl restart postfix
