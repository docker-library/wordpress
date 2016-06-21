FROM php:5.6-apache

RUN a2enmod rewrite

# install the PHP extensions we need
RUN apt-get update && apt-get install -y git-core libsqlite3-dev libpq-dev libmcrypt-dev libpng12-dev libjpeg-dev && rm -rf /var/lib/apt/lists/* \
        && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
        && docker-php-ext-install gd mysqli mcrypt zip mbstring pdo pdo_mysql pdo_sqlite pdo_pgsql json

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

RUN curl -sS https://getcomposer.org/installer | php \
        && mv composer.phar /usr/local/bin/composer

ADD config/*.php /tmp/config/

ADD docker-entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ONBUILD ADD . /usr/src/october

ONBUILD RUN cd /usr/src/october \
      && composer install --no-interaction --prefer-dist \
      && cp /tmp/config/*.php config/

ONBUILD RUN chown -R www-data:www-data /usr/src/october

ONBUILD VOLUME /var/www/html

ONBUILD WORKDIR /var/www/html

ONBUILD ENTRYPOINT ["/entrypoint.sh"]

ONBUILD CMD ["apache2-foreground"]
