#!/usr/bin/env bash

rm -rf mailwizz.zip mailwizz-* mailwizz
curl -s -X GET -H "X-LICENSEKEY: $MW_L_PURCHASE_CODE" https://www.mailwizz.com/api/download/version/latest -o mailwizz.zip
unzip -qq mailwizz.zip
mv mailwizz-* mailwizz
rm -rf /usr/share/nginx/html/*
cp -r mailwizz/latest/* /usr/share/nginx/html/
chmod +x /usr/share/nginx/html/apps/console/commands/shell/set-dir-perms
/usr/share/nginx/html/apps/console/commands/shell/set-dir-perms
python3 web_install.py
rm -rf /usr/share/nginx/html/install
/usr/share/nginx/html/apps/console/commands/shell/set-dir-perms
