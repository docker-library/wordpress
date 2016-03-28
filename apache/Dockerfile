FROM php:5.6-apache

RUN a2enmod rewrite

# install the PHP extensions we need
RUN apt-get update && apt-get install -y git-core libsqlite3-dev libpq-dev libmcrypt-dev libpng12-dev libjpeg-dev && rm -rf /var/lib/apt/lists/* \
        && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
        && docker-php-ext-install gd mysqli mcrypt zip mbstring pdo pdo_mysql pdo_sqlite pdo_pgsql json

VOLUME /var/www/html

RUN curl -sS https://getcomposer.org/installer | php \
        && mv composer.phar /usr/local/bin/composer

RUN cd /usr/src && git clone https://github.com/octobercms/october.git && cd october && composer install --no-interaction --prefer-dist

COPY config/*.php /usr/src/october/config/

RUN chown -R www-data:www-data /usr/src/october

COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["apache2-foreground"]
