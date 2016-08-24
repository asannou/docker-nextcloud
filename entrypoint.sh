#!/bin/sh

set -e

chown www-data:root /var/www/nextcloud/config/config.php /var/www/nextcloud/data

exec "$@"
