#!/bin/sh

set -e

CONFIG=/volume/config.php
DATA=/volume/data

cron

test -e $CONFIG || cp /root/config.php $CONFIG
test -e $DATA || mkdir $DATA
chown www-data:root $CONFIG $DATA

ln -snf $CONFIG /var/www/nextcloud/config/
ln -snf $DATA /var/www/nextcloud/

exec "$@"
