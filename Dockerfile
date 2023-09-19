ARG version
FROM nextcloud:${version}-apache

ENV PHP_MEMORY_LIMIT 512M
ENV PHP_UPLOAD_LIMIT 16G
ENV APACHE_BODY_LIMIT 0

RUN echo '0 4 * * * /usr/bin/find /var/www/html/data/ -regex /var/www/html/data/[^/]+/files/.* -ctime +30 -delete; /usr/local/bin/php /var/www/html/occ files:scan --all' >> /var/spool/cron/crontabs/www-data

# Remove backslashes from password generation policy
COPY password_policy.patch /root/
RUN patch -d /usr/src/nextcloud/apps/password_policy -p 1 < /root/password_policy.patch

RUN echo 'upload_tmp_dir=/volume/tmp' >> "${PHP_INI_DIR}/conf.d/nextcloud.ini"
RUN echo 'sendmail_path=sendmail -t -i' >> "${PHP_INI_DIR}/conf.d/nextcloud.ini"

COPY config.php /root/
COPY entrypoint.sh /root/

RUN sed 's@^exec @. /root/entrypoint.sh; exec @' -i /entrypoint.sh

