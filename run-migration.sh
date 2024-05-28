#!/bin/sh
set -e

cd /var/www/html/ && php artisan config:cache && php artisan view:cache && php artisan migrate
apache2ctl -D FOREGROUND
