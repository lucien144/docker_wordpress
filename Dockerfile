ARG COMPOSER_VERSION=2.0

FROM composer:${COMPOSER_VERSION} as composer
FROM php:8.0-fpm


RUN apt-get update -y && apt-get install -y \
    pkg-config libssl-dev \
    curl \
    openssl \
    zip unzip \
    zlib1g-dev libpng-dev \
    libwebp-dev \
    libjpeg-dev \
    libzip-dev \
    libmagickwand-dev \
    nasm \
    nginx \
    supervisor

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install some PHP extension
RUN docker-php-ext-install mysqli pdo pdo_mysql && docker-php-ext-enable mysqli
RUN docker-php-ext-install zip && docker-php-ext-enable zip
RUN docker-php-ext-install exif && docker-php-ext-enable exif
RUN pecl install imagick && docker-php-ext-enable imagick
RUN docker-php-ext-configure gd --enable-gd --with-jpeg --with-webp && docker-php-ext-install -j$(nproc) gd

# Installing composer
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

# Configure nginx
COPY /config/nginx/nginx.conf /etc/nginx/nginx.conf
COPY /config/nginx/50x.html /var/www/localhost/htdocs/50x.html
COPY /config/nginx/index.html /var/www/localhost/htdocs/index.html

# Configure php-fpm
COPY /config/fpm-pool.conf /usr/local/etc/php-fpm.d/fpm-pool.conf

# Configure supervisor
COPY /config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

WORKDIR /var/www/html
COPY wordpress/ /var/www/html

# RUN composer install
# Replaced by "docker exec"

VOLUME /var/www/html

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:80/fpm-ping