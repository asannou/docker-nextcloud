FROM php:5.6-apache

ARG VERSION=11.0.4

WORKDIR /root

# https://docs.nextcloud.com/server/11/admin_manual/installation/source_installation.html#additional-apache-configurations
RUN a2enmod rewrite headers env dir mime

RUN apt-get update && apt-get install -y \
  bzip2 \
  libgd-dev \
  libzip-dev \
  libbz2-dev \
  libicu-dev \
  libmcrypt-dev

# Cleaning APT
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# https://docs.nextcloud.com/server/11/admin_manual/installation/source_installation.html#prerequisites
# Required, Database connectors, Recommended packages
RUN docker-php-ext-configure gd --with-jpeg-dir --with-png-dir --with-xpm-dir --with-vpx-dir
RUN docker-php-ext-install gd zip pdo_mysql bz2 intl mcrypt
# For enhanced server performance
#RUN yes '' | pecl install apcu-4.0.11
#RUN docker-php-ext-enable apcu

COPY php-sendmail.ini /usr/local/etc/php/conf.d/

RUN curl -s -O https://download.nextcloud.com/server/releases/nextcloud-${VERSION}.tar.bz2
RUN tar -xjf nextcloud-${VERSION}.tar.bz2
RUN rm nextcloud-${VERSION}.tar.bz2
RUN mv nextcloud /var/www/
RUN chown -R www-data:www-data /var/www/nextcloud/

# https://docs.nextcloud.com/server/11/admin_manual/installation/source_installation.html#apache-web-server-configuration
COPY nextcloud.conf /etc/apache2/sites-available/
RUN ln -s /etc/apache2/sites-available/nextcloud.conf /etc/apache2/sites-enabled/nextcloud.conf

VOLUME /volume

COPY config.php /root/
COPY entrypoint.sh /root/
ENTRYPOINT ["/root/entrypoint.sh"]
CMD ["apache2-foreground"]

