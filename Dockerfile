FROM php:8.3-apache
LABEL maintainer="priorist <contact@priorist.com>"

COPY res/service-config/apache/000-default.conf /etc/apache2/sites-enabled/000-default.conf
COPY res/service-config/php/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
COPY res/service-config/php/development.ini /usr/local/etc/php/conf.d/development.ini

# Install TYPO3 requirements
# Thanks to https://github.com/martin-helmich/docker-typo3
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        wget \
# Configure PHP
        libxml2-dev libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libpq-dev \
        libzip-dev \
        zlib1g-dev \
# Install required 3rd party tools
        graphicsmagick && \
# Configure extensions
    docker-php-ext-configure gd --with-libdir=/usr/include/ --with-jpeg --with-freetype && \
    docker-php-ext-install -j$(nproc) exif mysqli soap gd zip opcache intl mbstring pgsql pdo_pgsql && \
    echo 'always_populate_raw_post_data = -1\nmax_execution_time = 240\nmax_input_vars = 1500\nupload_max_filesize = 32M\npost_max_size = 32M' > /usr/local/etc/php/conf.d/typo3.ini && \
# Set default php.ini
    cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini && \
# Configure Apache as needed
    a2enmod rewrite && \
    apt-get clean && \
    apt-get -y purge \
        libxml2-dev libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libzip-dev \
        zlib1g-dev && \
    rm -rf /var/lib/apt/lists/* /usr/src/* && \
# Install XDebug
    pecl install xdebug

VOLUME /var/www/html
