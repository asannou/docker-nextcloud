FROM php:5.6-apache

ARG VERSION=9.0.53

EXPOSE 80

WORKDIR /root

RUN a2enmod rewrite headers env dir mime

RUN apt-get update
RUN apt-get install -y bzip2

RUN apt-get install -y libgd-dev libzip-dev libmcrypt-dev libicu-dev libbz2-dev libmagickwand-dev
RUN docker-php-ext-install gd zip mcrypt intl bz2 pdo_mysql
RUN yes '' | pecl install imagick apcu-4.0.11
RUN docker-php-ext-enable imagick apcu

RUN curl -O https://download.nextcloud.com/server/releases/nextcloud-${VERSION}.tar.bz2
RUN tar -xjf nextcloud-${VERSION}.tar.bz2
RUN mv nextcloud /var/www/
RUN chown -R www-data:www-data /var/www/nextcloud/

COPY nextcloud.conf /etc/apache2/sites-available/
RUN ln -s /etc/apache2/sites-available/nextcloud.conf /etc/apache2/sites-enabled/nextcloud.conf
