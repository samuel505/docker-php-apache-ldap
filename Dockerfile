FROM php:7.3-apache

RUN a2enmod rewrite && a2enmod headers

RUN apt-get update &&\
    apt-get install --no-install-recommends --assume-yes --quiet ca-certificates curl git &&\
    rm -rf /var/lib/apt/lists/*

RUN apt-get update &&\
	apt-get install imagemagick -y

RUN apt-get update -y && apt-get install -y sendmail libpng-dev

RUN apt-get update && \
    apt-get install -y \
        zlib1g-dev 

# install the PHP extensions we need
RUN apt-get update && apt-get install -y locales git-core libsqlite3-dev libicu-dev libldap2-dev libfreetype6-dev libjpeg62-turbo-dev mariadb-client libmcrypt-dev libpq-dev libexif-dev libmcrypt-dev libjpeg-dev && rm -rf /var/lib/apt/lists/* \
        && docker-php-ext-configure gd --with-png-dir=/usr --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include \
	&& docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
        && docker-php-ext-install gd mysql mysqli ldap calendar opcache mcrypt gettext intl exif zip mbstring pdo pdo_mysql pdo_sqlite pdo_pgsql json

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
	composer global require drush/drush && \
	composer global require cweagans/composer-patches && \
	#composer require drupal/console:~1.0 --prefer-dist --optimize-autoloader && \
    ln -s /root/.composer/vendor/bin/drush /usr/local/bin/drush 
    
# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini
	
RUN { \
		echo 'date.timezone=Pacific/Noumea'; \
	} > /usr/local/etc/php/conf.d/timezone.ini

RUN echo "fr_FR.UTF-8 UTF-8" > /etc/locale.gen && \
locale-gen && \
update-locale LANG=fr_FR.UTF-8 LANGUAGE=fr_FR LC_ALL=fr_FR.UTF-8 && \
export LANG=fr_FR.UTF-8 LANGUAGE=fr_FR LC_ALL=fr_FR.UTF-8

ENV LANG=fr_FR.UTF-8 \
    LANGUAGE=fr_FR \
    LC_ALL=fr_FR.UTF-8

VOLUME /var/www/html
