FROM asannou/library-php:7.2-apache

ARG VERSION=17.0.0
ARG USER_SAML_VERSION=2.4.0

WORKDIR /root

# https://docs.nextcloud.com/server/17/admin_manual/installation/source_installation.html#additional-apache-configurations
RUN a2enmod rewrite headers env dir mime sed

# https://docs.nextcloud.com/server/17/admin_manual/installation/source_installation.html#prerequisites-for-manual-installation
# Required, Database connectors, Recommended packages
RUN apt-get update \
  && apt-get install -y --no-install-recommends cron bzip2 unzip libpng-dev libfreetype6-dev libzip-dev libbz2-dev libicu-dev \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ \
  && docker-php-ext-install gd zip pdo_mysql bz2 intl opcache pcntl \
  && apt-get purge -y libpng-dev libfreetype6-dev libicu-dev \
# Download Nextcloud Server
  && apt-get install -y --no-install-recommends gnupg dirmngr \
  && curl -s -o nextcloud.tar.bz2 https://download.nextcloud.com/server/releases/nextcloud-${VERSION}.tar.bz2 \
  && curl -s -o nextcloud.tar.bz2.asc https://download.nextcloud.com/server/releases/nextcloud-${VERSION}.tar.bz2.asc \
  && export GNUPGHOME="$(mktemp -d)" \
  && for server in \
    ha.pool.sks-keyservers.net \
    hkp://p80.pool.sks-keyservers.net:80 \
    keyserver.ubuntu.com \
    hkp://keyserver.ubuntu.com:80 \
    pgp.mit.edu; \
  do \
    gpg --batch --keyserver $server --recv-keys 28806A878AE423A28372792ED75899B9A724937A && break || :; \
  done \
  && gpg --batch --verify nextcloud.tar.bz2.asc nextcloud.tar.bz2 \
  && gpgconf --kill all \
  && tar -xjf nextcloud.tar.bz2 -C /var/www/ \
  && curl -s https://github.com/nextcloud/server/compare/v${VERSION}...asannou:v${VERSION}-share-expiration.patch | patch -d /var/www/nextcloud -p 1 \
  && rm -r "$GNUPGHOME" nextcloud.tar.bz2 nextcloud.tar.bz2.asc \
  && apt-get purge -y gnupg dirmngr \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# https://docs.nextcloud.com/server/17/admin_manual/configuration_server/caching_configuration.html
RUN yes '' | pecl install apcu-5.1.18 \
  && yes '' | pecl install redis-5.0.2 \
  && docker-php-ext-enable apcu redis

# https://docs.nextcloud.com/server/17/admin_manual/installation/server_tuning.html#enable-php-opcache
COPY php-opcache.ini /usr/local/etc/php/conf.d/

COPY php-memory.ini /usr/local/etc/php/conf.d/
COPY php-sendmail.ini /usr/local/etc/php/conf.d/

RUN curl -s -L -o user_saml.tar.gz https://github.com/nextcloud/user_saml/releases/download/v${USER_SAML_VERSION}/user_saml-${USER_SAML_VERSION}.tar.gz \
  && tar -zxf user_saml.tar.gz -C /var/www/nextcloud/apps/ \
  && rm user_saml.tar.gz

RUN curl -s https://github.com/nextcloud/user_saml/compare/v${USER_SAML_VERSION}...asannou:v${USER_SAML_VERSION}-csrf.patch | patch -d /var/www/nextcloud/apps/user_saml -p 1

RUN chown -R www-data:www-data /var/www/nextcloud/

# https://docs.nextcloud.com/server/17/admin_manual/installation/source_installation.html#apache-web-server-configuration
COPY nextcloud.conf /etc/apache2/sites-available/
RUN a2ensite nextcloud.conf

VOLUME /volume

COPY config.php /root/
COPY entrypoint.sh /root/

ENTRYPOINT ["/root/entrypoint.sh"]
CMD ["apache2-foreground"]

