#!/bin/sh

set -eu

DATA=/var/www/html/data
UPLOADTMP=/volume/tmp

mkdir -p $DATA $UPLOADTMP

occ() {
  /usr/local/bin/php /var/www/html/occ "$@"
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
files_antivirus
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
  occ maintenance:mode --off
  occ upgrade
  occ app:enable encryption
  occ encryption:enable
  occ app:disable $(list_enabled_apps | exclude_allowed_apps) || true
  occ config:app:set files_antivirus av_mode --value daemon
  occ config:app:set files_antivirus av_host --value clamav
  occ config:app:set files_antivirus av_port --value 3310
fi

