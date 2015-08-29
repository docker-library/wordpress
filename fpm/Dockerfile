FROM php:5.6-fpm

# install the PHP extensions we need
RUN apt-get update && apt-get install -y git-core libmcrypt-dev libpng12-dev libjpeg-dev && rm -rf /var/lib/apt/lists/ \
        && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
        && docker-php-ext-install gd mysqli mcrypt zip mbstring pdo pdo_mysql json

VOLUME /var/www/html

RUN curl -sS https://getcomposer.org/installer | php \
        && mv composer.phar /usr/local/bin/composer

# I'm using prefer-source so that I don't hit the Github API limit.
RUN composer create-project --no-interaction --prefer-source october/october /usr/src/october dev-master

COPY config/*.php /usr/src/october/config/

RUN chown -R www-data:www-data /usr/src/october

COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["php-fpm"]
