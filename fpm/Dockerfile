FROM php:7.0-apache

# install the PHP extensions we need
RUN apt-get update && apt-get install -y libpng12-dev libjpeg-dev libxml2-dev && rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-install gd \
	&& docker-php-ext-install soap \
	&& docker-php-ext-install mbstring
RUN docker-php-ext-install mysqli \
	&& docker-php-ext-install gd mysqli opcache

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

VOLUME /var/www/html

ENV WORDPRESS_VERSION 4.5.3
ENV WORDPRESS_SHA1 835b68748dae5a9d31c059313cd0150f03a49269

# upstream tarballs include ./wordpress/ so this gives us /usr/src/wordpress
RUN curl -o wordpress.tar.gz -SL https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz \
	&& echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c - \
	&& tar -xzf wordpress.tar.gz -C /usr/src/ \
	&& chown -R www-data:www-data /usr/src/wordpress \
	&& rm wordpress.tar.gz

# install language files
RUN curl -s https://he.wordpress.org/wordpress-${WORDPRESS_VERSION}-he_IL.tar.gz | tar -zx -C /usr/src/ --wildcards 'wordpress/wp-content/languages/*'

RUN chown -R www-data:www-data /usr/src/wordpress

COPY docker-entrypoint.sh /entrypoint.sh

# grr, ENTRYPOINT resets CMD now
ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
