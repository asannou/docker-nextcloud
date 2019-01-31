#!/bin/sh

set -e

CONFIG=/volume/config.php
DATA=/volume/data

cron

test -e $CONFIG || cp /root/config.php $CONFIG
test -e $DATA || mkdir $DATA
chown www-data:root $CONFIG $DATA

ln -snf $CONFIG /var/www/nextcloud/config/

occ() {
  args="$@"
  su - -s /bin/sh -c "/usr/local/bin/php /var/www/nextcloud/occ $args" www-data
}

if occ status | grep -q '\- installed: true'
then
  for app in \
    accessibility \
    federation \
    files_external \
    files_pdfviewer \
    files_texteditor \
    files_trashbin \
    files_versions \
    files_videoplayer \
    firstrunwizard \
    gallery \
    sharebymail \
    support \
    survey_client \
    systemtags \
    user_ldap; \
  do
    occ app:disable $app
  done
  occ upgrade --no-interaction
  occ db:add-missing-indices
  occ db:convert-filecache-bigint
  occ config:system:set trusted_proxies 0 --value=10.0.0.0/8
  occ config:system:set trusted_proxies 1 --value=172.16.0.0/12
  occ config:system:set trusted_proxies 2 --value=192.168.0.0/16
  occ config:system:set datadirectory --value=$DATA
  occ config:system:set skeletondirectory
  occ config:system:set enable_previews --type=boolean --value=false
fi

exec "$@"
