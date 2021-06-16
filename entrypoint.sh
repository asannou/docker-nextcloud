#!/bin/sh

set -e

CONFIG=/volume/config.php
DATA=/volume/data

test -e $CONFIG || cp /root/config.php $CONFIG
test -e $DATA || mkdir $DATA
chown www-data:root $CONFIG $DATA

ln -snf $CONFIG /var/www/nextcloud/config/
ln -snf $DATA /var/www/nextcloud/

occ() {
  args=$(printf "'%s' " "$@")
  su - -s /bin/sh -c "/usr/local/bin/php /var/www/nextcloud/occ $args" www-data
}

if occ status | grep -q '\- installed: true'
then
  occ upgrade --no-interaction
  occ db:add-missing-indices
  occ db:add-missing-columns
  occ db:add-missing-primary-keys
  occ db:convert-filecache-bigint --no-interaction
  occ config:system:set loglevel --type integer --value=1
  occ config:system:set memcache.local --value='\OC\Memcache\APCu'
  occ config:system:set trusted_proxies 0 --value=10.0.0.0/8
  occ config:system:set trusted_proxies 1 --value=172.16.0.0/12
  occ config:system:set trusted_proxies 2 --value=192.168.0.0/16
  occ config:system:set datadirectory --value=$DATA
  occ config:system:set simpleSignUpLink.shown --type=boolean --value=false
  occ encryption:scan:legacy-format && occ config:system:set encryption.legacy_format_support --type=boolean --value=false
fi

exec "$@"
