FROM php:5.6-apache

ARG VERSION=9.0.53

WORKDIR /root

RUN apt-get update && apt-get install -y \
  bzip2 \
  patch \
  unzip \
  libgd-dev \
  libzip-dev \
  libbz2-dev \
  libicu-dev \
  libmcrypt-dev

# Cleaning APT
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# https://docs.nextcloud.com/server/9/admin_manual/installation/source_installation.html#additional-apache-configurations
RUN a2enmod rewrite headers env dir mime

# https://docs.nextcloud.com/server/9/admin_manual/installation/source_installation.html#prerequisites-label
# Required, Database connectors, Recommended packages
RUN docker-php-ext-configure gd --with-jpeg-dir --with-png-dir --with-xpm-dir --with-vpx-dir
RUN docker-php-ext-install gd zip pdo_mysql bz2 intl mcrypt
# For enhanced server performance
#RUN yes '' | pecl install apcu-4.0.11
#RUN docker-php-ext-enable apcu

RUN curl -s -O https://download.nextcloud.com/server/releases/nextcloud-${VERSION}.tar.bz2
RUN tar -xjf nextcloud-${VERSION}.tar.bz2 -C /var/www/
RUN rm nextcloud-${VERSION}.tar.bz2

COPY password-policy-on-createUser.patch /root/
RUN patch -d /var/www/nextcloud/ -p 1 < /root/password-policy-on-createUser.patch

RUN curl -s -O https://apps.owncloud.com/CONTENT/content-files/170608-registration.zip
RUN unzip 170608-registration.zip -d /var/www/nextcloud/apps/
RUN rm 170608-registration.zip

RUN chown -R www-data:www-data /var/www/nextcloud/

# https://docs.nextcloud.com/server/9/admin_manual/installation/source_installation.html#apache-configuration-label
COPY nextcloud.conf /etc/apache2/sites-available/
RUN ln -s /etc/apache2/sites-available/nextcloud.conf /etc/apache2/sites-enabled/nextcloud.conf

VOLUME /var/www/nextcloud/data

CMD ["sh", "-c", "chown www-data:root /var/www/nextcloud/config/config.php /var/www/nextcloud/data && apache2-foreground"]

