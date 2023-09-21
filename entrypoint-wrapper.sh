#!/bin/sh

set -eu

if [ -e /volume/config.php ] && [ -d /volume/data ]
then
  sed "s@'/volume/data'@'/var/www/html/data'@" -i /volume/config.php
  mv /volume/config.php /usr/src/nextcloud/config/
  mv /volume/data /var/www/html/
  echo '<?php $OC_Version = '$(php -r 'require "/usr/src/nextcloud/config/config.php"; var_export(explode(".", $CONFIG["version"]));')' ?>' > /var/www/html/version.php
fi

exec /entrypoint.sh "$@"
