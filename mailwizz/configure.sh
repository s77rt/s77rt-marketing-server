#!/usr/bin/env bash

# Hooks
/bin/cp hooks/init-custom.php /usr/share/nginx/html/apps/
chown nginx:nginx /usr/share/nginx/html/apps/init-custom.php

# Cron
touch mwcron
echo "* * * * * /usr/bin/php -q /usr/share/nginx/html/apps/console/console.php send-campaigns >/dev/null 2>&1" >> mwcron
echo "* * * * * /usr/bin/php -q /usr/share/nginx/html/apps/console/console.php queue >/dev/null 2>&1" >> mwcron
echo "*/2 * * * * /usr/bin/php -q /usr/share/nginx/html/apps/console/console.php send-transactional-emails >/dev/null 2>&1" >> mwcron
echo "*/10 * * * * /usr/bin/php -q /usr/share/nginx/html/apps/console/console.php bounce-handler >/dev/null 2>&1" >> mwcron
echo "*/20 * * * * /usr/bin/php -q /usr/share/nginx/html/apps/console/console.php feedback-loop-handler >/dev/null 2>&1" >> mwcron
echo "*/3 * * * * /usr/bin/php -q /usr/share/nginx/html/apps/console/console.php process-delivery-and-bounce-log >/dev/null 2>&1" >> mwcron
echo "0 * * * * /usr/bin/php -q /usr/share/nginx/html/apps/console/console.php hourly >/dev/null 2>&1" >> mwcron
echo "0 0 * * * /usr/bin/php -q /usr/share/nginx/html/apps/console/console.php daily >/dev/null 2>&1" >> mwcron
crontab mwcron
rm -f mwcron

/usr/bin/php -q /usr/share/nginx/html/apps/console/console.php send-campaigns >/dev/null 2>&1
/usr/bin/php -q /usr/share/nginx/html/apps/console/console.php queue >/dev/null 2>&1
/usr/bin/php -q /usr/share/nginx/html/apps/console/console.php send-transactional-emails >/dev/null 2>&1
/usr/bin/php -q /usr/share/nginx/html/apps/console/console.php bounce-handler >/dev/null 2>&1
/usr/bin/php -q /usr/share/nginx/html/apps/console/console.php feedback-loop-handler >/dev/null 2>&1
/usr/bin/php -q /usr/share/nginx/html/apps/console/console.php process-delivery-and-bounce-log >/dev/null 2>&1
/usr/bin/php -q /usr/share/nginx/html/apps/console/console.php hourly >/dev/null 2>&1
/usr/bin/php -q /usr/share/nginx/html/apps/console/console.php daily >/dev/null 2>&1
