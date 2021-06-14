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
  args=$(printf "'%s' " "$@")
  su - -s /bin/sh -c "/usr/local/bin/php /var/www/nextcloud/occ $args" www-data
}

list_enabled_apps() {
  occ app:list --output=json | sed -E 's/.*"enabled":\{([^}]+).*/\1/;s/"([^"]+)":"[^"]+",?/\1\n/g'
}

exclude_allowed_apps() {
  grep --invert-match --line-regexp --fixed-strings 'activity
admin_audit
comments
dav
encryption
files
files_sharing
logreader
nextcloud_announcements
password_policy
serverinfo
theming
updatenotification
user_saml'
  }

if occ status | grep -q '\- installed: true'
then
  occ upgrade --no-interaction
  occ db:add-missing-indices
  occ db:add-missing-columns
  occ db:add-missing-primary-keys
  occ db:convert-filecache-bigint --no-interaction
  occ config:system:set memcache.local --value='\OC\Memcache\APCu'
  occ config:system:set trusted_proxies 0 --value=10.0.0.0/8
  occ config:system:set trusted_proxies 1 --value=172.16.0.0/12
  occ config:system:set trusted_proxies 2 --value=192.168.0.0/16
  occ config:system:set datadirectory --value=$DATA
  occ config:system:set skeletondirectory
  occ config:system:set enable_previews --type=boolean --value=false
  occ config:system:set simpleSignUpLink.shown --type=boolean --value=false
  occ encryption:scan:legacy-format && occ config:system:set encryption.legacy_format_support --type=boolean --value=false
  occ app:disable $(list_enabled_apps | exclude_allowed_apps) || true
fi

exec "$@"
