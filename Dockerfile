ARG version
FROM nextcloud:${version}-apache

ENV NEXTCLOUD_UPDATE 1
ENV NEXTCLOUD_INIT_HTACCESS true
ENV PHP_MEMORY_LIMIT 512M

RUN apt-get update \
  && apt-get install -y supervisor \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir /var/log/supervisord /var/run/supervisord

COPY supervisord.conf /

# Remove backslashes from password generation policy
COPY password_policy.patch /root/
RUN patch -d /usr/src/nextcloud/apps/password_policy -p 1 < /root/password_policy.patch

# Allow null in $password for user key in encryption
COPY generate_password_hash.patch /root/
RUN patch -d /usr/src/nextcloud -p 1 < /root/generate_password_hash.patch

RUN echo 'upload_tmp_dir=/var/www/html/upload_tmp' >> "${PHP_INI_DIR}/conf.d/nextcloud.ini"
RUN echo 'sendmail_path=sendmail -t -i' >> "${PHP_INI_DIR}/conf.d/nextcloud.ini"

COPY enable-circles.sh /docker-entrypoint-hooks.d/pre-upgrade/
COPY fix-database.sh /docker-entrypoint-hooks.d/post-upgrade/
COPY entrypoint.sh /docker-entrypoint-hooks.d/before-starting/
COPY config.php /usr/src/nextcloud/config/

CMD ["/usr/bin/supervisord", "-c", "/supervisord.conf"]
