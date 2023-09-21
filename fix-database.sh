#!/bin/sh

set -eu

php /var/www/html/occ db:add-missing-indices
php /var/www/html/occ db:add-missing-columns
php /var/www/html/occ db:add-missing-primary-keys
