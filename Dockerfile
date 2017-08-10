FROM php:5.6-apache

ARG VERSION=12.0.1

WORKDIR /root

# https://docs.nextcloud.com/server/12/admin_manual/installation/source_installation.html#additional-apache-configurations
RUN a2enmod rewrite headers env dir mime

RUN apt-get update && apt-get install -y \
  cron \
  bzip2 \
  libgd-dev \
  libzip-dev \
  libbz2-dev \
  libicu-dev \
  libmcrypt-dev

# Cleaning APT
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/cron

# https://docs.nextcloud.com/server/12/admin_manual/installation/source_installation.html#prerequisites-for-manual-installation
# Required, Database connectors, Recommended packages
RUN docker-php-ext-configure gd --with-jpeg-dir --with-png-dir --with-xpm-dir --with-vpx-dir
RUN docker-php-ext-install gd zip pdo_mysql bz2 intl mcrypt
# For enhanced server performance
#RUN yes '' | pecl install apcu-4.0.11
#RUN docker-php-ext-enable apcu

COPY php-sendmail.ini /usr/local/etc/php/conf.d/

RUN curl -s -O https://download.nextcloud.com/server/releases/nextcloud-${VERSION}.tar.bz2
RUN tar -xjf nextcloud-${VERSION}.tar.bz2 -C /var/www/
RUN rm nextcloud-${VERSION}.tar.bz2

RUN curl -s -L -O https://github.com/pellaeon/registration/releases/download/v0.2.5/registration.tar.gz
RUN tar -zxf registration.tar.gz -C /var/www/nextcloud/apps/
RUN rm registration.tar.gz

RUN chown -R www-data:www-data /var/www/nextcloud/

# https://docs.nextcloud.com/server/12/admin_manual/installation/source_installation.html#apache-web-server-configuration
COPY nextcloud.conf /etc/apache2/sites-available/
RUN ln -s /etc/apache2/sites-available/nextcloud.conf /etc/apache2/sites-enabled/nextcloud.conf

COPY crontab /root/
RUN crontab -u www-data /root/crontab

VOLUME /volume

COPY config.php /root/
COPY entrypoint.sh /root/
ENTRYPOINT ["/root/entrypoint.sh"]
CMD ["apache2-foreground"]

