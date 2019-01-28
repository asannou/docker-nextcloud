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

if occ status | grep -q '\- installed: true'
then
  occ upgrade --no-interaction
  occ db:add-missing-indices
  occ db:convert-filecache-bigint
  occ config:system:set trusted_proxies 0 --value=172.16.0.0/12
  occ config:system:set skeletondirectory
  occ config:system:set enable_previews --type=boolean --value=false
fi

exec "$@"
