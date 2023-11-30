#!/bin/sh

set -eu

DATA=/var/www/html/data
UPLOADTMP=/volume/tmp

mkdir -p $DATA $UPLOADTMP

occ() {
  /usr/local/bin/php /var/www/html/occ "$@"
}

if occ status | grep -q '\- installed: true'
then
  occ upgrade
  occ app:enable encryption
  occ encryption:enable
  if [ -n "${FORCE_MAINTENANCE_MODE_OFF+x}" ]
  then
    occ maintenance:mode --off
  fi
fi

