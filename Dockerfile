FROM php:7.2-apache

ARG VERSION=15.0.2

WORKDIR /root

# https://docs.nextcloud.com/server/15/admin_manual/installation/source_installation.html#additional-apache-configurations
RUN a2enmod rewrite headers env dir mime remoteip

# https://docs.nextcloud.com/server/15/admin_manual/installation/source_installation.html#prerequisites-for-manual-installation
# Required, Database connectors, Recommended packages
RUN apt-get update \
  && apt-get install -y --no-install-recommends cron bzip2 unzip libpng-dev libfreetype6-dev libzip-dev libbz2-dev libicu-dev \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ \
  && docker-php-ext-install gd zip pdo_mysql bz2 intl opcache \
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
  && rm -r "$GNUPGHOME" nextcloud.tar.bz2 nextcloud.tar.bz2.asc \
  && apt-get purge -y gnupg dirmngr \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# For enhanced server performance
#RUN yes '' | pecl install apcu-4.0.11
#RUN docker-php-ext-enable apcu

RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/cron

# https://docs.nextcloud.com/server/15/admin_manual/configuration_server/server_tuning.html#enable-php-opcache
COPY php-opcache.ini /usr/local/etc/php/conf.d/
COPY php-sendmail.ini /usr/local/etc/php/conf.d/

RUN curl -s -L -O https://github.com/pellaeon/registration/releases/download/v0.3.0/registration.tar.gz \
  && tar -zxf registration.tar.gz -C /var/www/nextcloud/apps/ \
  && rm registration.tar.gz

RUN curl -s -L -o user_saml.tar.gz https://github.com/nextcloud/user_saml/releases/download/v2.1.0/user_saml-2.1.0.tar.gz \
  && tar -zxf user_saml.tar.gz -C /var/www/nextcloud/apps/ \
  && rm user_saml.tar.gz

RUN curl -s https://github.com/asannou/user_saml/commit/476e66589f845a2eb6890f83e8427e4c488cd06d.patch | patch -d /var/www/nextcloud/apps/user_saml -p 1

RUN chown -R www-data:www-data /var/www/nextcloud/

# https://docs.nextcloud.com/server/15/admin_manual/installation/source_installation.html#apache-web-server-configuration
COPY nextcloud.conf /etc/apache2/sites-available/
RUN a2ensite nextcloud.conf

COPY crontab /root/
RUN crontab -u www-data /root/crontab

VOLUME /volume

COPY config.php /root/
COPY entrypoint.sh /root/

ENTRYPOINT ["/root/entrypoint.sh"]
CMD ["apache2-foreground"]

