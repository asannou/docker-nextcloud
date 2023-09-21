ARG version
FROM nextcloud:${version}-apache

ENV NEXTCLOUD_INIT_HTACCESS true
ENV PHP_MEMORY_LIMIT 512M

# Remove backslashes from password generation policy
COPY password_policy.patch /root/
RUN patch -d /usr/src/nextcloud/apps/password_policy -p 1 < /root/password_policy.patch

RUN echo 'upload_tmp_dir=/volume/tmp' >> "${PHP_INI_DIR}/conf.d/nextcloud.ini"
RUN echo 'sendmail_path=sendmail -t -i' >> "${PHP_INI_DIR}/conf.d/nextcloud.ini"

COPY entrypoint-wrapper.sh /
COPY enable-circles.sh /docker-entrypoint-hooks.d/pre-upgrade/
COPY fix-database.sh /docker-entrypoint-hooks.d/post-upgrade/
COPY entrypoint.sh /docker-entrypoint-hooks.d/before-starting/
COPY config.php /usr/src/nextcloud/config/

ENTRYPOINT ["/entrypoint-wrapper.sh"]
CMD ["apache2-foreground"]
