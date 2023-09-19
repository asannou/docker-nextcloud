set +u

CONFIG=/var/www/html/config/config.php
DATA=/volume/data
UPLOADTMP=/volume/tmp

cp -n /volume/config.php $CONFIG || true
cp -n /root/config.php $CONFIG || true

test -e $DATA || mkdir $DATA
test -e $UPLOADTMP || mkdir $UPLOADTMP
chown www-data:root $CONFIG $DATA $UPLOADTMP

occ() {
  args=$(printf "'%s' " "$@")
  run_as "php /var/www/html/occ $args"
}

if occ status | grep -q '\- installed: true'
then
  occ app:enable circles
  occ upgrade --no-interaction
  occ db:add-missing-indices
  occ db:add-missing-columns
  occ db:add-missing-primary-keys
  occ maintenance:update:htaccess
  occ config:system:set loglevel --type integer --value=1
  occ config:system:set memcache.local --value='\OC\Memcache\APCu'
  occ config:system:set trusted_proxies 0 --value=10.0.0.0/8
  occ config:system:set trusted_proxies 1 --value=172.16.0.0/12
  occ config:system:set trusted_proxies 2 --value=192.168.0.0/16
  occ config:system:set datadirectory --value=$DATA
  occ config:system:set simpleSignUpLink.shown --type=boolean --value=false
  occ app:enable encryption
  occ encryption:enable
  test -n "$FORCE_MAINTENANCE_MODE_OFF" && occ maintenance:mode --off
fi

exec "$@"
