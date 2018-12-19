#!/bin/sh

set -e

CONFIG=/volume/config.php
DATA=/volume/data
UPLOADTMP=/volume/tmp

cron

test -e $CONFIG || cp /root/config.php $CONFIG
test -e $DATA || mkdir $DATA
test -e $UPLOADTMP || mkdir $UPLOADTMP
chown www-data:root $CONFIG $DATA $UPLOADTMP

ln -snf $CONFIG /var/www/nextcloud/config/
ln -snf $DATA /var/www/nextcloud/

occ() {
  args="$@"
  su - -s /bin/sh -c "/usr/local/bin/php /var/www/nextcloud/occ $args" www-data
}

occ status | grep -q '\- installed: true' && occ upgrade --no-app-disable --no-interaction
exec "$@"
