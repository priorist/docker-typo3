FROM php:7-apache
LABEL maintainer="priorist <contact@priorist.com>"

COPY res/service-config/apache/000-default.conf /etc/apache2/sites-enabled/000-default.conf
COPY res/service-config/php/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
COPY res/service-config/php/development.ini /usr/local/etc/php/conf.d/development.ini

# Install TYPO3 requirements
# Thanks to https://github.com/martin-helmich/docker-typo3
RUN apt-get update && \
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
    docker-php-ext-install -j$(nproc) mysqli soap gd zip opcache intl pgsql pdo_pgsql && \
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
    pecl install xdebug && \

# Install composer
    wget -O /usr/local/bin/composer https://getcomposer.org/composer-stable.phar && \
    chmod +x /usr/local/bin/composer && \

# Install TYPO3
    composer create-project "typo3/cms-base-distribution:^10.4" . && \
    touch public/FIRST_INSTALL && \
    mkdir config && \
    chown -R www-data:www-data .

VOLUME /var/www/html/config
VOLUME /var/www/html/var
VOLUME /var/www/html/public/typo3conf
VOLUME /var/www/html/public/typo3temp
VOLUME /var/www/html/public/fileadmin
