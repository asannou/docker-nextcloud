#!/bin/sh

set -eu

CONFIG=/var/www/html/config/config.php
DATA=/var/www/html/data
UPLOADTMP=/volume/tmp

mkdir -p $DATA $UPLOADTMP
chown www-data:root $CONFIG $DATA $UPLOADTMP

occ() {
  /usr/local/bin/php /var/www/html/occ "$@"
}

list_enabled_apps() {
  occ app:list --output=json | sed -E 's/.*"enabled":\{([^}]+).*/\1/;s/"([^"]+)":"[^"]+",?/\1\n/g'
}

exclude_allowed_apps() {
  grep --invert-match --line-regexp --fixed-strings 'activity
admin_audit
circles
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
  occ app:enable encryption
  occ encryption:enable
  occ app:disable $(list_enabled_apps | exclude_allowed_apps) || true
  if [ -n "${FORCE_MAINTENANCE_MODE_OFF+x}" ]
  then
    occ maintenance:mode --off
  fi
fi

