FROM php:7.1-apache

WORKDIR /root

# https://docs.nextcloud.com/server/14/admin_manual/installation/source_installation.html#additional-apache-configurations
RUN a2enmod rewrite headers env dir mime remoteip

# https://docs.nextcloud.com/server/14/admin_manual/installation/source_installation.html#prerequisites-for-manual-installation
# Required, Database connectors, Recommended packages
RUN apt-get update \
  && apt-get install -y cron bzip2 unzip libpng-dev libzip-dev libbz2-dev libicu-dev \
  && docker-php-ext-install gd zip pdo_mysql bz2 intl opcache \
  && apt-get remove -y libpng-dev libicu-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# For enhanced server performance
#RUN yes '' | pecl install apcu-4.0.11
#RUN docker-php-ext-enable apcu

RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/cron

COPY php-opcache.ini /usr/local/etc/php/conf.d/
COPY php-sendmail.ini /usr/local/etc/php/conf.d/

ARG VERSION=14.0.6

RUN curl -s -o nextcloud.tar.bz2 https://download.nextcloud.com/server/releases/nextcloud-${VERSION}.tar.bz2 \
  && tar -xjf nextcloud.tar.bz2 -C /var/www/ \
  && rm nextcloud.tar.bz2

RUN curl -s -L -O https://github.com/pellaeon/registration/releases/download/v0.3.0/registration.tar.gz \
  && tar -zxf registration.tar.gz -C /var/www/nextcloud/apps/ \
  && rm registration.tar.gz

RUN curl -s -L -o user_saml.tar.gz https://github.com/nextcloud/user_saml/releases/download/v2.1.0/user_saml-2.1.0.tar.gz \
  && tar -zxf user_saml.tar.gz -C /var/www/nextcloud/apps/ \
  && rm user_saml.tar.gz

RUN chown -R www-data:www-data /var/www/nextcloud/

# https://docs.nextcloud.com/server/14/admin_manual/installation/source_installation.html#apache-web-server-configuration
COPY nextcloud.conf /etc/apache2/sites-available/
RUN a2ensite nextcloud.conf

COPY crontab /root/
RUN crontab -u www-data /root/crontab

VOLUME /volume

COPY config.php /root/
COPY entrypoint.sh /root/
ENTRYPOINT ["/root/entrypoint.sh"]
CMD ["apache2-foreground"]

